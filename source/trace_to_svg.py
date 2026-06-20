"""Trace a black silhouette PNG to a SMOOTH, curved SVG outline.

Unlike trace_to_svg.py (one <rect> per pixel -> blocky staircase edges),
this tracer treats the pixels as *guides* for the underlying smooth shape:

  1. Trace the real foreground/background boundary as closed loops
     (outer body + interior holes such as the embossed number).
  2. Simplify each loop with Douglas-Peucker so the pixel staircase
     collapses into clean straight runs (tolerance scales with the
     detected pixel size).
  3. Smooth the simplified polyline into cubic Beziers using a
     corner-aware Catmull-Rom: gentle turns become rounded curves,
     while genuinely sharp corners (flame tips, number serifs) stay
     crisp.

The boundary passes along the true silhouette edge (between fg and bg
pixels), so every pixel still constrains the curve — but the result is
made of smooth lines instead of square steps.

Output is a single <path> filled black with fill-rule="evenodd",
normalized to 1mm wide, cropped and translated to the content bounding
box, so it drops straight into the standee .scad files. A per-shape
.scad wrapper is generated for any image that doesn't have one yet.
"""
import math
import os
import sys
from PIL import Image


# --------------------------------------------------------------------------
# 1. Boundary extraction
# --------------------------------------------------------------------------

def load_mask(input_path, threshold=128):
    """Return (mask, w, h). mask[y][x] is True for foreground (dark)."""
    img = Image.open(input_path).convert("L")
    w, h = img.size
    px = img.load()
    mask = [[px[x, y] < threshold for x in range(w)] for y in range(h)]
    return mask, w, h


def trace_boundaries(mask, w, h):
    """Extract all closed boundary loops between foreground and background.

    Returns a list of loops; each loop is a list of (x, y) integer
    vertices on the pixel grid (pixel corners), in pixel coordinates.

    Convention: each foreground pixel contributes the directed edges of
    its square wherever a background pixel (or the image border) sits on
    the far side. Edges are oriented foreground-on-the-right, so outer
    loops wind clockwise and holes counter-clockwise. Winding is
    irrelevant to the even-odd fill we emit, but a consistent orientation
    lets us chain edges into loops.
    """
    def fg(x, y):
        return 0 <= x < w and 0 <= y < h and mask[y][x]

    # start vertex -> list of end vertices
    out = {}

    def add(a, b):
        out.setdefault(a, []).append(b)

    for y in range(h):
        row = mask[y]
        for x in range(w):
            if not row[x]:
                continue
            if not fg(x, y - 1):            # background above -> top edge
                add((x, y), (x + 1, y))
            if not fg(x + 1, y):            # background right -> right edge
                add((x + 1, y), (x + 1, y + 1))
            if not fg(x, y + 1):            # background below -> bottom edge
                add((x + 1, y + 1), (x, y + 1))
            if not fg(x - 1, y):            # background left -> left edge
                add((x, y + 1), (x, y))

    loops = []
    for start in list(out.keys()):
        while out.get(start):
            loop = [start]
            cur = start
            prev_dir = None
            while True:
                ends = out.get(cur)
                if not ends:
                    break
                nxt = _pick_next(cur, ends, prev_dir)
                ends.remove(nxt)
                if not ends:
                    del out[cur]
                prev_dir = (nxt[0] - cur[0], nxt[1] - cur[1])
                cur = nxt
                if cur == start:
                    break
                loop.append(cur)
            if len(loop) >= 4:
                loops.append(loop)
    return loops


def _pick_next(cur, ends, prev_dir):
    """At a vertex with several outgoing edges (diagonal pixel touch),
    keep the loop from self-crossing by taking the sharpest clockwise
    turn relative to how we arrived."""
    if len(ends) == 1 or prev_dir is None:
        return ends[0]

    def clockwise_score(end):
        d = (end[0] - cur[0], end[1] - cur[1])
        # angle of turn from prev_dir to d, measured clockwise (y-down)
        ang = math.atan2(
            prev_dir[0] * d[1] - prev_dir[1] * d[0],   # cross
            prev_dir[0] * d[0] + prev_dir[1] * d[1],    # dot
        )
        return ang  # most negative = sharpest clockwise; pick that

    return min(ends, key=clockwise_score)


# --------------------------------------------------------------------------
# 2. Pixel-size detection + simplification
# --------------------------------------------------------------------------

def detect_pixel_size(loops):
    """Estimate the underlying pixel block size from axis-aligned run
    lengths along the boundaries. For native-resolution art this is ~1;
    for upscaled pixel art (e.g. each design pixel drawn as an NxN block)
    it recovers N as the GCD of straight-run lengths."""
    from math import gcd
    g = 0
    for loop in loops:
        n = len(loop)
        i = 0
        while i < n:
            ax, ay = loop[i]
            bx, by = loop[(i + 1) % n]
            run = abs(bx - ax) + abs(by - ay)
            if run:
                g = gcd(g, run)
            i += 1
    return g if g else 1


def loop_area(loop):
    """Absolute polygon area (shoelace), in px²."""
    s = 0.0
    n = len(loop)
    for i in range(n):
        x0, y0 = loop[i]
        x1, y1 = loop[(i + 1) % n]
        s += x0 * y1 - x1 * y0
    return abs(s) / 2.0


def _perp_dist(p, a, b):
    if a == b:
        return math.hypot(p[0] - a[0], p[1] - a[1])
    num = abs((b[0] - a[0]) * (a[1] - p[1]) - (a[0] - p[0]) * (b[1] - a[1]))
    return num / math.hypot(b[0] - a[0], b[1] - a[1])


def _dp(points, eps):
    """Douglas-Peucker on an open polyline."""
    if len(points) < 3:
        return points[:]
    dmax, idx = 0.0, 0
    a, b = points[0], points[-1]
    for i in range(1, len(points) - 1):
        d = _perp_dist(points[i], a, b)
        if d > dmax:
            dmax, idx = d, i
    if dmax > eps:
        left = _dp(points[:idx + 1], eps)
        right = _dp(points[idx:], eps)
        return left[:-1] + right
    return [a, b]


def simplify_loop(loop, eps):
    """Douglas-Peucker on a *closed* loop. Anchored at the point farthest
    from the centroid so the start/end seam can't distort a flat edge."""
    n = len(loop)
    if n < 4:
        return loop[:]
    cx = sum(p[0] for p in loop) / n
    cy = sum(p[1] for p in loop) / n
    anchor = max(range(n), key=lambda i: (loop[i][0] - cx) ** 2 + (loop[i][1] - cy) ** 2)
    rot = loop[anchor:] + loop[:anchor]
    rot.append(rot[0])                 # close it for the open-polyline DP
    simp = _dp(rot, eps)
    if simp[0] == simp[-1]:
        simp = simp[:-1]
    return simp


# --------------------------------------------------------------------------
# 3. Corner-aware smoothing -> cubic Beziers
# --------------------------------------------------------------------------

def _turn_angle(prev, cur, nxt):
    """Interior turn angle in degrees at `cur` (0 = straight)."""
    ax, ay = cur[0] - prev[0], cur[1] - prev[1]
    bx, by = nxt[0] - cur[0], nxt[1] - cur[1]
    la = math.hypot(ax, ay)
    lb = math.hypot(bx, by)
    if la == 0 or lb == 0:
        return 0.0
    cosv = max(-1.0, min(1.0, (ax * bx + ay * by) / (la * lb)))
    return math.degrees(math.acos(cosv))


def smooth_to_beziers(pts, corner_deg=68.0, tension=1.0):
    """Convert a closed polyline into a list of cubic Bezier segments.

    Each segment is (P0, C1, C2, P3). The curve interpolates every input
    point (so it tracks the pixel guides). At a vertex whose turn exceeds
    `corner_deg` the tangent is killed on that side, keeping the corner
    sharp; elsewhere a Catmull-Rom tangent rounds the turn smoothly.
    """
    n = len(pts)
    if n < 3:
        return []

    is_corner = []
    for i in range(n):
        ang = _turn_angle(pts[(i - 1) % n], pts[i], pts[(i + 1) % n])
        is_corner.append(ang > corner_deg)

    k = tension / 6.0
    beziers = []
    for i in range(n):
        p0 = pts[i]
        p3 = pts[(i + 1) % n]
        pm = pts[(i - 1) % n]
        pn = pts[(i + 2) % n]

        # outgoing tangent at p0 (zero if p0 is a corner)
        if is_corner[i]:
            t0 = (0.0, 0.0)
        else:
            t0 = ((p3[0] - pm[0]) * k, (p3[1] - pm[1]) * k)
        # incoming tangent at p3 (zero if p3 is a corner)
        if is_corner[(i + 1) % n]:
            t3 = (0.0, 0.0)
        else:
            t3 = ((pn[0] - p0[0]) * k, (pn[1] - p0[1]) * k)

        c1 = (p0[0] + t0[0], p0[1] + t0[1])
        c2 = (p3[0] - t3[0], p3[1] - t3[1])
        beziers.append((p0, c1, c2, p3))
    return beziers


def _bezier_point(b, t):
    (p0, c1, c2, p3) = b
    u = 1 - t
    a = u * u * u
    bb = 3 * u * u * t
    cc = 3 * u * t * t
    d = t * t * t
    return (a * p0[0] + bb * c1[0] + cc * c2[0] + d * p3[0],
            a * p0[1] + bb * c1[1] + cc * c2[1] + d * p3[1])


# --------------------------------------------------------------------------
# 4. SVG emission
# --------------------------------------------------------------------------

def curve_bbox(all_beziers, steps=12):
    minx = miny = float("inf")
    maxx = maxy = float("-inf")
    for beziers in all_beziers:
        for b in beziers:
            for s in range(steps + 1):
                x, y = _bezier_point(b, s / steps)
                minx = min(minx, x); maxx = max(maxx, x)
                miny = min(miny, y); maxy = max(maxy, y)
    return minx, miny, maxx, maxy


def write_svg(output_path, all_beziers):
    minx, miny, maxx, maxy = curve_bbox(all_beziers)
    cw = maxx - minx
    ch = maxy - miny
    aspect = ch / cw
    norm_w = 1
    norm_h = aspect

    def fx(x):
        return round(x - minx, 3)

    def fy(y):
        return round(y - miny, 3)

    with open(output_path, "w") as f:
        f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        f.write('<svg xmlns="http://www.w3.org/2000/svg" '
                f'width="{norm_w}mm" height="{norm_h:.6f}mm" '
                f'viewBox="0 0 {cw:.3f} {ch:.3f}">\n')
        f.write('  <path fill="black" fill-rule="evenodd" d="')
        parts = []
        for beziers in all_beziers:
            if not beziers:
                continue
            p0 = beziers[0][0]
            parts.append(f"M {fx(p0[0])} {fy(p0[1])}")
            for (_, c1, c2, p3) in beziers:
                parts.append(f"C {fx(c1[0])} {fy(c1[1])} "
                             f"{fx(c2[0])} {fy(c2[1])} "
                             f"{fx(p3[0])} {fy(p3[1])}")
            parts.append("Z")
        f.write(" ".join(parts))
        f.write('"/>\n')
        f.write("</svg>\n")
    return cw, ch, aspect


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------

def trace_image_to_svg(input_path, output_path, threshold=128,
                       eps_factor=1.1, corner_deg=68.0, tension=1.0,
                       min_area=6.0):
    mask, w, h = load_mask(input_path, threshold)
    loops = trace_boundaries(mask, w, h)
    if not loops:
        print(f"  WARNING: no foreground found in {input_path}")
        return None
    psize = detect_pixel_size(loops)
    eps = max(0.5, eps_factor * psize)

    # Drop tiny noise specks/pinholes (potrace's "turdsize"), scaled to
    # the detected pixel size so upscaled art isn't over-pruned.
    area_thresh = min_area * psize * psize
    kept = [l for l in loops if loop_area(l) >= area_thresh]
    dropped = len(loops) - len(kept)
    loops = kept

    all_beziers = []
    pts_before = pts_after = 0
    for loop in loops:
        pts_before += len(loop)
        simp = simplify_loop(loop, eps)
        pts_after += len(simp)
        if len(simp) < 3:
            continue
        all_beziers.append(smooth_to_beziers(simp, corner_deg, tension))

    cw, ch, aspect = write_svg(output_path, all_beziers)
    print(f"  {len(loops)} loop(s) (+{dropped} noise dropped), "
          f"pixel-size~{psize}, eps={eps:.2f}, "
          f"{pts_before}->{pts_after} pts, bbox {cw:.1f}x{ch:.1f}, "
          f"aspect {aspect:.3f}")
    return all_beziers


def write_scad_wrapper(name, svg_path):
    """Generate a per-shape .scad file.

    Does NOT overwrite an existing .scad file (so user customizations
    are preserved).
    """
    scad_path = name + ".scad"
    if os.path.exists(scad_path):
        print(f"  {scad_path} already exists — not overwriting")
        return

    with open(scad_path, "w") as f:
        f.write(f"// Standee #{name}\n")
        f.write(f"use <standee_lib.scad>;\n\n")
        f.write(f"standee(svg_width     = 40,\n")
        f.write(f"        shape_thick   = 2,\n")
        f.write(f"        s_leg_width   = 8,\n")
        f.write(f"        s_leg_height  = 60,\n")
        f.write(f"        s_leg_overlap = 3)\n")
        f.write(f"    import(\"{svg_path}\");\n")

    print(f"Wrote {scad_path}")


if __name__ == "__main__":
    import glob

    svg_dir = sys.argv[1] if len(sys.argv) > 1 else "svgs"
    png_pattern = sys.argv[2] if len(sys.argv) > 2 else "images/*.png"

    os.makedirs(svg_dir, exist_ok=True)

    def num_key(f):
        base = os.path.basename(f).rsplit(".", 1)[0]
        return int(base) if base.isdigit() else 1 << 30

    png_files = sorted(glob.glob(png_pattern), key=num_key)

    for input_file in png_files:
        name = os.path.basename(input_file).rsplit(".", 1)[0]
        svg_file = os.path.join(svg_dir, name + ".svg")
        print(f"\n--- {name} ---")
        trace_image_to_svg(input_file, svg_file)
        write_scad_wrapper(name, f"svgs/{name}.svg")
