// Including it with use <> prevents global variables set in the GUI
// from propagating into keycap.scad.
include <keycap.scad>

// Angular resulution of keycap surface
$fa = 2;

// Whether to render RGB LED cutouts in the keycaps
$rgb = true;
// Mantis plate explosion offset
$explode = 0;

// Prevent rendering key in keycap.scad
no_key = true;

// Show switches
show_switch = true;
// Show keys
show_key = true;
// Model of mantis sound channels
show_sound = false;

// Mid layer height
mid_layer_height = 6;
// Tilt angle for home keys
tilt1 = 15;
// Tilt angle for outside keys
tilt2 = 15;

// Bottom PCB color
bottom_color = "green";
// Top PCB color
top_color = "white";

module mantis() {
    module base() {
        linear_extrude(height = 1.61, convexity = 10)
            offset(delta = -0.1) translate([-254, 127]) import("base.dxf", convexity = 10);
    }
    module sound_plate_main_split() {
        linear_extrude(height = 2.99, convexity = 10)
            offset(delta = -0.1) translate([-254, 127]) import("sound_plate_main_split.dxf", convexity = 10);
    }
    module main_split() {
        linear_extrude(height = 1.59, convexity = 10)
            offset(delta = -0.1) translate([-254, 127]) import("main_split.dxf", convexity = 10);
    }
    module plate_main_split() {
        linear_extrude(height = 2.21, convexity = 10)
            offset(delta = -0.1) translate([-254, 127]) import("plate_main_split.dxf", convexity = 10);
    }
    module sound_plate_raised() {
        linear_extrude(height = mid_layer_height - 0.01, convexity = 10)
            offset(delta = -0.1) translate([-254, 127]) import("sound_plate_raised.dxf", convexity = 10);
    }
    module raised() {
        linear_extrude(height = 1.59, convexity = 10)
            offset(delta = -0.1) translate([-254, 127]) import("raised.dxf", convexity = 10);
    }
    module plate_raised() {
        linear_extrude(height = 2.21, convexity = 10)
            offset(delta = -0.1) translate([-254, 127]) import("plate_raised.dxf", convexity = 10);
    }

    ex1 = $explode;
    ex2 = 2 * ex1;
    ex3 = 3 * ex1;
    ex4 = 4 * ex1;
    ex5 = 5 * ex1;
    ex6 = 6 * ex1;

    // Solid parts first
    color(bottom_color) translate([-ex1/2, 0, 4.6 + ex2]) main_split();
    color(bottom_color) translate([ ex1/2, 0, 4.6 + ex2]) mirror([1, 0, 0]) main_split();
    color(top_color) translate([0, 0, 8.4 + mid_layer_height + ex5]) raised();

    color("white", alpha = 0.2) union() {
        translate([0, 0, 10.0 + mid_layer_height + ex6]) plate_raised();

        translate([0, 0, 8.4 + ex4]) sound_plate_raised();
        translate([-ex1/2, 0, 6.2 + ex3]) plate_main_split();
        translate([ ex1/2, 0, 6.2 + ex3]) mirror([1, 0, 0]) plate_main_split();

        translate([-ex1/2, 0, 1.6 + ex1]) sound_plate_main_split();
        translate([ ex1/2, 0, 1.6 + ex1]) mirror([1, 0, 0]) sound_plate_main_split();

        base();
    }
}

module sound_channels() {
    module base() {
        linear_extrude(height = 4.59, convexity = 10)
            translate([-254, 127]) import("base.dxf", convexity = 10);
    }
    module raised_outline() {
        linear_extrude(height = 3.8 + mid_layer_height, convexity = 10)
            translate([-254, 127]) import("raised_outline.dxf", convexity = 10);
    }
    module sound_plate_main_split() {
        linear_extrude(height = 3.01, convexity = 10)
            offset(delta = 0.01) translate([-254, 127]) import("sound_plate_main_split.dxf", convexity = 10);
    }
    module main_split() {
        linear_extrude(height = 1.61, convexity = 10)
            offset(delta = 0.01) translate([-254, 127]) import("main_split.dxf", convexity = 10);
    }
    module plate_main_split() {
        linear_extrude(height = 2.21, convexity = 10)
            offset(delta = 0.01) translate([-254, 127]) import("plate_main_split.dxf", convexity = 10);
    }
    module sound_plate_raised() {
        linear_extrude(height = mid_layer_height + 0.01, convexity = 10)
            offset(delta = 0.01) translate([-254, 127]) import("sound_plate_raised.dxf", convexity = 10);
    }
    module raised() {
        linear_extrude(height = 1.61, convexity = 10)
            offset(delta = 0.01) translate([-254, 127]) import("raised.dxf", convexity = 10);
    }

    color("white", alpha = 0.4) render(convexity = 10) difference() {
        union() {
            translate([0, 0, 1.605]) base();
            translate([0, 0, 6.195]) raised_outline();
        }

        translate([0, 0, 1.6]) sound_plate_main_split();
        translate([0, 0, 1.6]) mirror([1, 0, 0]) sound_plate_main_split();

        translate([0, 0, 4.6]) main_split();
        translate([0, 0, 4.6]) mirror([1, 0, 0]) main_split();

        translate([0, 0, 6.2]) plate_main_split();
        translate([0, 0, 6.2]) mirror([1, 0, 0]) plate_main_split();

        translate([0, 0, 8.4]) sound_plate_raised();

        translate([0, 0, 8.4 + mid_layer_height]) raised();
    }
}

cos30 = cos(30);
module half_mantis() {
    hx = 21.5 + $explode/5;
    hy = -hx*cos30;
    dx = 3;
    dy = -dx/cos30;
    raise = 3.8 + mid_layer_height + 3*$explode;
    translate([-4.5*hx-dx/2, -3*hy, 0]) {
        translate([0  *hx, 0*hy   ,     0]) rotate([0, 0,    0]) switch_key($tilt = tilt2);
        translate([1  *hx, 0*hy   ,     0]) rotate([0, 0,  -60]) switch_key($tilt = tilt2);
        translate([2  *hx, 0*hy   ,     0]) rotate([0, 0,  -60]) switch_key($tilt = tilt2);
        translate([3  *hx, 0*hy   ,     0]) rotate([0, 0,  -60]) switch_key($tilt = tilt2);
        translate([3.5*hx, 1*hy   , raise]) rotate([0, 0,  -60]) switch_key($tilt = tilt2);
        translate([4  *hx, 2*hy   , raise]) rotate([0, 0,  -60]) switch_key($tilt = tilt2);

        translate([0.5*hx, 1*hy   ,     0]) rotate([0, 0, -120]) switch_key($tilt = tilt1);
        translate([1.5*hx, 1*hy   ,     0]) rotate([0, 0, -120]) switch_key($tilt = tilt1);
        translate([2.5*hx, 1*hy   ,     0]) rotate([0, 0, -120]) switch_key($tilt = tilt1);
        translate([3  *hx, 2*hy   , raise]) rotate([0, 0, -120]) switch_key($tilt = tilt1);
        translate([3.5*hx, 3*hy   , raise]) rotate([0, 0, -120]) switch_key($tilt = tilt2);

        translate([0  *hx, 2*hy   ,     0]) rotate([0, 0, -180]) switch_key($tilt = tilt2);
        translate([1  *hx, 2*hy   ,     0]) rotate([0, 0, -180]) switch_key($tilt = tilt2);
        translate([2  *hx, 2*hy   ,     0]) rotate([0, 0, -180]) switch_key($tilt = tilt2);
        translate([2.5*hx, 3*hy   , raise]) rotate([0, 0, -180]) switch_key($tilt = tilt2);

        translate([1.5*hx, 3*hy   ,     0]) rotate([0, 0, -180]) switch_key($tilt = tilt2);
    
        translate([2  *hx, 4*hy+dy, raise]) rotate([0, 0,   60]) switch_key($tilt = tilt1);
        translate([3  *hx, 4*hy+dy, raise]) rotate([0, 0,    0]) switch_key($tilt = tilt1);
        translate([4  *hx, 4*hy+dy, raise]) rotate([0, 0,  -60]) switch_key($tilt = tilt1);
    
        translate([3.5*hx, 5*hy+dy,     0]) rotate([0, 0,    0]) switch_key($tilt = tilt1);
    }
}

if (show_switch || show_key) {
    translate([0, 0, 6.2 + 4*$explode]) half_mantis();
    translate([0, 0, 6.2 + 4*$explode]) mirror([1, 0, 0]) half_mantis();
}

if (!show_sound) { // Keyboard
    mantis($fn = 36);
} else { // sound channels (and some other voids)
    sound_channels($fn = 36);
}