// Standee #11
include <standee_lib.scad>;

standee(
        svg_width     = DEFAULT_SVG_WIDTH,
        shape_thick   = DEFAULT_THICKNESS,
        s_leg_width   = DEFAULT_LEG_WIDTH,
        s_leg_height  = DEFAULT_LEG_HEIGHT+2,
        s_leg_overlap = DEFAULT_LEG_OVERLAP+2) {
    import("svgs/11.svg");
        translate([-0.8, 15.2]) square([0.4, 13.0]);

        translate([-8.5, 0.0]) square([0.4, 16.0]);
        translate([7.5, 0.0]) square([0.4, 15.0]);
}
