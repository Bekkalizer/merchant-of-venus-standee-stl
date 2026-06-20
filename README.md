```
                                                                                                           
 ......  @@@@   @@@@@                .              .                    ..... 
 ....   @@=@@ %@@@#%@   +@@@@  @@@=     @@+  #   *.    .           .   =...... 
 ...   @@  @@@@  @##@  @@@:+  @@  @@ @@= -@ @@. @@   @@@@  @@@* @=  @@   ..... 
 ...  @@  +@@=   @@@@ -@@    @@.@@@  @@  @ #@@ .@@ %@@ #@  @  @@@  -@#  ...... 
 ...                                                                   ....... 
 ...  @--@ @@ =  @@@@   @@@@@@@@ @@@@@@@. @@@   @@ %@@   @@@ *@@@@@@@  ....... 
 ... @@ +@ @@+-  @@#@=      @@@  @@-     @@+@@  @  @@   -@@-%@@       ........ 
 ...             %@#@@ .   @@   @@@      @  @@@@@ @@+  *@@@     @@@@  ........ 
 ...............  @#@@    @@   @@@@+@@@ @@   @@@* @@@@@ @@. @@@#@@@  ......... 
 ...............  @%@@   @@                                          ......... 
 ...............  @@%@ #@@   .....................    .......   .............. 
 ...............  @@@@@@   ...................................................                          
                                                                                                         
```

# Merchant of Venus — Standee STLs

3D-printable player standees for the board game **Merchant of Venus**.

Each player token is a two-part set: a flat, decorative **numbered shape** (1–14) that
push-fits via a small leg into a shared **base**. The shapes are ornate flame/crest
silhouettes with the token number cut out of the middle.

| | |
|---|---|
| **Pieces** | 14 numbered shapes + 1 universal base |
| **Format** | Ready-to-print `.stl`, parametric OpenSCAD source |
| **Supports** | None required (see orientation below) |
| **License** | GPL-3.0 |

---

## 1. Printing

All ready-to-print files live in [`stl-renders/`](stl-renders/):

- [`1.stl`](stl-renders/1.stl) … [`14.stl`](stl-renders/14.stl) — the numbered shape pieces (shape + leg)
- [`base.stl`](stl-renders/base.stl) — the universal base

### What to print

You need **one numbered shape and one base per token — 14 sets total**:

- Print `1.stl` through `14.stl`, one of each.
- Print **`base.stl` ×14** (every token uses an identical base).

### Orientation & settings

- **Shapes** print flat, lying on their back, so the whole silhouette sits on the bed —
  no supports needed. Thin floating details (flame tips, the number) are tied together
  by built-in support stripes so nothing prints in mid-air.
- **The base** is modelled upside down (slot facing up) so it also prints without supports.
- Any common filament works. A small layer height gives the cleanest curved edges.

### Assembly

Slide a shape's leg into the slot in a base. The fit is a friction push-fit
(0.2 mm tolerance per side by default) — no glue needed, but a dab helps if your
printer runs loose.

---

## 2. Contributing & source

All source lives in [`source/`](source/). The models are fully parametric, so most
changes are a one-line edit.

```
source/
├── standee_lib.scad   ← shared modules + all default dimensions
├── 1.scad .. 14.scad  ← one file per numbered shape
├── base.scad          ← the base piece
├── trace_to_svg.py    ← PNG → smooth-curve SVG tracer
├── svgs/              ← generated shape outlines (1.svg .. 14.svg)
└── images/            ← source silhouette PNGs (1.png .. 14.png)
```

### How a shape is built

Each `N.scad` imports its outline from `svgs/N.svg` and hands it to the `standee()`
module in `standee_lib.scad`, which extrudes the shape, adds the leg, and (optionally)
adds support stripes. The SVG is normalized to 1 mm wide, so the module scales it to
the desired physical width — swap in any 1 mm-wide SVG and it just works.

### Tunable parameters

Defaults live at the top of [`standee_lib.scad`](source/standee_lib.scad); override any
of them per shape in the `standee(...)` call.

| Parameter | Default | Description |
|---|---|---|
| `svg_width` | 30 mm | Physical width of the shape (height auto-scales) |
| `shape_thick` | 2 mm | Extrusion thickness (shape & leg) |
| `s_leg_width` | 4 mm | Width of the leg peg |
| `s_leg_height` | 40 mm | Total length of the leg |
| `s_leg_overlap` | 3 mm | How far the leg extends up into the shape |
| `support_y_offset` | 1 mm | Lifts all support stripes up into the shape |

Base parameters (size, slot tolerance, corner fillet) are in `base.scad` /
`standee_lib.scad`.

### Adding support stripes

Disconnected parts of a silhouette are bound together with thin stripes. Pass them as
**extra children** of `standee()`, after the `import` — note the curly braces, which
make them children of the module (without braces they are ignored):

```scad
standee(s_leg_height = DEFAULT_LEG_HEIGHT + 4) {
    import("svgs/7.svg");
    translate([-5.5, 1.4]) square([0.4, 23.7]);   // a 0.4 mm-wide stripe
    translate([ 5.5, 1.4]) square([0.4, 23.7]);
}
```

Stripe coordinates are in millimetres. They are extruded to `shape_thick` along with the
shape and lifted by `support_y_offset` so their bottoms tuck inside the silhouette for
clean flat printing.

### Regenerating the SVGs

The tracer turns the low-resolution silhouette PNGs in `images/` into smooth, curved
outlines (it fits cubic Béziers through the pixel boundary, keeps sharp flame tips, and
drops noise specks):

```sh
cd source
python3 trace_to_svg.py
```

This writes `svgs/*.svg` and creates a `.scad` wrapper for any image that doesn't have
one yet (existing `.scad` files are never overwritten). Smoothing is tunable via the
`eps_factor`, `corner_deg`, `tension`, and `min_area` arguments in `trace_to_svg.py`.
Requires Python 3 with [Pillow](https://pypi.org/project/Pillow/).

### Rendering STLs

Open a `.scad` file in [OpenSCAD](https://openscad.org/) and render with **F6**, then
export the STL (or use `openscad -o N.stl N.scad` on the command line).

### Contributions welcome

New token designs, cleaner outlines, better support layouts, or print-setting notes are
all welcome — open an issue or a pull request.

---

## License

Licensed under the [GNU General Public License v3.0](LICENSE). See
[gnu.org/licenses/gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.html) for a plain-language summary.
