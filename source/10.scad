// Standee #10
use <standee_lib.scad>;

// SVG content: 58x86 px (auto-filled)
standee(svg_width     = 58,
        svg_height    = 86,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60,
        s_leg_overlap = 3)
    union() {
        import("svgs/10.svg", center = true);
        translate([7, -19]) square([1, 35]);
    }
