// Standee #14
use <standee_lib.scad>;

// SVG content: 74x73 px (auto-filled)
standee(svg_width     = 74,
        svg_height    = 73,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60,
        s_leg_overlap = 3)
    union() {
        import("svgs/14.svg", center = true);
        translate([5, -31.5]) square([1, 54]);
    }
