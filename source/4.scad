// Standee #4
// Thin support stripes to hold disconnected parts together
include <standee_lib.scad>;

standee(
        svg_width     = DEFAULT_SVG_WIDTH,
        shape_thick   = DEFAULT_THICKNESS,
        s_leg_width   = DEFAULT_LEG_WIDTH,
        s_leg_height  = DEFAULT_LEG_HEIGHT+7,
        s_leg_overlap = DEFAULT_LEG_OVERLAP+7) {
    import("svgs/4.svg");

        // Vertical support stripes (1mm wide, full height)
        //translate([-8.3, 0.0]) square([0.4, 31.2]);
        //translate([-6.2, 0.0]) square([0.4, 25.0]);
        translate([0.0, 7.1])   square([0.4, 15.7]);
        //translate([5.8, 0.0])  square([0.4, 25.0]);
        //translate([8.3, 0.0])  square([0.4, 31.2]);

        // Horizontal support stripes (1mm tall, full width)
        translate([-14.6, 8.2]) square([29.2, 0.4]);
        translate([-12.1, 14.2])   square([24.6, 0.4]);
        //translate([-10.0, 21.9])  square([20.0, 0.4]);
}
