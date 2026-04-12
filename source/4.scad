// Standee #4
// Thin support stripes to hold disconnected parts together
use <standee_lib.scad>;

// SVG content: 72x75 px (auto-filled)
standee(svg_width     = 72,
        svg_height    = 75,
        shape_width   = 40,
        shape_thick   = 2,
        s_leg_width   = 8,
        s_leg_height  = 67,
        s_leg_overlap = 10)
    union() {
        import("svgs/4.svg", center = true);

        // Vertical support stripes (1mm wide, full height)
        //translate([-20, -37.5]) square([1, 75]);
        translate([-15, -37.5]) square([1, 60]);
        translate([0, -20.5])   square([1, 40]);
        translate([14, -37.5])  square([1, 60]);
        //translate([20, -37.5])  square([1, 75]);

        // Horizontal support stripes (1mm tall, full width)
        translate([-35, -15.5]) square([70, 1]);
        translate([-29, 0])   square([59, 1]);
        translate([-24, 15])  square([48, 1]);
    }
