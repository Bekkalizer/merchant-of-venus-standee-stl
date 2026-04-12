// Standee #8
use <standee_lib.scad>;

// SVG content: 77x75 px (auto-filled)
standee(svg_width     = 77,
        svg_height    = 75,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 62,
        s_leg_overlap = 5)
    union() {
        import("svgs/8.svg", center = true);
        translate([-0, -31.5]) square([1, 54]);
    }
