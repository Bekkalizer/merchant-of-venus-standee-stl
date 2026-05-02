// Standee #3
// Needs two bridging pins to connect the crown top to the base body
include <standee_lib.scad>;

standee(
        svg_width     = DEFAULT_SVG_WIDTH,
        shape_thick   = DEFAULT_THICKNESS,
        s_leg_width   = DEFAULT_LEG_WIDTH,
        s_leg_height  = DEFAULT_LEG_HEIGHT+5,
        s_leg_overlap = DEFAULT_LEG_OVERLAP+5)
        import("svgs/3.svg");
