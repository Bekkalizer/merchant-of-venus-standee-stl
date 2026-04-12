// Standee #6
use <standee_lib.scad>;

// SVG content: 77x76 px (auto-filled)
standee(svg_width     = 77,
        svg_height    = 76,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60,
        s_leg_overlap = 3)
    import("svgs/6.svg", center = true);
