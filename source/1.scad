// Standee #1
use <standee_lib.scad>;

// SVG content: 65x71 px (auto-filled)
standee(svg_width     = 65,
        svg_height    = 71,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60,
        s_leg_overlap = 3)
    import("svgs/1.svg", center = true);
