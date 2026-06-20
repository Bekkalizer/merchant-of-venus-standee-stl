// Standee #9
include <standee_lib.scad>;

standee(
        svg_width     = DEFAULT_SVG_WIDTH,
        shape_thick   = DEFAULT_THICKNESS,
        s_leg_width   = DEFAULT_LEG_WIDTH,
        s_leg_height  = DEFAULT_LEG_HEIGHT+3,
        s_leg_overlap = DEFAULT_LEG_OVERLAP+3) {
    import("svgs/9.svg");
        translate([-0.2, 1.0]) square([0.4, 22.7]);
        
        translate([-6.3, 3.2]) square([0.4, 19.5]);
        translate([5.5, 3.2]) square([0.4, 19.1]);
        
        translate([-9.5, 6]) square([0.4, 13.5]);
        translate([9.1, 7.4]) square([0.4, 11.9]);
        
        translate([-11.8, 8.3])  square([5.9, 0.4]);
        translate([5.9, 8.3])  square([5.9, 0.4]);
}

