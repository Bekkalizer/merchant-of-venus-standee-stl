// Standee #12
use <standee_lib.scad>;

// SVG content: 78x77 px (auto-filled)
standee(svg_width     = 78,
        svg_height    = 77,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60+4,
        s_leg_overlap = 3+4)
    import("svgs/12.svg", center = true);
