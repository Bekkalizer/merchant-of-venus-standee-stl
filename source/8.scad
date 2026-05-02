// Standee #8
include <standee_lib.scad>;

standee(
        svg_width     = DEFAULT_SVG_WIDTH,
        shape_thick   = DEFAULT_THICKNESS,
        s_leg_width   = DEFAULT_LEG_WIDTH,
        s_leg_height  = DEFAULT_LEG_HEIGHT+2,
        s_leg_overlap = DEFAULT_LEG_OVERLAP+2)
    import("svgs/8.svg");
        translate([-0.0, 2.3]) square([0.4, 21.0]);
