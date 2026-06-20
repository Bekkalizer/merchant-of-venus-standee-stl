// standee_lib.scad — shared modules for standee + base
//
// SVGs are normalized to 1mm wide by trace_to_svg.py.
// The standee module scales by svg_width directly — no SVG-specific
// parameters needed. Swap in any 1mm-wide SVG and it just works.

// --- Default dimensions ---

// Shape
DEFAULT_SVG_WIDTH       = 30;     // mm — width of the shape (height auto-scales)
DEFAULT_THICKNESS       = 2;      // mm — extrusion thickness (shape & leg)

// Leg (peg under the shape)
DEFAULT_LEG_WIDTH       = 4;      // mm
DEFAULT_LEG_HEIGHT      = 40;     // mm
DEFAULT_LEG_OVERLAP     = 3;      // mm — how far leg extends into shape
DEFAULT_LEG_TOLERANCE   = 0.2;    // mm — push-fit gap per side

// Support stripes (the thin bridges that bind floating parts together)
DEFAULT_SUPPORT_Y_OFFSET = 1;     // mm — lift ALL supports up into the shape
                                  // so their bottoms tuck inside the
                                  // silhouette (flat, support-free printing)

// Base
DEFAULT_BASE_WIDTH      = 30;     // mm — X dimension
DEFAULT_BASE_DEPTH      = 15;     // mm — Y dimension
DEFAULT_BASE_HEIGHT     = 4;      // mm — Z dimension
DEFAULT_BASE_FILLET     = 1.5;    // mm — corner rounding


// --- Modules ---

// Standee: extrude a 2D SVG shape + optional support stripes + leg.
//
// First child = SVG import (gets scaled to svg_width mm)
// Additional children = support stripes in mm coordinates (not scaled)
//
// The SVG must be normalized to 1mm wide (trace_to_svg.py does this).
// Import WITHOUT center=true.
//
//   svg_width:    desired width in mm (height auto-scales with aspect ratio)
//   shape_thick:  extrusion thickness
//   s_leg_width:  width of the leg
//   s_leg_height: total length of the leg
//   s_leg_overlap: how far leg extends into the shape
module standee(svg_width        = DEFAULT_SVG_WIDTH,
               shape_thick      = DEFAULT_THICKNESS,
               s_leg_width      = DEFAULT_LEG_WIDTH,
               s_leg_height     = DEFAULT_LEG_HEIGHT,
               s_leg_overlap    = DEFAULT_LEG_OVERLAP,
               support_y_offset = DEFAULT_SUPPORT_Y_OFFSET) {

    linear_extrude(height = shape_thick)
        union() {
            // Shape: first child, scaled to svg_width, centered on X
            translate([-svg_width/2, 0])
                scale([svg_width, svg_width])
                    children(0);

            // Extra children (support stripes etc.) — unscaled, in mm.
            // Lifted uniformly by support_y_offset so their bottoms tuck
            // into the shape instead of hanging below it.
            if ($children > 1)
                translate([0, support_y_offset])
                    for (i = [1:$children-1])
                        children(i);

            // Leg: centered on X, extending downward from Y=s_leg_overlap
            translate([-s_leg_width/2, s_leg_overlap - s_leg_height])
                square([s_leg_width, s_leg_height]);
        }
}

// Base: rounded rectangular plate with a slot matching the leg cross-section.
// Printed upside down (slot opens upward on print bed).
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
        translate([0, 0, base_height/2])
            minkowski() {
                cube([base_width - 2*fillet,
                      base_depth - 2*fillet,
                      base_height - 1], center = true);
                cylinder(r = fillet, h = 1, $fn = 32);
            }
        translate([-slot_w/2, -slot_d/2, -0.01])
            cube([slot_w, slot_d, base_height + 0.02]);
    }
}
