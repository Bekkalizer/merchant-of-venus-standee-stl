// Standee #10
include <standee_lib.scad>;

standee(
        svg_width     = DEFAULT_SVG_WIDTH,
        shape_thick   = DEFAULT_THICKNESS,
        s_leg_width   = DEFAULT_LEG_WIDTH,
        s_leg_height  = DEFAULT_LEG_HEIGHT+5,
        s_leg_overlap = DEFAULT_LEG_OVERLAP+5) {
    import("svgs/10.svg");
        translate([3.6, 12.4]) square([0.5, 18.1]);
}
