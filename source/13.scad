// Standee #13
use <standee_lib.scad>;

// SVG content: 75x75 px (auto-filled)
standee(svg_width     = 75,
        svg_height    = 75,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60+3,
        s_leg_overlap = 3+3)
    import("svgs/13.svg", center = true);
