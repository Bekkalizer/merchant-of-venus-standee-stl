// Standee #9
use <standee_lib.scad>;

// SVG content: 76x68 px (auto-filled)
standee(svg_width     = 76,
        svg_height    = 68,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 60+5,
        s_leg_overlap = 3+5)
    union() {
        import("svgs/9.svg", center = true);
        translate([-0.5, -31.5]) square([1, 65]);
        
        translate([-16, -26]) square([1, 53]);
        translate([14, -26]) square([1, 51]);
        
        translate([-24, -27]) square([1, 48]);
        translate([23, -27]) square([1, 48]);
        
        translate([-30, -13])  square([15, 1]);
        translate([15, -13])  square([15, 1]);
        
    }
