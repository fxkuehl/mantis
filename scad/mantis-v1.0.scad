// Including it with use <> prevents global variables set in the GUI
// from propagating into keycap.scad. Include it first so that I can
// override parameters below.
include <keycap.scad>

/* [Render] */
// Resolution in mm
$fs = 2; // [0.5:0.5:3]
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
show_base = true;
// Pre-render the case
render_case = true;
case_alpha = 1.0; // [0.1:0.1:1.0]
show_desk = true;

/* [Design dimensions in mm] */
main_height = 13;       // [5:0.1:15]
raised_height = 10;     // [5:0.1:15]
base_thickness = 2.5;   // [0.5:0.1:5]
deck_thickness = 3;     // [0.5:0.1:5]
wall_thickness = 2;     // [0.5:0.1:5]
// Edge fillet radius
r_edge = 2;             // [0.5:0.1:5]
pcb_thickness = 1.2;    // [0.5:0.1:2]
sensor_pcb_thickness = 1.6;// [0.5:0.1:2]
plate_thickness = 1.2;  // [0.5:0.1:2]
main_plate_z = 7.4;     // [1:0.1:15]
main_pcb_z = 5.2;       // [1:0.1:15]
main_switch_z = main_pcb_z + pcb_thickness;
raised_plate_z = 17.4;  // [1:0.1:30]
raised_pcb_z = 15.2;    // [1:0.1:30]
raised_switch_z = raised_pcb_z + pcb_thickness;
bump_height = 1;        // [0.5:0.1:5]
bearing_size = 2.5;     // [1:0.1:5]

/* [Mounting points dimensions in mm] */
// Default for M2 threaded insert
bore_diameter = 2.7; // [1.5:0.1:6]
post_diameter = 5.7; // [4:0.1:8]
bolt_diameter = 2.0; // [1:0.1:4]
head_diameter = 4.0; // [2:0.1:8]

/* [Keycaps] */
// RGB LED cutouts
rgb = false;
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
key_color = "linen";
trackball_color = "deepskyblue";
plate_color = "darkgreen";
pcb_color = "green";
mezzanine_color = "orange";
case_color = "chocolate";
base_color = "saddlebrown";
desk_color = "tan";

/* [Hidden] */
hx = 21.5;
hy = 18.62;

dx = 2.54;
dy = 1.1547 * dx;

kx = 0.27;
ky = 1.1547 * kx;

mcu_size = [17.78, 33.02];
mcu_top = 10*hy/3 + dy/2;
mcu_y = mcu_top - mcu_size.y/2;
forehead_x = (mcu_top - 8*hy/3 + dy/4) * hx / (2*hy/3);

// Fillets and Spacing
f_key = 3.0;
s_key = 0.54;
s_pcb = 0.27;
spacing = 0.54;

// Prevent rendering key in keycap.scad
no_key = true;

trackball_diameter = 34;
trackball_radius = trackball_diameter / 2;
trackball_position = [0, -hy - 3*dy/2, trackball_radius + 4];
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
            offset(delta = -min(3, radius)) import(outline);
        full_sphere(radius, false, $fa = fa);
    }
}

module main_outline() {
    polygon([
    [             0, -6*hy/3 - dy + dy/4],  // mouth
    [    -hx - dx/2, -8*hy/3 - dy],         // left mandible
    [-3.0*hx - dx/2, -4*hy/3 - dy],
    [-3.0*hx - dx/2, -2*hy/3],
    [-5.5*hx - dx/2,  3*hy/3],              // left temple
    [-5.5*hx - dx/2,  9*hy/3],
    [-4.0*hx - dx/2, 12*hy/3],              // left ear
    [-3.0*hx - dx/2, 10*hy/3],
    [-2.0*hx - dx/2, 12*hy/3],              // left horn
    [-forehead_x, mcu_top],                 // forehead
    [ forehead_x, mcu_top],
    [ 2.0*hx + dx/2, 12*hy/3],              // right horn
    [ 3.0*hx + dx/2, 10*hy/3],
    [ 4.0*hx + dx/2, 12*hy/3],              // right ear
    [ 5.5*hx + dx/2,  9*hy/3],              // right temple
    [ 5.5*hx + dx/2,  3*hy/3],
    [ 3.0*hx + dx/2, -2*hy/3],              // right mandible
    [ 3.0*hx + dx/2, -4*hy/3 - dy],
    [     hx + dx/2, -8*hy/3 - dy]
    ]);
}
module main_offset_fillet(o, fo, fi)
    offset(r     =     fo, $fa = fa_from_fs(fo))
    offset(r     = -fo-fi, $fa = fa_from_fs(fi))
    offset(delta =   o+fi) main_outline();
module main_extrusion(h, o, fxy, fz) {
    if (fz) {
        fa = 90 / round(fz * 1.5708 / $fs);
        translate([0, 0, fz]) minkowski() {
            linear_extrude(h - 2*fz, convexity=10)
                main_offset_fillet(o - fz, fxy - fz, fxy + fz);
            full_sphere(fz, false, $fa = fa);
        }
    } else {
        linear_extrude(h, convexity=10)
            main_offset_fillet(o, fxy, fxy);
    }
}

module raised_outline() {
    wx = wall_thickness;
    wy = 1.1547*wx;
    polygon([
    [-0.5*hx - dx/2 + kx, -5*hy/3 - dy + ky + wy+ky/2],
  //[-1.0*hx - dx/2 + wx + kx, -4*hy/3 - dy + ky + wy/2+ky/2],
  [-1.0*hx - dx/2 + kx, -4*hy/3 - dy + ky + wy+ky/2],
  [-1.0*hx - dx/2 + kx, -4*hy/3 - dy + ky + ky/2],
    [-1.5*hx - dx/2     , -5*hy/3 - dy + ky],
    [-1.5*hx - dx/2     , -5*hy/3 - dy],
    [-2.0*hx - dx/2     , -6*hy/3 - dy],
    [-3.0*hx - dx/2     , -4*hy/3 - dy],
    [-3.0*hx - dx/2     , -2*hy/3 - dy],
    [-2.5*hx - dx/2 + kx,   -hy/3 - dy + ky],
    [-2.5*hx - dx/2 + kx,    hy/3 - ky/2],
    [-2.0*hx - dx/2 + kx,  2*hy/3 - ky/2],
    [-2.0*hx - dx/2 + kx,  4*hy/3 - ky/2],
    [-1.5*hx - dx/2 + kx,  5*hy/3 - ky/2],
    [-1.5*hx - dx/2 + kx,  7*hy/3 - ky/2],
    [-1.0*hx - dx/2 + kx,  8*hy/3 - ky/2],
    [-1.0*hx - dx/2 + kx, mcu_top],
    [ 1.0*hx + dx/2 - kx, mcu_top],
    [ 1.0*hx + dx/2 - kx,  8*hy/3 - ky/2],
    [ 1.5*hx + dx/2 - kx,  7*hy/3 - ky/2],
    [ 1.5*hx + dx/2 - kx,  5*hy/3 - ky/2],
    [ 2.0*hx + dx/2 - kx,  4*hy/3 - ky/2],
    [ 2.0*hx + dx/2 - kx,  2*hy/3 - ky/2],
    [ 2.5*hx + dx/2 - kx,    hy/3 - ky/2],
    [ 2.5*hx + dx/2 - kx,   -hy/3 - dy + ky],
    [ 3.0*hx + dx/2     , -2*hy/3 - dy],
    [ 3.0*hx + dx/2     , -4*hy/3 - dy],
    [ 2.0*hx + dx/2     , -6*hy/3 - dy],
    [ 1.5*hx + dx/2     , -5*hy/3 - dy],
    [ 1.5*hx + dx/2     , -5*hy/3 - dy + ky],
  [ 1.0*hx + dx/2 - kx, -4*hy/3 - dy + ky + ky/2],
  [ 1.0*hx + dx/2 - kx, -4*hy/3 - dy + ky + wy+ky/2],
  //[ 1.0*hx + dx/2 - wx - kx, -4*hy/3 - dy + ky + wy/2+ky/2],
    [ 0.5*hx + dx/2 - kx, -5*hy/3 - dy + ky + wy+ky/2]
    ]);
}
module raised_offset_fillet(o, fo, fi)
    offset(r     =     fo, $fa = fa_from_fs(fo))
    offset(r     = -fo-fi, $fa = fa_from_fs(fi))
    offset(delta =   o+fi) raised_outline();
module raised_extrusion(h, o, fxy, fz) {
    if (fz) {
        fa = 90 / round(fz * 1.5708 / $fs);
        minkowski() {
            linear_extrude(h - fz, convexity=10)
                raised_offset_fillet(o - fz, fxy - fz, fxy + fz);
            rotate([0, 180, 0]) half_sphere(fz, false, $fa = fa);
        }
    } else {
        linear_extrude(h, convexity=10)
            raised_offset_fillet(o, fxy, fxy);
    }
}

module hex_outline() {
    polygon([
    [    0,  2 * hy/3],
    [ hx/2,  1 * hy/3],
    [ hx/2, -1 * hy/3],
    [    0, -2 * hy/3],
    [-hx/2, -1 * hy/3],
    [-hx/2,  1 * hy/3]
    ]);
}
module hex_offset_fillet(o, f)
    offset(r = f, $fa = fa_from_fs(f)) offset(delta = o-f) hex_outline();
module main_key_slots(h) {
    o = s_key/2 - 0.01;

    module left() translate([-dx/2, 0]) union() {
        for(i = [-4.5 : 1: -1.5])
            translate([i*hx, 3*hy]) offset(delta = o) hex_outline();
        for(i = [-5.0 : 1: -2.0])
            translate([i*hx, 2*hy]) offset(delta = o) hex_outline();
        for(i = [-4.5 : 1: -2.5])
            translate([i*hx,   hy]) offset(delta = o) hex_outline();
        translate([-3*hx,          0]) offset(delta = o) hex_outline();
        translate([  -hx, -2*hy - dy]) offset(delta = o) hex_outline();
    }

    linear_extrude(h, convexity=10) {
        f = f_key + s_key;
        offset(r =    f, $fa = fa_from_fs(f))
        offset(r = -2*f, $fa = fa_from_fs(f)) offset(delta = f) {
            left();
            scale([-1, 1]) left();
        }
    }
}
module raised_key_slots(h) {
    o = s_key/2 - 0.01;

    module left_fingers() translate([-dx/2, 0]) union() {
        translate([-1.5*hx, 3*hy]) offset(delta = o) hex_outline();
        for(i = [-2.0 : 1: -1.0])
            translate([i*hx, 2*hy]) offset(delta = o) hex_outline();
        for(i = [-2.5 : 1: -0.5])
            translate([i*hx,   hy]) offset(delta = o) hex_outline();
        for(i = [-3.0 : 1: -1.0])
            translate([i*hx,    0]) offset(delta = o) hex_outline();
    }
    module left_thumb() translate([-dx/2, -dy]) union() {
        for(i = [-2.5 : 1: -1.5])
            translate([i*hx,  -hy]) offset(delta = o) hex_outline();
        translate([  -hx, -2*hy]) offset(delta = o) hex_outline();
    }

    linear_extrude(h, convexity=10) {
        f = f_key + s_key;

        // offset different key clusters separately to prevent them from merging
        offset(r =    f, $fa = fa_from_fs(f))
        offset(r = -2*f, $fa = fa_from_fs(f)) offset(delta = f) left_fingers();
        offset(r =    f, $fa = fa_from_fs(f))
        offset(r = -2*f, $fa = fa_from_fs(f)) offset(delta = f) left_thumb();

        offset(r =    f, $fa = fa_from_fs(f))
        offset(r = -2*f, $fa = fa_from_fs(f)) offset(delta = f)
            scale([-1, 1]) left_fingers();
        offset(r =    f, $fa = fa_from_fs(f))
        offset(r = -2*f, $fa = fa_from_fs(f)) offset(delta = f)
            scale([-1, 1]) left_thumb();
    }
}
/*
color("red") translate([0, 0, main_height]) main_offset_fillet(0, 3.27, 3.27);
color("lime") translate([0, 0, main_height+raised_height])
    raised_offset_fillet(0, 0, 0);
*/

module gasket_pads(height) {
}

module mounting_post(height) difference() {
    cylinder(height, d = post_diameter);
    translate([0, 0, -0.01]) cylinder(height + 0.02, d = bore_diameter);
}

module countersunk_screw(length, offset) {
    head_radius = head_diameter/2 + 2*offset*sqrt(2);
    bolt_radius = bolt_diameter/2 + offset;
    $fn = round(360/fa_from_fs(head_radius));
    union() {
        translate([0, 0, -offset])
            cylinder(h = head_radius, r1 = head_radius, r2 = 0);
        translate([0, 0, 0.01])
            cylinder(h = length + offset - 0.01, r = bolt_radius);
        if (offset)
            translate([0, 0, -length])
                cylinder(h = length - offset + 0.01, r = head_radius);
    }
}

mounting_points_main = [
    [-5.33*hx - dx/2, 8.67*hy/3],
    [ 5.33*hx + dx/2, 8.67*hy/3],
    [-3.67*hx - dx/2,   0*hy/3],
    [ 3.67*hx + dx/2,   0*hy/3],
    [-1.67*hx - dx/2,  -6*hy/3 - dy],
    [ 1.67*hx + dx/2,  -6*hy/3 - dy]
];

mounting_points_raised = [
    [-hx - dx/2 + s_key/2 + post_diameter/2, -2*hy/3 - dy/2],
    [ hx + dx/2 - s_key/2 - post_diameter/2, -2*hy/3 - dy/2]
];

mounting_posts_rear = [
    [-mcu_size.x/2 - post_diameter/2 - spacing,
     mcu_top + s_pcb - post_diameter/2,
     main_pcb_z + pcb_thickness + 0.1],
    [mcu_size.x/2 + post_diameter/2 + spacing,
     mcu_top + s_pcb - post_diameter/2,
     main_pcb_z + pcb_thickness + 0.1],

    [-hx - dx/2 + post_diameter/2, mcu_top + s_pcb - post_diameter/2,
     main_height - deck_thickness + base_thickness + 0.1],
    [ hx + dx/2 - post_diameter/2, mcu_top + s_pcb - post_diameter/2,
     main_height - deck_thickness + base_thickness + 0.1]
];

module hex_pad(h, o) {
    linear_extrude(h) hex_offset_fillet(o - s_key/2, o + f_key + s_key);
}
module tri_pad(h, o) {
    linear_extrude(h) difference() {
        hex_offset_fillet(o - s_key/2, o + f_key + s_key);
        translate([0, 2*hy/3 - 0.01]) hex_offset_fillet(o + s_key/2, 0);
    }
}
module trackball_frame(h, oo, oi, f) difference() {
    linear_extrude(h) offset(r = f) offset(delta = oo - f) polygon([
        [  -hx/2 - dx/2, -5 * hy/3 - dy],
        [  -hx   - dx/2, -4 * hy/3 - dy],
        [  -hx   - dx/2, -2 * hy/3],
        [-3*hx/4 - dx/2, -1.5*hy/3],
        [ 3*hx/4 + dx/2, -1.5*hy/3],
        [   hx/2 + dx/2, -1 * hy/3],
        [   hx   + dx/2, -2 * hy/3],
        [   hx   + dx/2, -4 * hy/3 - dy],
        [   hx/2 + dx/2, -5 * hy/3 - dy]
    ]);
    translate([trackball_position.x, trackball_position.y, -0.01]) {
        cylinder(h + 0.02,
                 r = trackball_radius + s_key + wall_thickness + 0.1 - oi);
        translate([0, 0, h/2 + 0.01])
            cube([2*hx + dx + 2*oo - 2*oi - 2*post_diameter,
                  trackball_diameter, h + 0.02], center = true);
    }
}
module case_inside(offset) difference() {
    union() {
        translate([0, 0, base_thickness + offset/2])
            main_extrusion(main_height-base_thickness-deck_thickness - offset,
                           s_pcb - offset, f_key + s_key - offset, 0);
        translate([0, 0, main_height - deck_thickness - offset/2 - 0.01])
            raised_extrusion(raised_height + 0.01,
                             s_pcb - offset, f_key + s_key - offset, 0);
    }
    translate([0, 0,
               main_height - deck_thickness + base_thickness + 0.11 - offset])
        trackball_frame(raised_height, -s_key/2, offset, f_key + s_key);

    // Base plate mounting points
    // TODO: Integrate them into a separate outline to get nicer fillets
    mh = main_height - deck_thickness - base_thickness + 0.02;
    translate([0, 0, base_thickness - 0.01]) {
        translate([-5.5*hx - dx/2, 3*hy     ]) hex_pad(mh, offset);
        translate([ 5.5*hx + dx/2, 3*hy     ]) hex_pad(mh, offset);
        translate([-4.0*hx - dx/2,         0]) tri_pad(mh, offset);
        translate([ 4.0*hx + dx/2,         0]) tri_pad(mh, offset);
        translate([-2.0*hx - dx/2,-2*hy - dy]) tri_pad(mh, offset);
        translate([ 2.0*hx + dx/2,-2*hy - dy]) tri_pad(mh, offset);
    }
}
//translate([0, 0, 50]) case_inside(0);
module case_outside() {
    union() {
        main_extrusion(main_height,
                       s_pcb + wall_thickness,
                       f_key + s_key + wall_thickness, r_edge);
        translate([0, 0, main_height - r_edge])
            raised_extrusion(raised_height + r_edge,
                             s_pcb + wall_thickness,
                             f_key + s_key + wall_thickness, r_edge);
    }
}
module base_plate_base(offset)
    translate([0, 0, -offset])
        main_extrusion(base_thickness + 2*offset,
                       s_pcb + wall_thickness/2 + offset,
                       f_key + s_key + wall_thickness/2 + offset, 0);

module base_plate() difference() {
    union() {
        color(base_color, alpha=case_alpha) base_plate_base(0);
        intersection() {
            color(base_color, alpha=case_alpha) union() {
                for(i = [0:1])
                    translate([mounting_posts_rear[i].x,
                               mounting_posts_rear[i].y, 0.01])
                        cylinder(h = main_pcb_z - 0.1,
                                 d = post_diameter);
            }
            translate([0, 0, -0.01])
                main_extrusion(main_height, s_pcb - 0.1, f_key + s_key - 0.1, 0);
        }
    }
    for(i = [0:1])
        translate([mounting_posts_rear[i].x, mounting_posts_rear[i].y,
                   main_pcb_z - base_thickness])
            countersunk_screw(2*base_thickness + 0.1, 0.1);
    for (p = mounting_points_main)
        translate([p.x, p.y, 0])
            countersunk_screw(base_thickness + 0.1, 0.1);
}
module case() union() {
    difference() {
        color(case_color, alpha=case_alpha) case_outside();
        render(convexity=10) union() {
            base_plate_base(0.1);
            case_inside(0);
            translate([0, 0, main_height - deck_thickness - 0.01])
                main_key_slots(deck_thickness + 0.02);
            translate([0, 0, main_height - deck_thickness - 0.01])
                raised_key_slots(raised_height + deck_thickness + 0.02);

            translate(trackball_position)
                corr_sphere(trackball_radius + spacing);

            /* Mounting holes */
            h_main = main_height - base_thickness - deck_thickness;
            for (p = mounting_points_main)
                translate([p.x, p.y, base_thickness - 0.1])
                    cylinder(h = h_main, d = bore_diameter);
            h_raised = raised_height - base_thickness;
            for (p = mounting_points_raised)
                translate([p.x, p.y,
                           main_height - deck_thickness + base_thickness - 0.1])
                    cylinder(h = h_raised, d = bore_diameter);
        }
    }
    for (p = mounting_posts_rear)
        translate([p.x, p.y, p.z])
           mounting_post(main_height + raised_height - deck_thickness - p.z + 0.01);
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
        square(mcu_size, center=true);

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
        color(mezzanine_color, alpha=case_alpha)
            translate([0, 0, main_height - deck_thickness])
            raised_extrusion(base_thickness,
                             s_pcb - offset, f_key + s_key - offset, 0);
        translate([0, 0, main_height - deck_thickness - 0.01])
            main_key_slots(base_thickness + 0.02);
        translate([0, 0, main_height - deck_thickness - 0.01])
            mcu(base_thickness + 0.02, spacing);

        for(i = [0:1]) translate(mounting_posts_rear[i])
            cube([post_diameter + 2*s_pcb, post_diameter + 2*s_pcb,
                  main_height + raised_height], center = true);
        for(i = [2:3])
            translate([mounting_posts_rear[i].x, mounting_posts_rear[i].y,
                       main_height - deck_thickness - 0.01])
                countersunk_screw(base_thickness + 0.1, 0.1);
        for(p = mounting_points_raised)
            translate([p.x, p.y, main_height - deck_thickness])
                countersunk_screw(base_thickness + 0.1, 0.1);
    }
}

module bearings(size, offset, cylinder=false) {
    color("ghostwhite") translate(trackball_position) rotate([12, 0, 0]) {
        for (phi = [0:120:240])
            rotate([-50, 0, phi]) translate([0, 0, -trackball_radius - size/2])
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
            union() {
                color(mezzanine_color, alpha=case_alpha)
                    translate(trackball_position)
                    corr_sphere(trackball_radius + spacing + wall);
                mezzanine(0.1);
                color(mezzanine_color, alpha=case_alpha)
                    translate(trackball_position) rotate([60, 0, 0])
                    translate([0, 0, -trackball_radius-wall*2])
                    cylinder(wall*2, 5, 5);
                color(mezzanine_color, alpha=case_alpha)
                    bearings(bearing_size, 3.5);
            }
            render(convexity=10) case_inside(0.09);
        }
        translate(trackball_position) rotate([60, 0, 0])
            translate([0, 0, -trackball_radius]) union() {
            w = 2*hx + dx;
            translate([-w/2, -10, -10])
                cube([w, 20, 10 - 2.4 + 0.05], center=false);
            translate([0, 0, -2.5]) cylinder(2.5, 2.5, 1.5, center=false);
        }
        union() {
            translate(trackball_position)
                corr_sphere(trackball_radius + spacing);
            bearings(bearing_size, 0.1);
            bearings(bearing_size, -0.05, cylinder=true);
        }
    }
}

module key_profile(x) {
    $fa = $fs*2;
    $rgb = rgb;

    if (x == 0) {
        switch_key($tilt=tilt1, $rise=rise1);
    } else if (x == 1) {
        switch_key($tilt=tilt2, $rise=rise2);
    } else if (x == 2) {
        switch_key($tilt=tilt3, $rise=rise3);
    }
}

module keyboard() {
    ex = $explode;

    if (show_pcb) {
        translate([0, 0, main_pcb_z + 1*ex]) main_pcb();
        translate([0, 0, raised_pcb_z + 4*ex]) raised_pcb();
    }

    if (show_plate) {
        translate([0, 0, main_plate_z + 2*ex]) main_plate();
        translate([0, 0, raised_plate_z + 4.8*ex]) raised_plate();
    }

    if (show_sensor) {
        translate(trackball_position + [0, 0, 2*ex]) rotate([60, 0, 0])
            translate([0, 0, -trackball_radius]) sensor();
    }

    if (show_trackball) {
        color(trackball_color) translate(trackball_position + [0, 0, 7*ex])
            rotate([30, 0, 180]) corr_sphere(trackball_radius);
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
            main_z = main_switch_z + 4*ex;
            raised_z = raised_switch_z + 7*ex;
            hx = hx + ex/5;
            hy = hy + ex/5;
            for (k = main_fingers) {
                translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy, main_z])
                    rotate([0, 0, k[2]]) key_profile(k[3]);
                translate([5*hx + dx/2 - k[0]*hx, k[1]*hy, main_z])
                    rotate([0, 0, -k[2]]) key_profile(k[3]);
            }
            for (k = main_thumbs) {
                translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy - dy, main_z])
                    rotate([0, 0, k[2]]) key_profile(k[3]);
                translate([5*hx + dx/2 - k[0]*hx, k[1]*hy - dy, main_z])
                    rotate([0, 0, -k[2]]) key_profile(k[3]);
            }
            for (k = raised_fingers) {
                translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy, raised_z])
                    rotate([0, 0, k[2]]) key_profile(k[3]);
                translate([5*hx + dx/2 - k[0]*hx, k[1]*hy, raised_z])
                    rotate([0, 0, -k[2]]) key_profile(k[3]);
            }
            for (k = raised_thumbs) {
                translate([-5*hx -dx/2 + k[0]*hx, k[1]*hy - dy, raised_z])
                    rotate([0, 0, k[2]]) key_profile(k[3]);
                translate([5*hx + dx/2 - k[0]*hx, k[1]*hy - dy, raised_z])
                    rotate([0, 0, -k[2]]) key_profile(k[3]);
            }
        }
    }

    if (show_bearing) translate([0, 0,  6.8*ex]) bearings(bearing_size, 0);

    if (show_mezzanine) {
        if (render_case)
            translate([0, 0, 3*ex]) color(mezzanine_color, alpha=case_alpha)
                render(convexity=8) trackball_holder();
        else
            translate([0, 0, 3*ex]) trackball_holder();
    }

    if (show_base) {
        if (render_case)
            color(base_color, alpha=case_alpha) render(convexity=8)
                base_plate();
        else
            base_plate();
    }

    if (show_case) {
        if (render_case)
            translate([0, 0, 6*ex]) color(case_color, alpha=case_alpha)
                render(convexity=10) case();
        else
            translate([0, 0, 6*ex]) color(alpha=case_alpha) case();
    }
}

if (show_desk) {
    color(desk_color) rotate([0, 0, -5]) translate([-300, -100, -20 - bump_height])
        cube([600, 350, 20]);
    // Approximate shadow to give a sense of the distance from the desk surface:
    // 1. Core shadow slightly smaller than the outline
    o = (show_case ? s_pcb + wall_thickness : 0) - bump_height;
    f = (show_case ? f_key + s_key + wall_thickness : f_key + s_pcb) - bump_height;
    if (show_case) {
        color("black", alpha=0.5) translate([0, 0, -bump_height - 0.49])
            main_offset_fillet(s_pcb + wall_thickness - bump_height,
                               f_key + s_key + wall_thickness + bump_height,
                               f_key + s_key + wall_thickness + bump_height);
    } else if (show_pcb || show_plate) {
        color("black", alpha=0.3) translate([0, 0, -bump_height - 0.49])
            main_offset_fillet(-main_pcb_z - bump_height,
                               f_key + s_pcb + main_pcb_z + bump_height,
                               f_key + s_pcb + main_pcb_z + bump_height);
    }
    // 2. Partial shadow of the main body, raised part and trackball
    shadow_width = 2.5 + bump_height/4;
    color("black", alpha=0.2) translate([0, 0, -bump_height - 0.48])
            render(convexity=10) union() {
        o = (show_case ? s_pcb + wall_thickness : 0) + shadow_width;
        f = (show_case ? f_key + s_key + wall_thickness : f_key + s_pcb) + shadow_width;
        if (show_case || show_pcb || show_plate) {
            translate([shadow_width, -shadow_width, 0])
                main_offset_fillet(o, f, f);
            translate([shadow_width * 1.67, -shadow_width * 1.67, 0])
                raised_offset_fillet(o, f, f);
        }
        if (show_trackball) {
            translate([shadow_width*3, -shadow_width*3, 0])
                translate(trackball_position)
                circle(trackball_radius + shadow_width);
        }
    }
}

keyboard();