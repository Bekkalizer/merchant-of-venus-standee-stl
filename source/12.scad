// Standee #12
include <standee_lib.scad>;

standee(
        svg_width     = 30,
        shape_thick   = DEFAULT_THICKNESS,
        s_leg_width   = DEFAULT_LEG_WIDTH,
        s_leg_height  = DEFAULT_LEG_HEIGHT+4,
        s_leg_overlap = DEFAULT_LEG_OVERLAP+4)
    import("svgs/12.svg");
