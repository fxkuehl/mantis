// Including it with use <> prevents global variables set in the GUI
// from propagating into keycap.scad. Include it first so that I can
// override parameters below.
include <keycap.scad>

/* [Render] */
// Angular resolution in degrees
$fa = 4; // [1:8]
$explode = 0;
show_trackball = true;
show_switch = true;
show_key = true;
// Switch plates
show_plate = true;
// Switch PCBs
show_pcb = true;
// Trackball sensor
show_sensor = true;
show_bearing = true;
show_mezzanine = true;
show_case = true;
// Pre-render the case
render_case = true;
case_alpha = 1.0; // [0.1:0.1:1.0]
show_desk = true;

/* [Design sizes in mm] */
main_height = 13;
raised_height = 10;
base_thickness = 2.5;
deck_thickness = 3;
pcb_thickness = 1.2;
sensor_pcb_thickness = 1.6;
plate_thickness = 1.2;
main_plate_z = 7.4;
main_pcb_z = 5.2;
main_switch_z = main_pcb_z + pcb_thickness;
raised_plate_z = 17.4;
raised_pcb_z = 15.2;
raised_switch_z = raised_pcb_z + pcb_thickness;
bearing_size = 2.5;
// Edge radius
r_edge = 2.73;

/* [Keycaps] */
// RGB LED cutouts
$rgb = false;
// Tilt angle for home keys
tilt1 = 15;
// Rise of the home keys
rise1 = -0.5;
// Tilt angle for top row keys
tilt2 = 28;
// Rise of the top row keys
rise2 = 2.9;
// Tilt angle for bottom row keys
tilt3 = 15;
// Rise of the top bottom keys
rise3 = -0.5;

/* [Colors] */
trackball_color = "deepskyblue";
plate_color = "#404040";
pcb_color = "green";
mezzanine_color = "orange";
case_color = "chocolate";
desk_color = "tan";

/* [Hidden] */
hx = 21.5;
hy = 18.62;

dx = 3.27;
dy = 1.1547 * dx;

mcu_y = 10*hy/3 + dy/2 - 33.02/2;

spacing = 0.54;
// Prevent rendering key in keycap.scad
no_key = true;

trackball_diameter = 34;
trackball_radius = trackball_diameter / 2;
trackball_position = [0, -hy - 3*dy/2, trackball_radius + 4];
//trackball_diameter = 24;
//trackball_position = [0, -hy - 2*dy/2, trackball_diameter/2 + 10];

// Segment size in mm of curves on the case
$fs = $fa/2;

use <utils.scad>

module flat_extrusion(outline, height, offset=0) {
    translate([-254, 127, 0])
        linear_extrude(height, convexity=10)
            offset(r=-offset) offset(r=2*offset) import(outline);
}
module rounded_extrusion(outline, height, radius) {
    fa = 90 / round(radius * 1.5708 / $fs);
    translate([-254, 127, radius]) minkowski() {
        linear_extrude(height=height - 2*radius, convexity=10)
            offset(delta = -min(3, radius)) import(outline);
        full_sphere(radius, false, $fa = fa);
    }
}

module case_inside(offset) {
    render(convexity=10) {
        translate([0, 0, base_thickness + offset/2])
            flat_extrusion("outlines/main_padded.dxf",
                           main_height-base_thickness-deck_thickness - offset,
                           -offset);
        translate([0, 0, main_height-deck_thickness-0.1 + offset/2])
            flat_extrusion("outlines/raised_padded.dxf",
                           raised_height+0.1 - offset, -offset);
    }
}

module case() difference() {
    color(case_color, alpha=case_alpha) render(convexity=10) union() {
        rounded_extrusion("outlines/main_external.dxf",
                          main_height, r_edge);
            rounded_extrusion("outlines/raised_external.dxf",
                              main_height+raised_height, r_edge);
    }
    render(convexity=10) {
        case_inside(0);
        translate([0, 0, base_thickness])
            flat_extrusion("outlines/main_key_slots.dxf", main_height);
        translate([0, 0, main_height-deck_thickness-0.1])
            flat_extrusion("outlines/raised_key_slots.dxf",
                           raised_height+deck_thickness+0.2);

        translate(trackball_position)
            corr_sphere(trackball_radius + spacing);
    }
}

module main_pcb() color(pcb_color)
    flat_extrusion("outlines/main_pcb.dxf", pcb_thickness);
module raised_pcb() color(pcb_color)
    flat_extrusion("outlines/raised_pcb.dxf", plate_thickness);
module main_plate() color(plate_color)
    flat_extrusion("outlines/main_plate.dxf", pcb_thickness);
module raised_plate() color(plate_color)
    flat_extrusion("outlines/raised_plate.dxf", plate_thickness);

module mcu(height, offset)
    translate([0, mcu_y, 0]) linear_extrude(height) offset(r=offset)
        square([17.78, 33.02], center=true);

module lens(offset) {
    translate([-8.25/2 - offset, -5.48 - offset, -5.95 - 2.4])
        cube([8.25 + 2*offset, 12.9 + 2*offset, 5.95 + offset], center=false);
}

/* Place holder for PMW3610 sensor and lens in the x/y-plane, facing up,
 * centered at its optical center. Also a place holder for the PCB shaped
 * to fit into the the tight space with enough room to place components
 * and hopefully route traces.
 */
module sensor() {
    // Sensor package
    color("dimgray") translate([-5.45, -5.48, -9.05])
        cube([10.9, 16.2, 2.91], center=false);

    // PCB
    color(pcb_color) render(convexity = 4) difference() {
        union() {
            v = hx + dx - 2*spacing;
            translate([-v/2, -5.48 - 1, -9.05 + 1.65])
                cube([v, 18, sensor_pcb_thickness], center=false);
            w = 2*hx + dx - 2*spacing;
            translate([-w/2, -5.48 - 1, -9.05 + 1.65])
                cube([w, 10, sensor_pcb_thickness], center=false);
        }

        translate([-8.9/2, -5.48, -8.55 + 1.65])
            cube([8.9, 15.2, 1.7], center=false);
    }

    // Lens
    color("#ffffff", 0.3) lens(0);
}

module mezzanine(offset) {
    difference() {
        translate([0, 0, main_height - deck_thickness])
            flat_extrusion("outlines/raised_padded.dxf",
                           base_thickness, -offset);
        translate([0, 0, base_thickness])
            flat_extrusion("outlines/main_key_slots.dxf", main_height);
        translate([0, 0, main_height - deck_thickness - 0.1])
            mcu(base_thickness + 0.2, spacing);
    }
}

module bearings(size, offset, cylinder=false) {
    color("ghostwhite") translate(trackball_position) rotate([20, 0, 0]) {
        for (phi = [0:120:240])
            rotate([-60, 0, phi]) translate([0, 0, -trackball_radius - size/2])
                if (cylinder)
                    cylinder(size/2, size/2+offset, size/2+offset);
                else
                    corr_sphere(size/2 + offset);
    }
}

module trackball_holder() {
    wall = 2.0;
    difference() {
        intersection() {
            difference() {
                color(mezzanine_color) union() {
                    translate(trackball_position)
                        corr_sphere(trackball_radius + spacing + wall);
                    mezzanine(0.1);
                    translate(trackball_position) rotate([60, 0, 0])
                        translate([0, 0, -trackball_radius-wall*2])
                        cylinder(wall*2, 5, 5);
                        bearings(bearing_size, 4);
                }
                translate(trackball_position)
                    corr_sphere(trackball_radius + spacing);
            }
            case_inside(0.1);
        }
        translate(trackball_position) rotate([60, 0, 0])
            translate([0, 0, -trackball_radius]) union() {
            w = 2*hx + dx;
            translate([-w/2, -10, -10])
                cube([w, 20, 10 - 2.4 + 0.05], center=false);
            translate([0, 0, -2.5]) cylinder(2.5, 2.5, 1.5, center=false);
        }
        bearings(bearing_size, 0.1);
        bearings(bearing_size, -0.05, cylinder=true);
    }
}

if (show_desk) {
    color(desk_color) translate([-300, -100, -22]) cube([600, 350, 20]);
    // Approximate shadow to give a sense of the distance from the desk surface:
    // 1. Core shadow slightly smaller than the outline
    if (show_case) {
        color("black", alpha=0.5) translate([0, 0, -2.99])
            flat_extrusion("outlines/main_external.dxf", 1, -2);
    } else if (show_pcb || show_plate) {
        color("black", alpha=0.3) translate([0, 0, -2.99])
            flat_extrusion("outlines/main_padded.dxf", 1, -4);
    }
    // 2. Partial shadow of the main body, raised part and trackball
    shadow_width = 3;
    color("black", alpha=0.2) render(convexity=10) union() {
        if (show_case) {
            translate([shadow_width, -shadow_width, - 2.98])
                flat_extrusion("outlines/main_external.dxf", 1, shadow_width);
            translate([shadow_width*1.67, -shadow_width*1.67, -2.98])
                flat_extrusion("outlines/raised_external.dxf", 1, shadow_width);
        } else if (show_pcb || show_plate) {
            translate([shadow_width, -shadow_width, - 2.98])
                flat_extrusion("outlines/main_padded.dxf", 1, shadow_width);
            translate([shadow_width*1.67, -shadow_width*1.67, -2.98])
                flat_extrusion("outlines/raised_padded.dxf", 1, shadow_width);
        }
        if (show_trackball) {
            translate([shadow_width*3, -shadow_width*3, -2.98])
                linear_extrude(1) translate(trackball_position)
                circle(trackball_radius + shadow_width);
        }
    }
}

if (show_trackball) {
    color(trackball_color) translate(trackball_position) rotate([30, 0, 180])
        corr_sphere(trackball_radius);
}

if (show_pcb) {
    translate([0, 0, main_pcb_z]) main_pcb();
    translate([0, 0, raised_pcb_z]) raised_pcb();
}

if (show_plate) {
    translate([0, 0, main_plate_z]) main_plate();
    translate([0, 0, raised_plate_z]) raised_plate();
}

if (show_sensor) {
    translate(trackball_position) rotate([60, 0, 0])
        translate([0, 0, -trackball_radius]) sensor();
}

module key_profile(x) {
    if (x == 0) {
        switch_key($tilt=tilt1, $rise=rise1);
    } else if (x == 1) {
        switch_key($tilt=tilt2, $rise=rise2);
    } else if (x == 2) {
        switch_key($tilt=tilt3, $rise=rise3);
    }
}

if (show_key || show_switch) {
    main_fingers = [
        [0.5, 3,   0, 0], [1.5, 3, -60, 1], [2.5, 3, -60, 1], [3.5, 3, -60, 1],
        [0.0, 2, 120, 0], [1.0, 2,-120, 0], [2.0, 2,-120, 0], [3.0, 2,-120, 0],
                          [0.5, 1, 180, 2], [1.5, 1, 180, 2], [2.5, 1, 180, 2],
                                                              [2.0, 0, 180, 1]
    ];
    raised_fingers = [
        [4.0, 2, -60, 1], [4.5, 1, -60, 1],
        [3.5, 1,-120, 0], [4.0, 0,-120, 0],
        [3.0, 0, 180, 2]
    ];
    raised_thumbs =   [[2.5, -1, 60, 0], [3.5, -1, 0, 0]];
    main_thumbs =     [[4.0, -2,  0, 1]];
    union() {
        for (k = main_fingers) {
            translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy, main_switch_z])
                rotate([0, 0, k[2]]) key_profile(k[3]);
            translate([5*hx + dx/2 - k[0]*hx, k[1]*hy, main_switch_z])
                rotate([0, 0, -k[2]]) key_profile(k[3]);
        }
        for (k = main_thumbs) {
            translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy - dy, main_switch_z])
                rotate([0, 0, k[2]]) key_profile(k[3]);
            translate([5*hx + dx/2 - k[0]*hx, k[1]*hy - dy, main_switch_z])
                rotate([0, 0, -k[2]]) key_profile(k[3]);
        }
        for (k = raised_fingers) {
            translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy, raised_switch_z])
                rotate([0, 0, k[2]]) key_profile(k[3]);
            translate([5*hx + dx/2 - k[0]*hx, k[1]*hy, raised_switch_z])
                rotate([0, 0, -k[2]]) key_profile(k[3]);
        }
        for (k = raised_thumbs) {
            translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy - dy, raised_switch_z])
                rotate([0, 0, k[2]]) key_profile(k[3]);
            translate([5*hx + dx/2 - k[0]*hx, k[1]*hy - dy, raised_switch_z])
                rotate([0, 0, -k[2]]) key_profile(k[3]);
        }
    }
}

if (show_bearing) bearings(bearing_size, 0);

if (show_mezzanine) {
    if (render_case)
        color(mezzanine_color, alpha=case_alpha) render(convexity=8)
            trackball_holder();
    else
        trackball_holder();
}

if (show_case) {
    if (render_case)
        color(case_color, alpha=case_alpha) render(convexity=10) case();
    else
        color(alpha=case_alpha) case();
}
