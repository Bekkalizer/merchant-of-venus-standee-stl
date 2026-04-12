// Standee #2
use <standee_lib.scad>;

// SVG content: 57x74 px (auto-filled)
standee(svg_width     = 57,
        svg_height    = 74,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60,
        s_leg_overlap = 3)
    import("svgs/2.svg", center = true);
