"""Trace a black silhouette PNG to SVG outline.

Uses run-length encoding merged into rectangles for clean geometry
that OpenSCAD's CGAL renderer can handle.

Crops the SVG to the content bounding box so that the SVG dimensions
match the actual shape — making scale calculations in OpenSCAD correct.

Also generates a per-shape .scad wrapper file with the SVG dimensions
pre-filled, so the user only has to specify model parameters.
"""
import os
import sys
from PIL import Image


def trace_image_to_svg(input_path, output_path, threshold=128):
    img = Image.open(input_path).convert("L")
    w, h = img.size
    pixels = img.load()

    # Find content bounding box
    min_x, min_y, max_x, max_y = w, h, 0, 0
    for y in range(h):
        for x in range(w):
            if pixels[x, y] < threshold:
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x + 1)
                max_y = max(max_y, y + 1)

    content_w = max_x - min_x
    content_h = max_y - min_y
    print(f"  Content bbox: {content_w}x{content_h} px "
          f"(cropped from {w}x{h})")

    # Extract horizontal runs of dark pixels
    runs = []
    for y in range(h):
        x = 0
        while x < w:
            if pixels[x, y] < threshold:
                x_start = x
                while x < w and pixels[x, y] < threshold:
                    x += 1
                runs.append((x_start, y, x - x_start))
            else:
                x += 1

    # Merge vertically adjacent runs with same x_start and length
    runs.sort(key=lambda r: (r[0], r[2], r[1]))
    merged = []
    i = 0
    while i < len(runs):
        x_start, y_start, length = runs[i]
        y_end = y_start
        while (i + 1 < len(runs) and
               runs[i + 1][0] == x_start and
               runs[i + 1][2] == length and
               runs[i + 1][1] == y_end + 1):
            i += 1
            y_end = runs[i][1]
        merged.append((x_start, y_start, length, y_end - y_start + 1))
        i += 1

    print(f"  {len(runs)} horizontal runs -> {len(merged)} merged rectangles")

    # Write SVG — cropped to content bounding box.
    # Translate all coordinates so the content starts at (0, 0).
    # OpenSCAD does not honour the viewBox origin offset, so we must
    # shift the geometry ourselves to keep import(center=true) correct.
    with open(output_path, "w") as f:
        f.write(f'<?xml version="1.0" encoding="UTF-8"?>\n')
        # Use mm units so OpenSCAD imports 1 SVG unit = 1mm
        # (without mm, OpenSCAD converts px at 96 DPI)
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" '
                f'width="{content_w}mm" height="{content_h}mm" '
                f'viewBox="0 0 {content_w} {content_h}">\n')

        for x, y, rw, rh in merged:
            f.write(f'  <rect x="{x - min_x}" y="{y - min_y}" '
                    f'width="{rw}" height="{rh}" fill="black"/>\n')

        f.write("</svg>\n")

    print(f"Wrote {output_path}: {len(merged)} rectangles, "
          f"{content_w}x{content_h} px")
    return content_w, content_h


def write_scad_wrapper(name, svg_path, w, h):
    """Generate a per-shape .scad file with the SVG dimensions baked in.

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
        f.write(f"// SVG content: {w}x{h} px (auto-filled)\n")
        f.write(f"standee(svg_width     = {w},\n")
        f.write(f"        svg_height    = {h},\n")
        f.write(f"        shape_width   = 40,\n")
        f.write(f"        shape_thick   = 2,\n")
        f.write(f"        s_leg_width   = 8,\n")
        f.write(f"        s_leg_height  = 60,\n")
        f.write(f"        s_leg_overlap = 3)\n")
        f.write(f"    import(\"{svg_path}\", center = true);\n")

    print(f"Wrote {scad_path}")


if __name__ == "__main__":
    import glob

    svg_dir = sys.argv[1] if len(sys.argv) > 1 else "svgs"
    png_pattern = sys.argv[2] if len(sys.argv) > 2 else "../*.png"

    os.makedirs(svg_dir, exist_ok=True)

    png_files = sorted(glob.glob(png_pattern),
                       key=lambda f: int(os.path.basename(f).rsplit(".", 1)[0]))

    for input_file in png_files:
        name = os.path.basename(input_file).rsplit(".", 1)[0]
        svg_file = os.path.join(svg_dir, name + ".svg")
        print(f"\n--- {name} ---")
        w, h = trace_image_to_svg(input_file, svg_file)
        # .scad wrapper references SVG relative to source/ directory
        svg_rel = f"svgs/{name}.svg"
        write_scad_wrapper(name, svg_rel, w, h)
