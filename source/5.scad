// Standee #5
use <standee_lib.scad>;

// SVG content: 64x63 px (auto-filled)
standee(svg_width     = 64,
        svg_height    = 63,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 61,
        s_leg_overlap = 4)
    import("svgs/5.svg", center = true);
