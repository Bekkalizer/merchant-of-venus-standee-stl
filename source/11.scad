// Standee #11
use <standee_lib.scad>;

// SVG content: 80x81 px (auto-filled)
standee(svg_width     = 80,
        svg_height    = 81,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60+2,
        s_leg_overlap = 3+2)
    union() {
        import("svgs/11.svg", center = true);
        translate([-2, 0]) square([1, 40]);
        
        translate([-20, -38]) square([1, 40]);
        translate([20, -38]) square([1, 40]);
    }
