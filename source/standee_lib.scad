// standee_lib.scad — shared modules for standee + base
//
// All model dimensions are passed as named arguments to standee() and base()
// with sensible defaults. SVG dimensions (svg_width, svg_height) are
// auto-filled by trace_to_svg.py when generating the per-shape .scad files.

// --- Default dimensions ---

// Shape (standee body)
DEFAULT_SHAPE_WIDTH     = 40;     // mm — physical width of the shape
DEFAULT_THICKNESS       = 2;      // mm — extrusion thickness (shape & leg)

// Leg (peg under the shape)
DEFAULT_LEG_WIDTH       = 8;      // mm — width of the leg (4× thickness)
DEFAULT_LEG_HEIGHT      = 60;     // mm — total length of the leg
DEFAULT_LEG_OVERLAP     = 3;      // mm — how far the leg extends into the shape
DEFAULT_LEG_TOLERANCE   = 0.2;    // mm — push-fit gap per side

// Base
DEFAULT_BASE_WIDTH      = 30;     // mm — X dimension
DEFAULT_BASE_DEPTH      = 15;     // mm — Y dimension
DEFAULT_BASE_HEIGHT     = 4;      // mm — Z dimension
DEFAULT_BASE_FILLET     = 1.5;    // mm — corner rounding


// --- Modules ---

// Standee: extrude a 2D SVG shape (passed as child) + leg as a single piece.
//
//   svg_width, svg_height: source SVG dimensions in px (auto-filled by tracer)
//   width:        physical width of the shape in mm (height auto-scales)
//   thickness:    extrusion thickness — shared by shape and leg
//   leg_width:    width of the leg
//   leg_height:   total length of the leg
//   leg_overlap:  how far the top of the leg extends into the shape
module standee(svg_width, svg_height,
               shape_width   = DEFAULT_SHAPE_WIDTH,
               shape_thick   = DEFAULT_THICKNESS,
               s_leg_width   = DEFAULT_LEG_WIDTH,
               s_leg_height  = DEFAULT_LEG_HEIGHT,
               s_leg_overlap = DEFAULT_LEG_OVERLAP) {

    sf = shape_width / svg_width;
    sh = svg_height * sf;
    sb = -sh / 2;

    lt = sb + s_leg_overlap;
    lb = lt - s_leg_height;

    linear_extrude(height = shape_thick)
        union() {
            scale([sf, sf])
                children();
            translate([-s_leg_width/2, lb])
                square([s_leg_width, s_leg_height]);
        }
}

// Base: rounded rectangular plate with a slot matching the leg cross-section.
// Printed upside down (slot opens upward) to avoid bridging on the print bed.
//
//   base_width, base_depth, base_height: base dimensions in mm
//   leg_width, leg_thickness:            leg cross-section (must match standee)
//   tolerance:                           push-fit gap per side
//   fillet:                              corner radius
module base(base_width    = DEFAULT_BASE_WIDTH,
            base_depth    = DEFAULT_BASE_DEPTH,
            base_height   = DEFAULT_BASE_HEIGHT,
            leg_width     = DEFAULT_LEG_WIDTH,
            leg_thickness = DEFAULT_THICKNESS,
            tolerance     = DEFAULT_LEG_TOLERANCE,
            fillet        = DEFAULT_BASE_FILLET) {

    slot_w = leg_width     + 2 * tolerance;
    slot_d = leg_thickness + 2 * tolerance;

    translate([0, 0, base_height])
    rotate([180, 0, 0])
    difference() {
        // Rounded base block
        translate([0, 0, base_height/2])
            minkowski() {
                cube([base_width - 2*fillet,
                      base_depth - 2*fillet,
                      base_height - 1], center = true);
                cylinder(r = fillet, h = 1, $fn = 32);
            }
        // Slot — goes all the way through the base
        translate([-slot_w/2, -slot_d/2, -0.01])
            cube([slot_w, slot_d, base_height + 0.02]);
    }
}
