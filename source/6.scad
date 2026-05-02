// Standee #6
include <standee_lib.scad>;

standee(
        svg_width     = DEFAULT_SVG_WIDTH,
        shape_thick   = DEFAULT_THICKNESS,
        s_leg_width   = DEFAULT_LEG_WIDTH,
        s_leg_height  = DEFAULT_LEG_HEIGHT,
        s_leg_overlap = DEFAULT_LEG_OVERLAP)
    import("svgs/6.svg");
