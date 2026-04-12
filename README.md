                                                                                                           
 ..........  @@@@@@- .   @@@@@@@  ............................................................................................ 
 .......... =@@###@=   .@@#####@  ............................................................................................ 
 ........   @@@@##@*  .@@%#####@  ...                   ........     ...    ...    ......    ...... .......................... 
 ........  @@+ @##@- @@@ @#####@  ..    =@@@@@    :#@#                      .      ...        ..       .               ....... 
 .......  @@@  @##@@@@@  @#####@  .  @@@        @@@   @@@@   @@@@:@@@   @@@    @@@ ..   @@@@@ .  @@@@@   @@  @@@@@@@@@ ....... 
 ......  @@@   @###@@@   @#####@-   @@%@@@@@@  @@@    @@@  @@@@    @   @@#@@@ @@@     @@. @#@    @@@@@  .@#    @@@@    ....... 
 .....  @@@    @##@@.  . @#####@%   @%@@      @@@@%@@@     @@@         @%@@   @%@    @@ . @#@   @@  @@@@@@  .  @%@  .......... 
 ..... @@@  .  @@@@   .. @@@@@@@@  @@@@       @@@   @@@@ @ @@@@  @@@  @@@@   @@@@  =@@  . @@@   @@   @@@@@ .. @@@@  .......... 
 ..... @@  ... %@@   ... -@@@@%@.  @%%@@@@@@  @=.    @@@:     #@@     @#%  . @%@  =@      -@@  @@  .  @@@  .. @@@  ........... 
 .....                 .                                                  ..                                      ............ 
 ....  .@@:@@@  *@@@@@ . @@@@@@@@ ... @@@@@@@@@@@@@  @@@@@@@@@@@@@ @@@@@@  .. +@@  @@@@@ ..  @@@@@   @@@@@@@@@@@- ............ 
 .... @@@   @@  @@     . :@#####@ ...      @@##@@+  @@#@@          @@@@#@@    @@@  @%#@= ..  @##@@ @@@@      @@@  ............ 
 .... @@@  @@  @@@.-:...  @#####@  .......  @#@@=   @@#@          @@@ @@#@+   @@- @@#@@     @@#@@  @@#@@         ............. 
 ....   @@@    =@   ....  @#####@  ......  @@@@    @@#%@@@@@@@@@  @@   @@@@@ @@@  @%#@@    @@##@@  .@@@@@@@@@#  .............. 
 ......     ..    ....... @%####@@ .....  @@@@     @##@@         @@@   :@#%@@@@  @@##@   :@@##%@          @#@@@ .............. 
 ........................ @@####@@ ...   @@@@  .. @@##@          @@  .  @@@##@@  @@##@@@@@ @##@@          @@@@@ .............. 
 ........................  @#####@ ..   @@@@  ... @@@@@@@@@@@@@ @@@  ..  @@@@@    @@@@@@  =@@@@  @@@@@@@@@@@.   .............. 
 ........................  @#####@ .   @@@@  ....                   ....        .                             ................ 
 ......................... @#####@    @@@   .................................................................................. 
 ......................... @#####@  +@@@:  ................................................................................... 
 ......................... @%####@  @@@   .................................................................................... 
 ......................... @@####@@@@@  ...................................................................................... 
 ......................... .@@@@@@@@@   ...................................................................................... 
                                                                                                           
                                                                                                         
# Merchant of Venus — Standee STLs

3D-printable standees for the board game Merchant of Venus. Each standee consists of a numbered shape piece that push-fits into a shared base.

## Printing

You need to print **one numbered standee and one base per player token** (14 sets total).

All ready-to-print STL files are in the [`stl-renders/`](stl-renders/) folder:

- `1.stl` through `14.stl` — the numbered standee pieces (shape + leg)
- `base.stl` — the universal base (print 14 of these)

The base is oriented for printing without supports (slot facing up). The standees print flat on their side.

## Folder structure

```
├── README.md
├── stl-renders/            ← Ready-to-print STL files
│   ├── 1.stl .. 14.stl     ← Numbered standee pieces
│   └── base.stl            ← Universal base (print ×14)
└── source/                 ← OpenSCAD source files
    ├── standee_lib.scad    ← Shared library (standee + base modules)
    ├── 1.scad .. 14.scad   ← Per-number standee definitions
    ├── base.scad           ← Base piece definition
    ├── trace_to_svg.py     ← PNG → SVG tracer script
    ├── svgs/               ← Generated SVG outlines
    │   └── 1.svg .. 14.svg
    └── images/             ← Source PNG images
        ├── 1.png .. 14.png
        ├── numbers1.png    ← Original number sheets
        └── numbers2.png
```

## Modifying

The source `.scad` files are parameterized. Each standee file lets you adjust:

| Parameter | Default | Description |
|---|---|---|
| `shape_width` | 40 mm | Physical width of the shape |
| `shape_thick` | 2 mm | Extrusion thickness (shape & leg) |
| `s_leg_width` | 8 mm | Width of the leg peg |
| `s_leg_height` | 60 mm | Total length of the leg |
| `s_leg_overlap` | 3 mm | How far the leg extends into the shape |

Base parameters can be adjusted in `base.scad`. See `standee_lib.scad` for all defaults.

To regenerate SVGs from source images:

```sh
cd source
python3 trace_to_svg.py
```

## License

This project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html). See [LICENSE](LICENSE) for details.
