// Including it with use <> prevents global variables set in the GUI
// from propagating into keycap.scad. Include it first so that I can
// override parameters below.
include <keycap.scad>

/* [Quality] */
// Angular resolution of trackball and keycap surfaces
$fa = 6;
// Segment size in mm of curves on the case
$fs = 1.5;

/* [Render] */
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
show_case = true;
// Pre-render the case
render_case = true;
case_alpha = 0.5;
show_desk = true;

/* [Design sizes in mm] */
main_height = 13;
raised_height = 10;
base_thickness = 3;
deck_thickness = 3;
pcb_thickness = 1.2;
plate_thickness = 1.2;
main_plate_z = 7.4;
main_pcb_z = 5.2;
main_switch_z = main_pcb_z + pcb_thickness;
raised_plate_z = 17.4;
raised_pcb_z = 15.2;
raised_switch_z = raised_pcb_z + pcb_thickness;
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
case_color = "chocolate";
desk_color = "tan";

/* [Hidden] */
hx = 21.5;
hy = 18.62;

dx = 3.27;
dy = 1.1547 * dx;

spacing = 0.54;
// Prevent rendering key in keycap.scad
no_key = true;

trackball_diameter = 34;
trackball_position = [0, -hy - 3*dy/2, trackball_diameter/2 + 4];
//trackball_diameter = 24;
//trackball_position = [0, -hy - 2*dy/2, trackball_diameter/2 + 10];

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
            offset(delta = -radius) import(outline);
        full_sphere(radius, $fa = fa);
    }
}

module case() difference() {
    color(case_color, alpha=case_alpha) render(convexity=10) union() {
        rounded_extrusion("outlines/main_external.dxf",
                          main_height, r_edge);
            difference(convexity=20) {
                rounded_extrusion("outlines/raised_external.dxf",
                                  main_height+raised_height, r_edge);
                translate([0, -2*hy - 3*dy/2, main_height + raised_height/2])
                    cube(size=[2*hx, hy, raised_height+6], center=true);
            }
    }
    render(convexity=10) {
        translate([0, 0, base_thickness])
            flat_extrusion("outlines/main_padded.dxf",
                           main_height-base_thickness-deck_thickness);
        difference() {
            translate([0, 0, main_height-deck_thickness-0.1])
                flat_extrusion("outlines/raised_padded.dxf",
                               raised_height+0.1);
            translate([0, -hy - dy,
                       main_height+(raised_height-deck_thickness)/2])
                cube(size=[2*hx+dx-spacing, 2*hx,
                           raised_height+deck_thickness+1], center=true);
        }
        translate([0, 0, base_thickness])
            flat_extrusion("outlines/main_key_slots.dxf", main_height);
        translate([0, 0, main_height-deck_thickness-0.1])
            flat_extrusion("outlines/raised_key_slots.dxf",
                           raised_height+deck_thickness+0.2);

        fa = 360 / ceil(3.1416 * trackball_diameter / $fs);
        translate(trackball_position)
            full_sphere(trackball_diameter / 2.0 + spacing,
                        $fa=fa);
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

/* Place holder for PMW3610 sensor and lens in the x/y-plane, facing up,
 * centered at its optical center. Also a place holder for the PCB shaped
 * to fit into the the tight space with enough room to place components
 * and hopefully route traces.
 */
module sensor() {
    // Sensor package
    translate([-5.45, -5.48, -9.05])
        cube([10.9, 16.2, 2.91], center=false);

    // PCB
    difference() {
        union() {
            color(pcb_color) translate([-24/2, -5.48 - 1, -9.05 + 1.65])
                cube([24, 18, 1.6], center=false);
            color(pcb_color) translate([-50/2, -5.48 - 1, -9.05 + 1.65])
                cube([50, 10, 1.6], center=false);
        }

        translate([-8.9/2, -5.48, -8.55 + 1.65])
            cube([8.9, 15.2, 1.7], center=false);
    }

    // Lens
    color("#ffffff", 0.3) translate([-8.25/2, -5.48, -5.95 - 2.4])
        cube([8.25, 12.9, 5.95], center=false);
}

if (show_desk) {
    color(desk_color) translate([-300, -100, -22]) cube([600, 350, 20]);
    // Approximate shadow to give a sense of the distance from the desk surface:
    // 1. Core shadow slightly smaller than the outline
    color("black", alpha=0.5) translate([0, 0, -2.99])
        flat_extrusion("outlines/main_external.dxf", 1, -2);
    // 2. Partial shadow of the main body, raised part and trackball
    shadow_width = 3;
    color("black", alpha=0.2) render(convexity=10) union() {
        translate([shadow_width, -shadow_width, - 2.98])
            flat_extrusion("outlines/main_external.dxf", 1, shadow_width);
        translate([shadow_width*1.67, -shadow_width*1.67, -2.98])
            flat_extrusion("outlines/raised_external.dxf", 1, shadow_width);
        translate([shadow_width*3, -shadow_width*3, -2.98])
            linear_extrude(1) translate(trackball_position)
            circle(d=trackball_diameter + 2*shadow_width);
    }
}

if (show_trackball) {
    color(trackball_color) translate(trackball_position) rotate([-30, 0, 0])
        full_sphere(trackball_diameter / 2.0);
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
    translate(trackball_position)
        rotate([60, 0, 0])
        translate([0, 0, -trackball_diameter/2]) sensor();
}

if (show_key || show_switch) {
    key_profiles = [[tilt1, rise1], [tilt2, rise2], [tilt3, rise3]];
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
        for (k = main_fingers) let (p = key_profiles[k[3]]) {
            translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy, main_switch_z])
                rotate([0, 0, k[2]])
                switch_key($tilt = p[0], $rise = p[1]);
            translate([5*hx + dx/2 - k[0]*hx, k[1]*hy, main_switch_z])
                rotate([0, 0, -k[2]])
                switch_key($tilt = p[0], $rise = p[1]);
        }
        for (k = main_thumbs) let (p = key_profiles[k[3]]) {
            translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy - dy, main_switch_z])
                rotate([0, 0, k[2]])
                switch_key($tilt = p[0], $rise = p[1]);
            translate([5*hx + dx/2 - k[0]*hx, k[1]*hy - dy, main_switch_z])
                rotate([0, 0, -k[2]])
                switch_key($tilt = p[0], $rise = p[1]);
        }
        for (k = raised_fingers) let (p = key_profiles[k[3]]) {
            translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy, raised_switch_z])
                rotate([0, 0, k[2]])
                switch_key($tilt = p[0], $rise = p[1]);
            translate([5*hx + dx/2 - k[0]*hx, k[1]*hy, raised_switch_z])
                rotate([0, 0, -k[2]])
                switch_key($tilt = p[0], $rise = p[1]);
        }
        for (k = raised_thumbs) let (p = key_profiles[k[3]]) {
            translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy - dy, raised_switch_z])
                rotate([0, 0, k[2]])
                switch_key($tilt = p[0], $rise = p[1]);
            translate([5*hx + dx/2 - k[0]*hx, k[1]*hy - dy, raised_switch_z])
                rotate([0, 0, -k[2]])
                switch_key($tilt = p[0], $rise = p[1]);
        }
    }
}

if (show_case) {
    if (render_case)
        color(case_color, alpha=case_alpha) render(convexity=10) case();
    else
        color(alpha=case_alpha) case();
}
