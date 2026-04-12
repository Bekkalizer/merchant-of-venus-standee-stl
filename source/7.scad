// Standee #7
use <standee_lib.scad>;

// SVG content: 76x70 px (auto-filled)
standee(svg_width     = 76,
        svg_height    = 70,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60+6,
        s_leg_overlap = 3+6)
    union() {
        import("svgs/7.svg", center = true);
        translate([-14, -31.5]) square([1, 60]);
        translate([14, -31.5]) square([1, 60]);
        translate([-28, -23]) square([1, 35]);
        translate([28, -22]) square([1, 35]);
    }
