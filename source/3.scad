// Standee #3
// Needs two bridging pins to connect the crown top to the base body
use <standee_lib.scad>;

// SVG content: 69x70 px (auto-filled)
// Scale factor: 40/69 = 0.5797
sf = 40 / 69;

standee(svg_width     = 69,
        svg_height    = 70,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 65,
        s_leg_overlap = 8)
        import("svgs/3.svg", center = true);
