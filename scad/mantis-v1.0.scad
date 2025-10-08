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
// Foam or cork
show_foam = true;
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
// Fillet style
fillet_style = 1;      // [0:Flat, 1:Parabolic, 2:Circular]
// Main Edge fillet radius
r_edge_main = 0.5;             // [0.5:0.1:5]
// Raised Edge fillet radius
r_edge_raised = 0.5;           // [0.5:0.1:5]
// Main Corner fillet radius
r_corner_main = 2.5;           // [0.5:0.1:5]
// Raised Corner fillet radius
r_corner_raised = 1.6;         // [0.5:0.1:5]
wall_thickness_main = 2.5;     // [0.5:0.1:5]
wall_thickness_raised = 2.5;   // [0.5:0.1:5]
main_height = 12.5;     // [5:0.1:15]
raised_height = 10;     // [5:0.1:15]
base_thickness = 2.5;   // [0.5:0.1:5]
base_relief_depth = 1;  // [0.5:0.1:2]
deck_thickness = 3.2;   // [0.5:0.1:5]
pcb_thickness = 1.2;    // [0.5:0.1:2]
foam_thickness = 1.0;   // [0.5:0.1:2]
sensor_pcb_thickness = 1.6;// [0.5:0.1:2]
plate_thickness = 1.2;  // [0.5:0.1:2]
main_plate_z = 6.7;     // [1:0.1:15]
main_pcb_z = 4.5;       // [1:0.1:15]
main_switch_z = main_pcb_z + pcb_thickness;
raised_plate_z = 16.7;  // [1:0.1:30]
raised_pcb_z = 14.5;    // [1:0.1:30]
raised_switch_z = raised_pcb_z + pcb_thickness;
trackball_z = 19.5;     // [1:0.1:30]
bump_recess = 1.0;      // [0:0.1:2]
bump_diameter = 7.0;    // [1:0.1:12]
bump_height = 1.5;      // [0:0.1:5]
bearing_size = 2.5;     // [1:0.1:5]
// Horizontal fit tolerance
hfit = 0.1; // [0.01:0.01:0.2]
// Vertical fit tolerance
vfit = 0.01; // [0.01:0.01:0.2]

// Some derived dimensions for the gaskets
gasket_thickness_main = main_height - deck_thickness -
                       (main_plate_z + plate_thickness);
gasket_pad_thickness_main = main_plate_z - gasket_thickness_main -
                            base_thickness;
gasket_thickness_raised = main_height + raised_height - deck_thickness -
                         (raised_plate_z + plate_thickness);
gasket_pad_thickness_raised = raised_plate_z - gasket_thickness_raised -
                              (main_height - deck_thickness + base_thickness);

/* [Mounting points dimensions in mm] */
// Default for M2 threaded insert
bore_diameter = 2.7; // [1.5:0.1:6]
post_diameter = 6.0; // [4:0.1:8]
bolt_diameter = 2.0; // [1:0.1:4]
head_diameter = 4.0; // [2:0.1:8]

/* [Keycaps] */
// RGB LED cutouts
rgb = false;
// Saddle shaped dish
saddle = true;
// Dish diameter
dish_diam = 14;
// Angle of the dish at the rim
slope = 15;
// Tilt angle for home keys
tilt1 = 15;
// Rise of the home keys
rise1 = -0.5;
// Tilt angle for top row keys
tilt2 = 28;
// Rise of the top row keys
rise2 = 1.5;
//rise2 = 2.9;
// Tilt angle for bottom row keys
tilt3 = 15;
// Rise of the top bottom keys
rise3 = -0.5;

/* [Colors] */
key_color = "linen";
trackball_color = "deepskyblue";
plate_color = "darkgreen";
pcb_color = "green";
foam_color = "goldenrod";
mezzanine_color = "orange";
case_color = "chocolate";
base_color = "saddlebrown";
desk_color = "tan";

/* [Hidden] */
hx = 21.5;
hy = 18.62;

dx = 3;
dy = 1.1547 * dx;

kx = 0.25;
ky = 1.1547 * kx;

mcu_size = [17.78, 33.02];
mcu_top = 10*hy/3 + dy/2;
mcu_y = mcu_top - mcu_size.y/2;
forehead_x = (mcu_top - 8*hy/3 + dy/4) * hx / (2*hy/3);

// Fillets and Spacing
f_key = 3.0;
s_key = 0.5;
s_pcb = 0.25;
spacing = 0.5;

// Prevent rendering key in keycap.scad
no_key = true;

trackball_diameter = 34;
trackball_radius = trackball_diameter / 2;
trackball_position = [0, -hy - 3*dy/2, trackball_z];
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

module hex_outline() polygon([
    [    0,  2 * hy/3],
    [ hx/2,  1 * hy/3],
    [ hx/2, -1 * hy/3],
    [    0, -2 * hy/3],
    [-hx/2, -1 * hy/3],
    [-hx/2,  1 * hy/3]
]);
module hex_offset_fillet(o, f)
    offset(r = f, $fa = fa_from_fs(f)) offset(delta = o-f) hex_outline();
module half_hex_outline() polygon([
    [    0,         0],
    [ hx/2,  1 * hy/3],
    [ hx/2, -1 * hy/3],
    [    0, -2 * hy/3],
    [-hx/2, -1 * hy/3],
    [-hx/2,  1 * hy/3]
]);

main_outline_points = [
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
];

// Polyhedron with variable fillets along z
// points: points of a polygon describing the outline in x-y plane
// h: height
// o: offset in x-y plane
// fxy: fillet in x-y plane of the bulk
// f_edge: fillet of the top/bottom edge
// f_corner: fillet of the corners
// f_style: edge/corner fillet style (0: chamfer, 1: parabolic, 2: circular)
// round_bottom: true if bottom side is fillet, false if bottom is flat
module fillet_polyhedron(points, h, o, fxy, f_edge, f_corner,
                         fillet_style, round_bottom=true) {
    assert(f_edge <= f_corner);

    n = len(points);
    m = round(3.1416 / 3 * fxy / $fs);
    p = n * (m + 1);
    ac = tan(60)^2 / (4*f_corner);
    ae = tan(60)^2 / (4*f_edge);
    z1 = fillet_style == 1 ? sqrt(f_corner/ac) : f_corner;
    q = round(z1 * 1.5708 / $fs);
    Q = round_bottom ? 2*q : q;
    //echo(z1, q);

    bottom = at_z(round_bottom ?
        offset_fillet_poly2(points, o-f_edge, fxy+f_edge, 0,
                           fxy-f_edge, f_corner-f_edge, m) :
        offset_fillet_poly(points, o, fxy, fxy, m), 0);
    top = at_z(offset_fillet_poly2(points, o-f_edge, fxy+f_edge, 0,
                                   fxy-f_edge, f_corner-f_edge, m), h);

    bottom_fillet = round_bottom ? [for (i = [1 : q]) each let (
        z = (fillet_style == 2 ? cos(90*i/q) : 1 - i/q) * z1,
        _r = max(0, f_edge - (z1-z)),
        r = fillet_style == 0 ? _r :
            fillet_style == 1 ? ae * _r^2 :
                                f_edge - sqrt(f_edge^2 - _r^2),
        dr = ((fillet_style == 0 ? z :
               fillet_style == 1 ? ac * z^2 :
                                   z1-sqrt(f_corner^2 - z^2))
              - r)
    ) at_z(offset_fillet_poly2(points, o - r, fxy + r, 0,
                               fxy - r, dr, m), z1 - z)] : [];
    top_fillet = [for (i = [q : -1 : 1]) each let (
        z = (fillet_style == 2 ? cos(90*i/q) : 1 - i/q) * z1,
        _r = max(0, f_edge - (z1-z)),
        r = fillet_style == 0 ? _r :
            fillet_style == 1 ? ae * _r^2 :
                                f_edge - sqrt(f_edge^2 - _r^2),
        dr = ((fillet_style == 0 ? z :
               fillet_style == 1 ? ac * z^2 :
                                   z1-sqrt(f_corner^2 - z^2))
              - r)
    ) at_z(offset_fillet_poly2(points, o - r, fxy + r, 0,
                              fxy - r, dr, m), h - z1 + z)];
    points = concat(bottom, bottom_fillet, top_fillet, top);
    bottom_face = [for (i = [p-1 : -1 : 0]) i];
    top_face = [for (i = [p * (1 + Q) : p * (2 + Q) - 1]) i];
    side_faces = [for (i = [0 : Q]) each
        [for (j = [0 : p-1])
            [i*p + j, i*p + (j+1)%p, (i+1)*p + (j+1)%p, (i+1)*p + j]]];
    faces = concat([bottom_face, top_face], side_faces);
    polyhedron(points, faces, convexity=10);
}

module main_outline_template() polygon(main_outline_points);
module main_outline(variant) difference() {
    main_outline_template();
    if (variant == 1) {
        translate([-5.5*hx - dx/2, 3*hy     ]) hex_outline();
        translate([ 5.5*hx + dx/2, 3*hy     ]) hex_outline();
        translate([-4.0*hx - dx/2,         0]) half_hex_outline();
        translate([ 4.0*hx + dx/2,         0]) half_hex_outline();
        translate([-2.0*hx - dx/2,-2*hy - dy]) half_hex_outline();
        translate([ 2.0*hx + dx/2,-2*hy - dy]) half_hex_outline();
    }
}
module main_offset_fillet(o, fo, fi, variant) difference() {
    offset(r     =     fo, $fa = fa_from_fs(fo))
    offset(r     = -fo-fi, $fa = fa_from_fs(fi))
    offset(delta =   o+fi) main_outline(variant);

    if (variant == 1) {
        w = hx + dx/2 - mcu_size.x/2 - spacing + s_pcb;
        d = 2*post_diameter;
        translate([-hx - dx/2 - s_pcb + w/2, mcu_top])
            offset(r     =     fo, $fa = fa_from_fs(fo))
            offset(delta =  -o-fo) square([w, d], center=true);
        translate([ hx + dx/2 + s_pcb - w/2, mcu_top])
            offset(r     =     fo, $fa = fa_from_fs(fo))
            offset(delta =  -o-fo) square([w, d], center=true);
    }
}
module main_extrusion(h, o, fxy, fz, variant=0) {
    if (fz) {
        fa = 90 / round(fz * 1.5708 / $fs);
        translate([0, 0, fz]) minkowski() {
            linear_extrude(h - 2*fz, convexity=10)
                main_offset_fillet(o - fz, fxy - fz, fxy + fz, variant);
            full_sphere(fz, false, $fa = fa);
        }
    } else {
        linear_extrude(h, convexity=10)
            main_offset_fillet(o, fxy, fxy, variant);
    }
}

raised_outline_points = let (
    wx = wall_thickness_raised,
    wy = 1.1547*wx
) [
    [0, -2*hy - dy/2],
  //[-0.5*hx - dx/2 + kx, -5*hy/3 - dy + ky + wy+ky/2],
    [-1.0*hx - dx/2 + wx + 2*kx, -4*hy/3 - dy + ky + wy/2],
  //[-1.0*hx - dx/2 + wx + kx, -4*hy/3 - dy + ky + wy/2+ky/2],
  //[-1.0*hx - dx/2 + kx, -4*hy/3 - dy + ky + wy+ky/2],
  //[-1.0*hx - dx/2 + kx, -4*hy/3 - dy + ky + ky/2],
    //[-1.5*hx - dx/2     , -5*hy/3 - dy + ky],
    //[-1.5*hx - dx/2     , -5*hy/3 - dy],
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
    //[ 1.5*hx + dx/2     , -5*hy/3 - dy],
    //[ 1.5*hx + dx/2     , -5*hy/3 - dy + ky],
  //[ 1.0*hx + dx/2 - kx, -4*hy/3 - dy + ky + ky/2],
  //[ 1.0*hx + dx/2 - kx, -4*hy/3 - dy + ky + wy+ky/2],
  //[ 1.0*hx + dx/2 - wx - kx, -4*hy/3 - dy + ky + wy/2+ky/2],
    [ 1.0*hx + dx/2 - wx - 2*kx, -4*hy/3 - dy + ky + wy/2],
  //[ 0.5*hx + dx/2 - kx, -5*hy/3 - dy + ky + wy+ky/2],
];

raised_outline_points1 = let (
    wx = wall_thickness_raised,
    wy = 1.1547*wx
) [
    [-0.5*hx - dx/2 + kx, -5*hy/3 - dy + ky + wy+ky/2],
  //[-1.0*hx - dx/2 + wx + 2*kx, -4*hy/3 - dy + ky + wy/2],
  //[-1.0*hx - dx/2 + wx + kx, -4*hy/3 - dy + ky + wy/2+ky/2],
    [-1.25*hx - dx/2 + kx, -7*hy/6 - dy + ky + wy+ky/2],
  //[-1.0*hx - dx/2 + kx, -4*hy/3 - dy + ky + ky/2],
    [-1.5*hx - dx/2     , -5*hy/3 - dy + ky + hy/2],
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
    //[ 1.5*hx + dx/2     , -5*hy/3 - dy],
    //[ 1.5*hx + dx/2     , -5*hy/3 - dy + ky],
  //[ 1.0*hx + dx/2 - kx, -4*hy/3 - dy + ky + ky/2],
  //[ 1.0*hx + dx/2 - kx, -4*hy/3 - dy + ky + wy+ky/2],
    [ 1.0*hx + dx/2 - wx - 2*kx, -4*hy/3 - dy + ky + wy/2],
    [ 0.5*hx + dx/2 - kx, -5*hy/3 - dy + ky + wy+ky/2]
];


module raised_outline() polygon(raised_outline_points);
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

module mcu(height, offset)
    translate([0, mcu_y, 0]) linear_extrude(height) offset(r=offset)
        square(mcu_size, center=true);
module display_cable_cutout(height, offset)
    translate([0, mcu_y - mcu_size.y/2, 0]) linear_extrude(height)
        offset(r=offset) square([12-2*offset, 7-2*offset], center=true);

module usb_port_template(o, depth, height=0.6) {
    rotate([90, 0, 0]) linear_extrude(depth) offset(r = o)
        square([6.69, height], center = true);
}

mounting_points_main = [
    [-5.33*hx - dx/2, 8.67*hy/3],
    [ 5.33*hx + dx/2, 8.67*hy/3],
    [-3.67*hx - dx/2,   0*hy/3],
    [ 3.67*hx + dx/2,   0*hy/3],
    [-1.67*hx - dx/2,  -6*hy/3 - dy],
    [ 1.67*hx + dx/2,  -6*hy/3 - dy],
    [-hx - dx/2 + 4, mcu_top + s_pcb - 3],
    [ hx + dx/2 - 4, mcu_top + s_pcb - 3]
];

mounting_points_raised = [
    [-hx - dx/2 + post_diameter/2, -2*hy/3 - dy/2],
    [ hx + dx/2 - post_diameter/2, -2*hy/3 - dy/2]
];

mounting_points_sensor = [
    [-9, 0],
    [ 9, 0]
];

trackball_wall = 2.0;
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
    translate([trackball_position.x, trackball_position.y, -0.01]) union() {
        cylinder(h + 0.02,
                 r = trackball_radius + s_key + trackball_wall + hfit - oi);
        translate([0, 0, h/2 + 0.01])
            cube([2*hx + dx + 2*oo - 2*oi - 2*post_diameter,
                 trackball_diameter, h + 0.02], center = true);
    }
}
//translate([0, 0, 100]) trackball_frame(raised_height, -s_key/2, 0, f_key + s_key);
// Circular cut of the front of the top case-inside to allow pivoting
// installation of the mezzanine and trackball holder with the pivot being
// the rear mounting point for the base plate that the mezzanine ends up
// resting upon. This is created from a rotate-extrusion of the raised
// outline.
module pivot_installation_cut(width, o, fxy) difference() {
    height = raised_height + deck_thickness;
    translate([0, -5*hy/3 - dy, main_height - deck_thickness + height/2 - 0.01])
        cube([width, hy, height], center=true);

    translate([0, mcu_top - post_diameter, main_height - deck_thickness - 0.02])
        rotate([-90, 0, 90]) rotate_extrude(angle=12, convexity=10)
        rotate([0, 0, -90]) translate([0, -mcu_top + 6])
        intersection() {
            raised_offset_fillet(o, fxy, fxy);
            translate([0, -3*hy - dy])
                square([7*hx + dx, 6*hy + dy], center = true);
        }
}
//translate([0, 0, 0]) pivot_installation_cut(7*hx + dx, s_pcb, f_key + s_key);
module case_inside(oh, ov) union() {
    translate([0, 0, base_thickness + ov])
        main_extrusion(main_height-base_thickness-deck_thickness - 2*ov,
                       s_pcb - oh, f_key + s_key - oh, 0, 1);
    difference() {
        translate([0, 0, main_height - deck_thickness - ov - 0.01])
            raised_extrusion(raised_height + 0.01,
                             s_pcb - oh, f_key + s_key - oh, 0);
        translate([hx+dx/2, -5*hy/3 - dy + oh,
                   main_height - deck_thickness - ov - 0.02]) rotate([0, 0, 180])
            cube([2*hx+dx, hy, raised_height + 0.03]);
        translate([0, 0,
                   main_height - deck_thickness + base_thickness + vfit])
            trackball_frame(raised_height, -s_key/2, oh, f_key + s_key);
        width = oh ? 7*hx + dx : 2*hx + dx;
        pivot_installation_cut(width, s_pcb - oh, f_key + s_key - oh);
    }
}
//translate([0, 0, 50]) case_inside(hfit, vfit);

module case_outside() {
    union() {
        fillet_polyhedron(main_outline_points, main_height,
                          s_pcb + wall_thickness_main,
                          f_key + s_key + wall_thickness_main,
                          r_edge_main, r_corner_main, fillet_style);
        translate([0, 0, main_height - 2*r_corner_main]) difference() {
            fillet_polyhedron(raised_outline_points,
                              raised_height + 2*r_corner_main,
                              s_pcb + wall_thickness_raised,
                              f_key + s_key + wall_thickness_raised,
                              r_edge_raised, r_corner_raised, fillet_style,
                    round_bottom=(wall_thickness_main < wall_thickness_raised));
            translate([hx+dx/2, -5*hy/3 - dy, -vfit]) rotate([0, 0, 180])
                cube([2*hx+dx, hy, raised_height + 2*r_corner_main + 2*vfit]);
        }
    }
}
//translate([0, 0, 50]) case_outside();
module base_plate_base(oh, ov) intersection() {
    translate([0, 0, -ov - 0.01])
        main_extrusion(base_thickness + 2*ov + 0.01,
                       s_pcb + wall_thickness_main/2 + oh,
                       f_key + s_key + wall_thickness_main + oh, 0);
    if (!ov)
        case_outside();
}
module main_gasket_pads() intersection() {
    translate([0, 0, base_thickness - vfit])
        linear_extrude(gasket_pad_thickness_main, convexity=10)
        offset(r = f_key + s_key) offset(delta = -f_key - s_key - s_pcb)
        union() {
        translate([-4.0*hx -  dx/2, 4*hy      ]) hex_outline();
        translate([ 4.0*hx +  dx/2, 4*hy      ]) hex_outline();
        translate([-2.0*hx -  dx/2, 4*hy      ]) hex_outline();
        translate([ 2.0*hx +  dx/2, 4*hy      ]) hex_outline();
        translate([-5.5*hx -  dx/2, 1*hy      ]) hex_outline();
        translate([ 5.5*hx +  dx/2, 1*hy      ]) hex_outline();
        translate([-4.0*hx -  dx/2,          0]) hex_outline();
        translate([ 4.0*hx +  dx/2,          0]) hex_outline();
        translate([-2.0*hx -  dx/2, -2*hy - dy]) hex_outline();
        translate([ 2.0*hx +  dx/2, -2*hy - dy]) hex_outline();
    }
    main_extrusion(main_height, s_pcb - hfit, f_key + s_key - hfit, 0,
                   variant=1);
}
bump_positions = [
    [-4.00*hx - dx/2, 11*hy/3     ],
    [ 4.00*hx + dx/2, 11*hy/3     ],
    [-5.25*hx - dx/2,  7*hy/6     ],
    [ 5.25*hx + dx/2,  7*hy/6     ],
    [-2.00*hx - dx/2, -5*hy/3 - dy],
    [ 2.00*hx + dx/2, -5*hy/3 - dy]
];
module base_relief() translate([0, 0, base_thickness - base_relief_depth])
    flat_extrusion("outlines/base_relief.dxf", base_relief_depth+vfit);
module drain_hole() union() {
    radius = 7.5;
    translate(trackball_position - [0, 0, trackball_radius])
        cylinder(h=10, r=radius, center=true);
    translate(trackball_position - [0, 0, trackball_z+vfit])
        cylinder(1, radius+1, radius);
}
module power_switch_cutout() translate([-6/2, mcu_top, -vfit])
    cube([6, 10, main_pcb_z+0.5+vfit]);

module base_plate() difference() {
    ca = render_case ? 0 : case_alpha;
    bc = render_case ? undef : base_color;
    color(bc, alpha=ca) union() {
        base_plate_base(0, 0);
        main_gasket_pads();
    }
    base_relief();
    translate(trackball_position + [0.25, 0.1, -0.3]) rotate([60, 0, 0])
        translate([0, 0, -trackball_radius]) sensor();
    translate(trackball_position + [-0.25, 0.1, -0.3]) rotate([60, 0, 0])
        translate([0, 0, -trackball_radius]) sensor();
    drain_hole();
    power_switch_cutout();
    for (p = mounting_points_main)
        translate([p.x, p.y, 0])
            countersunk_screw(base_thickness, hfit);
    for (p = bump_positions)
        translate(p)
            cylinder(h = bump_recess*2, d = bump_diameter, center = true);
}
module case() union() {
    ca = render_case ? 0 : case_alpha;
    cc = render_case ? undef : case_color;
    difference() {
        color(cc, alpha=ca) case_outside();
        render(convexity=10) union() {
            base_plate_base(hfit, vfit);
            case_inside(0, 0);
            translate([0, 0, main_height - deck_thickness - vfit - 0.01])
                main_key_slots(deck_thickness + vfit + 0.02);
            translate([0, 0, main_height - deck_thickness - vfit - 0.01])
                raised_key_slots(raised_height + deck_thickness + vfit + 0.02);

            translate(trackball_position)
                corr_sphere(trackball_radius + spacing);
            translate([0, 0,
                       main_height + raised_height - deck_thickness - 1])
                mcu(2, 0);

            usb_height = 0.6 + 1.5;
            usb_offset = 1.255 + 2.5;
            w = max(wall_thickness_main, wall_thickness_raised);
            translate([0, mcu_top + s_pcb + w + 0.1,
                       main_height + raised_height - deck_thickness
                       - usb_height/2 - usb_offset])
                usb_port_template(usb_offset, w + 0.2, usb_height);

            power_switch_cutout();

            /* Mounting holes */
            h_main = main_height - base_thickness - deck_thickness;
            for (p = mounting_points_main)
                translate([p.x, p.y, base_thickness - 0.1])
                    cylinder(h = h_main, d = bore_diameter);
            h_raised = raised_height - base_thickness;
            for (p = mounting_points_raised)
                translate([p.x, p.y,
                           main_height - deck_thickness + base_thickness
                           + vfit - 0.1])
                    cylinder(h = h_raised, d = bore_diameter);
        }
    }
}
module bump() union() {
    diameter = bump_diameter - 1.0;
    $fa = fa_from_fs(diameter/2);
    translate([0, 0, -bump_height/2 - 0.01])
        cylinder(h = bump_height/2, d = diameter);
    translate([0, 0, -bump_height/2])
        scale([1, 1, bump_height/diameter])
        rotate([0, 0, 90 + $fa/2]) half_sphere(diameter/2);
}

module main_pcb() color(pcb_color)
    flat_extrusion("outlines/main_pcb.dxf", pcb_thickness);
module main_pcb_foam() color(foam_color)
    translate([0, 0, -foam_thickness - vfit])
    flat_extrusion("outlines/main_pcb_foam.dxf", foam_thickness - 2*vfit);
module raised_pcb() color(pcb_color)
    flat_extrusion("outlines/raised_pcb.dxf", plate_thickness);
module raised_pcb_foam() color(foam_color)
    translate([0, 0, -foam_thickness - vfit])
    flat_extrusion("outlines/raised_pcb_foam.dxf", foam_thickness - 2*vfit);
module main_plate() color(plate_color)
    flat_extrusion("outlines/main_plate.dxf", pcb_thickness);
module main_plate_foam() color(foam_color)
    translate([0, 0, -foam_thickness - vfit])
    flat_extrusion("outlines/main_plate_foam.dxf", foam_thickness - 2*vfit);
module raised_plate() color(plate_color)
    flat_extrusion("outlines/raised_plate.dxf", plate_thickness);
module raised_plate_foam() color(foam_color)
    translate([0, 0, -foam_thickness - vfit])
    flat_extrusion("outlines/raised_plate_foam.dxf", foam_thickness - 2*vfit);

module female_header(height, pin_l, n) {
    pitch = 2.54;
    pin_w = 0.4;
    w = 2.5;
    pad = 0.25;
    color("#303030") difference() {
        translate([-w/2, -pitch/2 - pad, 0])
            cube([w, pitch*n + 2*pad, height]);
        for (i = [0:n-1])
            translate([-0.5, i*pitch - 0.5, 1]) cube([1, 1, height]);
    }
    for (i = [0:n-1])
        translate([-pin_w/2, i*pitch - pin_w/2, -pin_l]) color("gold")
            cube([pin_w, pin_w, pin_l + 0.5]);
}
module male_header(height, pin_l1, pin_l2, n) {
    pitch = 2.54;
    pin_w = 0.64;
    w = 2.5;
    color("#303030") difference() {
        translate([-w/2, -pitch/2, 0]) cube([w, pitch*n, height]);
        for (i = [0:n]) {
            translate([-w, (i-0.5)*pitch, 0])
                rotate([0, 0, 45]) translate([-w/2, -w/2, -0.1])
                cube([w, w, height+0.2]);
            translate([w, (i-0.5)*pitch, 0])
                rotate([0, 0, 45]) translate([-w/2, -w/2, -0.1])
                cube([w, w, height+0.2]);
        }
    }
    for (i = [0:n-1])
        translate([-pin_w/2, i*pitch - pin_w/2, -pin_l1]) color("gold")
            cube([pin_w, pin_w, pin_l1 + height + pin_l2]);
}
module usb_port(depth) union() {
    difference() {
        color("lightgrey") usb_port_template(1.255, 10.5);
        translate([0, 0.1, 0]) usb_port_template(1.155, 10.5);
    }
    color("#303030") translate([0, 0.05, 0]) usb_port_template(0, 10.4);
}

module controller() {
    ex = $explode;
    y0 = -2.54*6;
    translate([-7.62, y0, 0]) female_header(8.39, 3.2, 12);
    translate([ 7.62, y0, 0]) female_header(8.39, 3.2, 12);
    translate([-7.62, y0, 8.4 + 1*ex]) male_header(2.49, 6, 3, 12);
    translate([ 7.62, y0, 8.4 + 1*ex]) male_header(2.49, 6, 3, 12);
    color(pcb_color) translate([-mcu_size.x/2, -mcu_size.y/2, 10.9 + ex])
        cube([mcu_size.x, mcu_size.y, 1.6]);
    translate([0, mcu_size.y/2, 10.9 + ex - 1.6]) usb_port(10.5);
}

module ffc_connector_hirose() {
    color("beige") translate([-4, 0, 0]) cube([8, 2.2, 1.19]);
    color("dimgrey") translate([-6.57/2, -0.5, 0.6]) cube([6.57, 1.5, 0.6]);
    for (i = [0:11])
        color("gold") translate([i*0.5 - 2.75, 0.1, 0]) cube([0.15, 2.4, 0.35]);
}

module ffc_connector_molex() {
    color("beige") translate([-10.7/2, -1.8, 0]) cube([10.7, 4, 1.8]);
    color("dimgrey") translate([-9.1/2, -2.6, 1]) cube([9.1, 4, 0.9]);
    for (i = [0:11])
        color("gold") translate([i*0.5 - 2.75, -1.4, 0]) cube([0.15, 4, 0.35]);
}

module ffc_connector() ffc_connector_molex();

module pcm12_switch() {
    color("silver") translate([-6.7/2, -2.6/2, 0]) cube([6.7, 2.6, 1.4]);
    color("dimgrey") translate([-1.3, 2.58/2, 0.4]) cube([1.3, 1.5, 0.8]);
    color("silver") translate([-7.7/2, -2.6/2, 0]) cube([7.7, 0.66, 0.15]);
    color("silver") translate([-7.7/2, 2.6/2-0.66, 0]) cube([7.7, 0.66, 0.15]);
    color("gold") translate([-0.75-0.2, -2.6/2-0.9, 0]) cube([0.4, 1, 0.15]);
    color("gold") translate([-2.25-0.2, -2.6/2-0.9, 0]) cube([0.4, 1, 0.15]);
    color("gold") translate([2.25-0.2, -2.6/2-0.9, 0]) cube([0.4, 1, 0.15]);
}

module main_pcb_assembly() {
    main_pcb();
    translate([0, hy, 0]) rotate([0, 180, 0]) ffc_connector();
    translate([-17, 4*hy/3, 0]) rotate([0, 180, 0]) ffc_connector();
    translate([0, mcu_top - 2.6/2, 0]) rotate([0, 180, 0])
        pcm12_switch();
    translate([0, mcu_y, pcb_thickness]) controller();
}

module raised_pcb_assembly() {
    raised_pcb();
    translate([0, hy-9, 0]) rotate([0, 180, 180]) ffc_connector();
}

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
    color("dimgray") translate([-5.05, -5.48, -9.05])
        cube([10.1, 16.2, 2.91], center=false);

    // PCB
    color(pcb_color) render(convexity = 4) difference() {
        translate([0, 0, -9.05+1.65])
            flat_extrusion("outlines/sensor_pcb.dxf", sensor_pcb_thickness);
        for(p = mounting_points_sensor)
            translate([p.x, p.y, -9.05]) cylinder(5, d=bolt_diameter + 0.2);
    }

    // Connector
    translate([-17, -1.7, -9.05 + 1.65]) rotate([0, 180, 180]) ffc_connector();

    // Lens
    color("#ffffff", 0.3) lens(0);
}

module raised_gasket_pads()
    translate([0, 0, main_height - deck_thickness + base_thickness - vfit])
        intersection() {
            linear_extrude(gasket_pad_thickness_raised, convexity=10)
                offset(r = f_key + s_key) offset(delta = -f_key - s_key - s_pcb)
                union() {
                    translate([-2*hx -  dx/2, -2*hy - dy]) hex_outline();
                    translate([ 2*hx +  dx/2, -2*hy - dy]) hex_outline();
                    translate([0, 3*hy + hy/6])
                        square([2*hx + dx, hy], center=true);
                }
            pivot = [0, mcu_top - post_diameter, -deck_thickness];
            radius = deck_thickness + gasket_pad_thickness_raised;
            angle = 12;
            translate(pivot) rotate([0, 90, 0])
                linear_extrude(6*hx, center=true) offset(r = radius)
                polygon([[0, -6*hy], [0, 0], hy*[sin(angle), cos(angle)]]);
        }
module mezzanine() {
    ca = render_case ? 0 : case_alpha;
    mc = render_case ? undef : mezzanine_color;
    difference() {
        color(mc, alpha=ca) union() {
            translate([0, 0, main_height - deck_thickness])
                raised_extrusion(base_thickness,
                                 s_pcb, f_key + s_key, 0);
            raised_gasket_pads();
        }
        translate([0, 0, main_height - deck_thickness - 0.01])
            mcu(base_thickness + gasket_pad_thickness_raised + 0.02, spacing);
        translate([0, 0, main_height - deck_thickness - 0.01])
            display_cable_cutout(base_thickness +
                                 gasket_pad_thickness_raised + 0.02,
                                 spacing);

        for(p = mounting_points_raised)
            translate([p.x, p.y, main_height - deck_thickness])
                countersunk_screw(base_thickness, hfit);
    }
}

module bearings(size, offset, what=0) {
    translate(trackball_position) rotate([4, 0, 0]) {
        for (phi = [0:120:240])
            rotate([-45, 0, phi]) translate([0, 0, -trackball_radius - size/2])
                if (what == 0)
                    color("ghostwhite") corr_sphere(size/2 + offset);
                else if (what == 1)
                    cylinder(h = size/2, r = size/2 + offset);
                else if (what == 2)
                    translate([0, 0, -10]) cylinder(h = 10, r = size/2 + offset);
                else if (what == 3)
                    translate([0, 0, -0.01])
                        cylinder(h = size/2 - spacing + 0.01,
                                 r1 = size/2 + offset + (size/2 - spacing),
                                 r2 = size/2 + offset);
                else if (what == 4)
                    cylinder(h = size,
                             r1 = size/2 + offset,
                             r2 = size/2 + offset + size);
                else if (what == 5)
                    translate([-size/4, -size/2 - offset, 0])
                        cube([size/2, size + 2*offset, size/2]);
    }
}

module trackball_holder() intersection() {
    ca = render_case ? 0 : case_alpha;
    mc = render_case ? undef : mezzanine_color;
    wall = trackball_wall;
    difference() {
        union() {
            difference() {
                union() {
                    color(mc, alpha=ca)
                        translate(trackball_position)
                        corr_sphere(trackball_radius + spacing + wall);
                    mezzanine();
                    color(mc, alpha=ca) {
                        translate(trackball_position) rotate([60, 0, 0])
                            translate([0, 0, -trackball_radius - 2.4 + vfit])
                            cylinder(2.5, 5, 5);
                        bearings(bearing_size, 4.5 - bearing_size/2);
                    }
                }
                w = 2*hx + dx;
                h = 25;
                translate(trackball_position) rotate([60, 0, 0])
                    translate([-w/2, -10, -trackball_radius - h])
                    cube([w, 30, h - 2.4 + vfit], center=false);
            }
            color(mc, alpha=ca)
                translate(trackball_position) rotate([60, 0, 0])
                    for (p = mounting_points_sensor)
                        translate([p.x, p.y,
                                   -trackball_radius - 9.05+1.65 + 1.6 + vfit])
                            cylinder(trackball_radius/2 + 9.05-1.65 - 1.6,
                                     d = post_diameter);
        }
        union() {
            translate(trackball_position)
                corr_sphere(trackball_radius + spacing);
            drain_hole();
            difference() {
                bearings(bearing_size, 1.5, what=4);
                bearings(bearing_size, 0.25, what=3);
            }
            bearings(bearing_size, 0.01);
            bearings(bearing_size, -0.05, what=1);
            bearings(bearing_size, -0.5, what=2);
            bearings(bearing_size, 1.4, what=5);

            translate(trackball_position) rotate([60, 0, 0]) {
                translate([0, 0, -trackball_radius-2.5])
                    cylinder(2.5, 2.5, 1.5, center=false);
                for (p = mounting_points_sensor)
                    translate([p.x, p.y, -trackball_radius - 9.05+1.65 + 1.6])
                        cylinder(5, d = bore_diameter);
            }
            main_key_slots(main_height + raised_height);
        }
    }
    render(convexity=10) case_inside(hfit, vfit);
}

module key_profile(x) {
    $fa = $fs*2;
    $rgb = rgb;
    $slope = slope;
    $dish_diam = dish_diam;
    $explode=$explode/3;

    if (x == 0) {
        switch_key($tilt=tilt1, $rise=rise1, $saddle=saddle);
    } else if (x == 1) {
        switch_key($tilt=tilt2, $rise=rise2, $saddle=saddle);
    } else if (x == 2) {
        switch_key($tilt=tilt3, $rise=rise3, $saddle=saddle);
    }
}

module keyboard() {
    ex = $explode;

    if (show_pcb) {
        translate([0, 0, main_pcb_z + 2*ex]) main_pcb_assembly();
        translate([0, 0, raised_pcb_z + 7*ex]) raised_pcb_assembly();
        if (show_foam) {
            translate([0, 0, main_pcb_z + 1*ex]) main_pcb_foam();
            translate([0, 0, raised_pcb_z + 6*ex]) raised_pcb_foam();
        }
    }

    if (show_plate) {
        translate([0, 0, main_plate_z + 4*ex]) main_plate();
        translate([0, 0, raised_plate_z + 9*ex]) raised_plate();
        if (show_foam) {
            translate([0, 0, main_plate_z + 3*ex]) main_plate_foam();
            translate([0, 0, raised_plate_z + 8*ex]) raised_plate_foam();
        }
    }

    if (show_sensor) {
        translate(trackball_position + [0, 0, 3*ex]) rotate([60, 0, 0])
            translate([0, 0, -trackball_radius]) sensor();
    }

    if (show_trackball) {
        color(trackball_color) translate(trackball_position + [0, 0, 11*ex])
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
        [4.0, 2, -60, 1], [4.5, 1,-120, 1],
        [3.5, 1,-120, 0], [4.0, 0,-120, 1],
        [3.0, 0, 180, 2]
        ];
        raised_thumbs =   [[2.5, -1, 60, 0], [3.5, -1, 0, 0]];
        main_thumbs =     [[4.0, -2,  0, 1]];
        union() {
            main_z = main_switch_z + 7*ex;
            raised_z = raised_switch_z + 11*ex;
            hx = hx + ex/3;
            hy = hy + ex/3;
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

    if (show_bearing) translate([0, 0,  5.5*ex]) bearings(bearing_size, 0);

    if (show_mezzanine) {
        pivot = [0, mcu_top - post_diameter, main_height - deck_thickness];
        angle = [12 - abs($t-0.5)*24, 0, 0];
        translate([0, 0, 5*ex] + pivot) rotate(angle) translate(-pivot) {
            if (render_case)
                color(mezzanine_color, alpha=case_alpha)
                    render(convexity=8) trackball_holder();
            else
                color(alpha=case_alpha) trackball_holder();
        }
    }

    if (show_base) {
        if (render_case)
            color(base_color, alpha=case_alpha) render(convexity=8)
                base_plate();
        else
            color(alpha=case_alpha) base_plate();

        for (p = bump_positions)
            color("white", alpha=0.2)
                translate([p.x, p.y, bump_recess - 0.5*ex]) bump();
    }

    if (show_case) {
        if (render_case)
            translate([0, 0, 10.2*ex]) color(case_color, alpha=case_alpha)
                render(convexity=10) case();
        else
            translate([0, 0, 10.2*ex]) color(alpha=case_alpha) case();
    }
}

if (show_desk) {
    elevation = max(0, bump_height - bump_recess);
    color(desk_color) rotate([0, 0, -5]) translate([-300, -100, -20 - elevation])
        cube([600, 350, 20]);
    // Approximate shadow to give a sense of the distance from the desk surface:
    // 1. Core shadow slightly smaller than the outline
    o = (show_case ? s_pcb + wall_thickness_main : -main_pcb_z) - elevation;
    f = (show_case ? f_key + s_key + wall_thickness_main :
                     f_key + s_pcb + main_pcb_z) + elevation;
    if (show_case || show_pcb || show_plate) {
        color("black", alpha=show_case ? 0.5 : 0.3)
            translate([0, 0, -elevation - 0.49]) main_offset_fillet(o, f, f);
    }
    // 2. Partial shadow of the main body, raised part and trackball
    shadow_width = 2.5 + elevation/4;
    color("black", alpha=0.2) translate([0, 0, -elevation - 0.48])
            render(convexity=10) union() {
        o = (show_case ? s_pcb + wall_thickness_main : 0) + shadow_width;
        f = (show_case ? f_key + s_key + wall_thickness_main : f_key + s_pcb) + shadow_width;
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

translate([0, 0, $explode]) keyboard();