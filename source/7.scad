// Standee #7
include <standee_lib.scad>;

standee(
        svg_width     = DEFAULT_SVG_WIDTH,
        shape_thick   = DEFAULT_THICKNESS,
        s_leg_width   = DEFAULT_LEG_WIDTH,
        s_leg_height  = DEFAULT_LEG_HEIGHT+4,
        s_leg_overlap = DEFAULT_LEG_OVERLAP+4) {
    import("svgs/7.svg");
        translate([-5.5, 1.4]) square([0.4, 23.7]);
        translate([5.5, 1.4]) square([0.4, 23.7]);
        translate([-11.1, 4.7]) square([0.4, 13.8]);
        translate([11.1, 5.1]) square([0.4, 13.8]);
}
