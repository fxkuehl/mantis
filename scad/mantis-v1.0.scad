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
show_main_plate = true;
show_main_pcb = true;
show_raised_plate = true;
show_raised_pcb = true;
// Foam or cork
show_foam = true;
// nice!view display
show_display = true;
// Trackball sensor
show_sensor = true;
show_mezzanine = true;
show_case = true;
show_base = true;
// Pre-render the case
render_case = true;
case_alpha = 1.0; // [0.1:0.1:1.0]
// Show miscelaneous hardware (screws, bearings, gaskets)
show_misc = true;
show_desk = true;
fast_shadow = true;
shadow_softness = 0; // [0:6]
shadow_spread = 0.1; // [0.05:0.05:0.5]

/* [Design dimensions in mm] */
// Skirts around raised keys
has_skirts = true;
// Whether to include a display
has_display = true;
display_bump_height = 2; // [0:0.5:5]
// Fillet style
fillet_style = 1;      // [0:Flat, 1:Root, 2:Circular, 3:Parabolic]
// Main Edge fillet radius
r_edge_main = 0.5;             // [0.5:0.1:5]
// Raised Edge fillet radius
r_edge_raised = 0.5;           // [0.5:0.1:5]
// Main Corner fillet radius
r_corner_main = 2.5;           // [0.5:0.1:5]
// Raised Corner fillet radius
r_corner_raised = 1.5;         // [0.5:0.1:5]
wall_thickness_main = 2.5;     // [0.5:0.1:5]
wall_thickness_raised = 2.0;   // [0.5:0.1:5]
main_height = 12.5;     // [5:0.1:15]
raised_height = 10;     // [5:0.1:15]
base_thickness = 2.5;   // [0.5:0.1:5]
base_relief_depth = 1;  // [0.5:0.1:2]
deck_thickness = 2.6;   // [0.5:0.1:5]
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
flat_head_diameter = 3.5; // [2:0.1:8]
flat_head_thickness = 0.5; // [0.1:0.1:2]
bolt_length = 5.0; // [3:1:10]

gasket_length = 13; // [1:1:20]
gasket_width = 4; // [1:1:20]

/* [Keycaps] */
// Switch type
switch_type = 1; // [1: Choc v1, 2: Choc v2]
// Switch color scheme
switch_colors = 6; // [0: Red, 1: Blue, 2: Brown, 3: Pro Red, 4: Pink, 5: Robin, 6: Sunset, 7: Twilight, 8: Nocturnal, 9: Sunrise, 10: Bokeh]
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
rise1 = -0.5; // [-0.5:0.1:4]
// Tilt angle for top row keys
tilt2 = 28;
// Rise of the top row keys
rise2 = 2.0; // [-0.5:0.1:4]
//rise2 = 2.9;
// Tilt angle for bottom row keys
tilt3 = 28;
// Rise of the top bottom keys
rise3 = -0.5; // [-0.5:0.1:4]

/* [Colors] */
key_color = "linen";
key_color2 = "tan";
trackball_color = "deepskyblue";
plate_color = "darkgreen";
pcb_color = "green";
foam_color = "goldenrod";
mezzanine_color = "orange";
case_color = "chocolate";
base_color = "saddlebrown";
desk_color = "wheat";

/* [Hidden] */
hx = 21.5;
hy = 18.62;

dx = 3;
dy = 1.1547 * dx;

kx = 0.25;
ky = 1.1547 * kx;

mcu_size = [17.78, 33.02];
mcu_top = 10*hy/3 + 4;
mcu_y = mcu_top - mcu_size.y/2;
forehead_x = (mcu_top - 8*hy/3 + dy/4) * hx / (2*hy/3);

// Mezzanine thickness that results in equal space between main and raised
// base and deck
mezzanine_thickness = raised_height + deck_thickness + base_thickness - main_height;

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

// Display 1.9mm thick + 0.1mm tolerance, 1mm thick frame around it = 3mm
display_position = [0, mcu_top-mcu_size.y - 2.6 + 18,
                    main_height+raised_height+display_bump_height-3];

use <utils.scad>

module flat_extrusion(outline, height, offset=0) {
    translate([-254, 127, 0])
        linear_extrude(height, convexity=10)
            offset(r=-offset) offset(r=2*offset) import(outline);
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
module main_extrusion(h, o, fxy, variant=0) {
    linear_extrude(h, convexity=10)
        main_offset_fillet(o, fxy, fxy, variant);
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
module raised_extrusion(h, o, fxy) {
    linear_extrude(h, convexity=10)
        raised_offset_fillet(o, fxy, fxy);
}

display_bump_points = [
    [(hx + dx)/2, mcu_top + s_pcb + s_key/2 + wall_thickness_raised],
    [(hx + dx)/2, 5*hy/3],
    [0, 4*hy/3 - dy/4],
    [-(hx + dx)/2, 5*hy/3],
    [-(hx + dx)/2, mcu_top + s_pcb + s_key/2 + wall_thickness_raised]
];
//translate([0, 0, 30]) polygon(display_bump_points);

module main_key_slots(height, skirt=false) {
    z = raised_height/2.5 - 1.2 + 2*wall_thickness_raised;
    o = s_key/2 - 0.01;
    fi = f_key + s_key;
    fe = wall_thickness_raised + s_key/2 + 0.01;
    fo = fi + fe - s_key/2;
    // Use corner fillet to increase outside radius at the top to match
    // inside fillet radius of the top deck's edge. Calculate the difference
    // how much the radius needs to move inward.
    x1 = fo*(1/cos(30) - 1);
    x2 = fi*(1/cos(30) - 1);
    fc = fe + x1-x2;
    h = has_skirts && skirt ? height+z-fc : height;

    points1 = [
                                   [ 7*hx/2 + dx/2, -1*hy/3],
        // Inner zig-zag edge
        [ 6*hx/2 + dx/2, -2*hy/3], [ 5*hx/2 + dx/2, -1*hy/3],
        [ 5*hx/2 + dx/2,  1*hy/3], [ 4*hx/2 + dx/2,  2*hy/3],
        [ 4*hx/2 + dx/2,  4*hy/3], [ 3*hx/2 + dx/2,  5*hy/3],
        [ 3*hx/2 + dx/2,  7*hy/3], [ 2*hx/2 + dx/2,  8*hy/3],
        [ 2*hx/2 + dx/2, 10*hy/3], [ 3*hx/2 + dx/2, 11*hy/3],
        // Rest of the body
        [ 4*hx/2 + dx/2, 10*hy/3], [ 5*hx/2 + dx/2, 11*hy/3],
        [ 6*hx/2 + dx/2, 10*hy/3], [ 7*hx/2 + dx/2, 11*hy/3],
        [ 8*hx/2 + dx/2, 10*hy/3], [ 9*hx/2 + dx/2, 11*hy/3],
        [10*hx/2 + dx/2, 10*hy/3], [10*hx/2 + dx/2,  8*hy/3],
        [11*hx/2 + dx/2,  7*hy/3], [11*hx/2 + dx/2,  5*hy/3],
        [10*hx/2 + dx/2,  4*hy/3], [10*hx/2 + dx/2,  2*hy/3],
        [ 9*hx/2 + dx/2,  1*hy/3], [ 8*hx/2 + dx/2,  2*hy/3],
        [ 7*hx/2 + dx/2,  1*hy/3]
    ];
    points2 = [
        [ 1*hx/2 + dx/2, -5*hy/3 - dy], [ 2*hx/2 + dx/2, -4*hy/3 - dy],
        [ 3*hx/2 + dx/2, -5*hy/3 - dy], [ 3*hx/2 + dx/2, -7*hy/3 - dy],
        [ 2*hx/2 + dx/2, -8*hy/3 - dy], [ 1*hx/2 + dx/2, -7*hy/3 - dy]
    ];
    module right() {
        fillet_polyhedron(points1, h-0.001, o, fi, fi, fe, fc, 7, false, false);
        fillet_polyhedron(points2, h-0.001, o, fi, fi, fe, fc, 7, false, false);
        if (has_skirts && skirt) translate([0, 0, h-0.011]) {
            fillet_polyhedron(slice(points1, [0:10]), fc+0.011, 0.01,
                              fi, fo, fe, fc, 7, false, true);
            fillet_polyhedron(points2, fc+0.011, 0.01,
                              fi, fo, fe, fc, 7, false, true);
        }
    }
    right();
    scale([-1, 1]) right();
}
//translate([0, 0, main_height - deck_thickness]) main_key_slots(deck_thickness, true);

module raised_key_slots(h) {
    o = s_key/2 - 0.01;

    module left_fingers() translate([-dx/2, 0]) union() {
        if (!has_skirts)
            translate([-1.5*hx, 3*hy]) offset(delta = o) hex_outline();
        for(i = [(has_skirts ? -1.0 : -2.0) : 1: -1.0])
            translate([i*hx, 2*hy]) offset(delta = o) hex_outline();
        for(i = [(has_skirts ? -1.5 : -2.5) : 1: -0.5])
            translate([i*hx,   hy]) offset(delta = o) hex_outline();
        for(i = [(has_skirts ? -2.0 : -3.0) : 1: -1.0])
            translate([i*hx,    0]) offset(delta = o) hex_outline();
    }
    module left_thumb() translate([-dx/2, -dy]) union() {
        for(i = [-2.5 : 1: -1.5])
            translate([i*hx,  -hy]) offset(delta = o) hex_outline();
        if (!has_skirts)
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
    head_radius = head_diameter/2 + 2*offset;
    bolt_radius = bolt_diameter/2 + offset;
    $fn = round(360/fa_from_fs(head_radius));
    sc = offset ? undef : "gainsboro";
    color(sc) difference() {
        union() {
            translate([0, 0, -offset])
                cylinder(h = head_radius, r1 = head_radius, r2 = 0);
            translate([0, 0, 0.01])
                cylinder(h = length + offset - 0.01, r = bolt_radius);
            if (offset)
                translate([0, 0, -length])
                    cylinder(h = length - offset + 0.01, r = head_radius);
        }
        if (!offset) {
            rotate([90, 0, 0]) rotate([0, 0, 45])
                linear_extrude(height = head_radius/4, center=true)
                offset(r=head_radius/3) square(head_radius/3, center=true);
            rotate([0, 90, 0]) rotate([0, 0, 45])
                linear_extrude(height = head_radius/4, center=true)
                offset(r=head_radius/3) square(head_radius/3, center=true);
        }
    }
}

module flat_head_screw(length) {
    head_radius = flat_head_diameter/2;
    bolt_radius = bolt_diameter/2;
    $fn = round(360/fa_from_fs(head_radius));
    color("gainsboro") difference() {
        union() {
            intersection() {
                rotate_extrude(angle=360) intersection() {
                    offset(r=flat_head_thickness)
                        square(head_radius - flat_head_thickness,
                               center=false);
                    translate([0, -flat_head_thickness, 0]) square(head_radius);
                }
                translate([0, 0, -flat_head_thickness/2])
                    cube([flat_head_diameter, flat_head_diameter,
                          flat_head_thickness+0.01], center=true);
            }
            translate([0, 0, -0.01])
                cylinder(h = length + 0.01, r = bolt_radius);
        }
        translate([0, 0, -flat_head_thickness])
            rotate([90, 0, 0]) rotate([0, 0, 45])
            linear_extrude(height = head_radius/4, center=true)
            offset(r=bolt_radius/2) square(bolt_radius/2, center=true);
        translate([0, 0, -flat_head_thickness])
            rotate([0, 90, 0]) rotate([0, 0, 45])
            linear_extrude(height = head_radius/4, center=true)
            offset(r=bolt_radius/2) square(bolt_radius/2, center=true);
    }
}

module mcu(height, offset)
    translate([0, mcu_y, 0]) linear_extrude(height) offset(r=offset)
        square(mcu_size, center=true);
module mcu_pins(height, diam) {
    y0 = mcu_y - 2.54*6;
    for (i = [0:11]) {
        translate([-7.62, y0 + i*2.54, 0])
            cylinder(h=height, d=diam);
        translate([ 7.62, y0 + i*2.54, 0])
            cylinder(h=height, d=diam);
    }
}
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
                       s_pcb - oh, f_key + s_key - oh, 1);
    difference() {
        translate([0, 0, main_height - deck_thickness - ov - 0.01])
            raised_extrusion(raised_height + 0.01,
                             s_pcb - oh, f_key + s_key - oh);
        translate([hx+dx/2, -5*hy/3 - dy + oh,
                   main_height - deck_thickness - ov - 0.02]) rotate([0, 0, 180])
            cube([2*hx+dx, hy, raised_height + 0.03]);
        translate([0, 0,
                   main_height - deck_thickness + mezzanine_thickness + vfit])
            trackball_frame(raised_height, -s_key/2, oh, f_key + s_key);
        width = oh ? 7*hx + dx : 2*hx + dx;
        pivot_installation_cut(width, s_pcb - oh, f_key + s_key - oh);
    }
}
//translate([0, 0, 50]) case_inside(hfit, vfit);

module case_main()
    fillet_polyhedron(main_outline_points, main_height,
                      s_pcb + wall_thickness_main,
                      f_key + s_key + wall_thickness_main,
                      f_key + s_key + wall_thickness_main,
                      r_edge_main, r_corner_main, fillet_style);
module case_outside() {
    union() {
        // work around CGAL quirks: make the raised part slightly smaller
        // than the main part, otherwise CGAL throws various errors or
        // assertion failures, sometimes with different ones depending on
        // arbitrary changes of parameters.
        x = 0.0001;
        case_main();
        translate([0, 0, main_height - 2*r_corner_main]) difference() {
            fillet_polyhedron(raised_outline_points,
                              raised_height + 2*r_corner_main,
                              s_pcb + wall_thickness_raised-x,
                              f_key + s_key + wall_thickness_raised-x,
                              f_key + s_key + wall_thickness_raised-x,
                              r_edge_raised, r_corner_raised, fillet_style,
                    round_bottom=(wall_thickness_main < wall_thickness_raised));
            translate([hx+dx/2, -5*hy/3 - dy, -vfit]) rotate([0, 0, 180])
                cube([2*hx+dx, hy, raised_height + 2*r_corner_main + 2*vfit]);
        }

        if (has_display)
            translate([0, 0, main_height+raised_height-r_corner_raised-vfit])
                fillet_polyhedron(display_bump_points,
                                  display_bump_height+r_corner_raised+vfit,
                                  -s_key/2,
                                  f_key+s_key/2, f_key+s_key/2,
                                  0.75, display_bump_height, 3,
                                  false);
    }
}
//translate([0, 0, 50]) case_outside();

module base_plate_base(oh, ov) intersection() {
    translate([0, 0, -ov - 0.01])
        main_extrusion(base_thickness + 2*ov + 0.01,
                       s_pcb + wall_thickness_main/2 + oh,
                       f_key + s_key + wall_thickness_main + oh);
    if (!ov)
        case_main();
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
    main_extrusion(main_height, s_pcb - hfit, f_key + s_key - hfit,
                   variant=1);
}

main_gasket_pos_rot = [
    [-4.00*hx - dx/2, 11/3*hy,   0],
    [ 4.00*hx + dx/2, 11/3*hy,   0],
    [-2.00*hx - dx/2, 11/3*hy,   0],
    [ 2.00*hx + dx/2, 11/3*hy,   0],
    [-5.25*hx - dx/2,  7/6*hy, -60],
    [ 5.25*hx + dx/2,  7/6*hy,  60],
    [-4.00*hx - dx/2,  1/3*hy,   0],
    [ 4.00*hx + dx/2,  1/3*hy,   0],
    [-2.00*hx - dx/2, -5/3*hy - dy,   0],
    [ 2.00*hx + dx/2, -5/3*hy - dy,   0]
];
module main_gaskets() {
    for (p = main_gasket_pos_rot) {
        color(foam_color)
            translate([p.x, p.y,
                       plate_thickness + (gasket_thickness_main - vfit)/2])
            rotate([0, 0, p.z])
            cube([gasket_length, gasket_width, gasket_thickness_main-vfit],
                 center=true);
        color(foam_color)
            translate([p.x, p.y,
                       -(gasket_thickness_main - vfit)/2])
            rotate([0, 0, p.z])
            cube([gasket_length, gasket_width, gasket_thickness_main-vfit],
                 center=true);
    }
}
raised_gasket_pos = let (x = (hx + dx/2 + mcu_size.x/2) / 2) [
    [-x, 3*hy],
    [ x, 3*hy],
    [-2.00*hx - dx/2, -5/3*hy - dy],
    [ 2.00*hx + dx/2, -5/3*hy - dy]
];
module raised_gaskets() {
    for (p = raised_gasket_pos) {
        color(foam_color)
            translate([p.x, p.y,
                       plate_thickness + (gasket_thickness_main - vfit)/2])
            cube([gasket_length, gasket_width, gasket_thickness_main-vfit],
                 center=true);
        color(foam_color)
            translate([p.x, p.y,
                       -(gasket_thickness_main - vfit)/2])
            cube([gasket_length, gasket_width, gasket_thickness_main-vfit],
                 center=true);
    }
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

module base_plate(fast_shadow=false) difference() {
    ca = render_case ? 0 : case_alpha;
    bc = render_case ? undef : base_color;
    color(bc, alpha=ca) union() {
        base_plate_base(0, 0);
        main_gasket_pads();
    }
    drain_hole();
    if (!fast_shadow) {
        base_relief();
        translate(trackball_position + [0.25, 0.1, -0.3]) rotate([60, 0, 0])
            translate([0, 0, -trackball_radius]) sensor();
        translate(trackball_position + [-0.25, 0.1, -0.3]) rotate([60, 0, 0])
            translate([0, 0, -trackball_radius]) sensor();
        translate([-17, mcu_top - 8.89 - 1.85, -vfit])
            cylinder(h=base_thickness+2*vfit, r=1.5, center=false);
        power_switch_cutout();
        for (p = mounting_points_main)
            translate([p.x, p.y, 0])
                countersunk_screw(base_thickness, hfit);
        for (p = bump_positions)
            translate(p)
                cylinder(h = bump_recess*2, d = bump_diameter, center = true);
    }
}
module case(fast_shadow=false) union() {
    ca = render_case ? 0 : case_alpha;
    cc = render_case ? undef : case_color;
    difference() {
        color(cc, alpha=ca) case_outside();
        if (!fast_shadow) render(convexity=10) union() {
            base_plate_base(hfit, vfit);
            case_inside(0, 0);
            translate([0, 0, main_height - deck_thickness - 0.01])
                main_key_slots(deck_thickness + 0.02, true);
            // Cut through the top deck and deep enough through the skirts to
            // accommodate 3.3mm key travel.
            raised_slot_depth = has_skirts ? max(deck_thickness+0.02, 3.3) :
                raised_height + deck_thickness + 0.02;
            translate([0, 0, main_height + raised_height -
                             raised_slot_depth - 0.01])
                raised_key_slots(raised_slot_depth + 0.02);

            /* Position of the bottom right thumb key. The edge of that key
             * marks the plane that cuts the sphere of the trackball. Rotate
             * thatn around the z-axis so the distance of the plane to the
             * center of the sphere become the y-coordinate. Then calculate
             * the radius of the circle where the plane cuts the sphere.
             *
             * Use that to chamfer the sharp edge where the sphere cuts through
             * the front of the case with a cylinder (perpendicular to the
             * plane of the case) and a cone (perpendicular with the sphere).
             */
            p = rotate_z_around([hx + dx/2, -2*hy - dy, 20], -30,
                                trackball_position) - trackball_position;
            d_trackball_cut = -p.y - hx/2 - kx - 0.5;
            r_trackball_cut = sqrt((trackball_radius+spacing)^2 -
                                   d_trackball_cut^2);
            translate(trackball_position) {
                corr_sphere(trackball_radius + spacing);
                difference() {
                    union() {
                        rotate([90, 0, 30])
                            cylinder(2*d_trackball_cut,
                                     r=r_trackball_cut+1);
                        rotate([90, 0, 30])
                            cylinder(2*d_trackball_cut,
                                     r1=0, r2=2*(r_trackball_cut+1));
                        rotate([90, 0, -30])
                            cylinder(2*d_trackball_cut,
                                     r=r_trackball_cut+1);
                        rotate([90, 0, -30])
                            cylinder(2*d_trackball_cut,
                                     r1=0, r2=2*(r_trackball_cut+1));
                    }
                    translate([-50, -50, -trackball_z])
                        cube([100, 100, main_height]);
                }
            }
            translate([0, 0,
                       main_height + raised_height - deck_thickness - 1])
                mcu_pins(2, 3);

            // allow +/-2mm movement or misalignment for max-size plug
            usb_height = 0.6 + 4;
            // allow USB plugs or magnetic adapters with 2.5mm width
            // surrounding the USB plug itself
            usb_offset = 1.255 + 2.5;
            // Assume Z position of top-mounted USB port with 8.4mm female +
            // 2.5mm male headers. Mid-mounted USB will have only 0.4mm to move
            // up, but down-movement matters more
            usb_z = main_pcb_z + pcb_thickness + 8.4+2.5 - (1.255*2+0.6)/2;
            w = max(wall_thickness_main, wall_thickness_raised);
            translate([0, mcu_top + s_pcb + w + 0.1,
                       usb_z])
                usb_port_template(usb_offset, w + 1.2, usb_height);

            power_switch_cutout();

            if (has_display)
                translate(display_position) niceview_cutout();

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
        } else union() {
            translate(trackball_position)
                corr_sphere(trackball_radius + spacing);
            drain_hole();
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

module main_pcb() scale([-1, 1, 1]) color(pcb_color)
    flat_extrusion("outlines/main_pcb.dxf", pcb_thickness);
module main_pcb_foam() color(foam_color)
    translate([0, 0, -foam_thickness + vfit])
    flat_extrusion("outlines/main_pcb_foam.dxf", foam_thickness - 2*vfit);
module raised_pcb() scale([-1, 1, 1]) color(pcb_color)
    flat_extrusion("outlines/raised_pcb.dxf", plate_thickness);
module raised_pcb_foam() color(foam_color)
    translate([0, 0, -foam_thickness + vfit])
    flat_extrusion("outlines/raised_pcb_foam.dxf", foam_thickness - 2*vfit);
module main_plate() color(plate_color)
    flat_extrusion("outlines/main_plate.dxf", pcb_thickness);
module main_plate_foam() color(foam_color)
    translate([0, 0, -foam_thickness + vfit])
    flat_extrusion("outlines/main_plate_foam.dxf", foam_thickness - 2*vfit);
module raised_plate() color(plate_color)
    flat_extrusion("outlines/raised_plate.dxf", plate_thickness);
module raised_plate_foam() color(foam_color)
    translate([0, 0, -foam_thickness + vfit])
    flat_extrusion("outlines/raised_plate_foam.dxf", foam_thickness - 2*vfit);

module female_header(height, pin_l, n) {
    pitch = 2.54;
    pin_w = 0.4;
    w = 2.5;
    pad = 0.25;
    color("#303030") render(convexity=10) difference() {
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
    color("#303030") render(convexity=10) difference() {
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
    color("lightgrey") render(convexity=10) difference() {
        usb_port_template(1.255, depth);
        translate([0, 0.1, 0]) usb_port_template(1.155, depth);
    }
    color("#303030") translate([0, 0.05, 0]) usb_port_template(0, depth-0.1);
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

module jst_ph(n) translate([-(n-1), 0, 0]) {
    color("beige") render() difference() {
        w = n * 2 + 1.9;
        translate([0, 7.6/2-1.6, 2.4]) cube([w, 7.6, 4.8], center=true);
        translate([0, 7.6/2+0.5, 2.4]) cube([w-1, 7.6, 4.8-1], center=true);
        translate([0, -2, 2.4]) cube([w-1, 3.5, 5], center=true);
        translate([-w/2 + 1, 0, 4.8]) cube([1, 8, 1.1], center=true);
        translate([ w/2 - 1, 0, 4.8]) cube([1, 8, 1.1], center=true);
        translate([0, 6, 3]) cube([w+1, 4, 1], center=true);

        g = (n-2) * 2 + 1;
        translate([0, 6, 4.8]) cube([g, 8, 1.1], center=true);

        multmatrix([
            [1, 0, 0, 0],
            [0, 1, 0, -1.3],
            [0, 1, 1,  4.9],
            [0, 0, 0, 1]]) cube([w+1, 2, 4], center=true);
        for(i = [0:(n-1)]) {
            x = (i - (n-1)/2) * 2;
            translate([x, -1, 2.4]) cube([0.6, 2, 5], center=true);
        }
    }
    for(i = [0:(n-1)]) {
        x = (i - (n-1)/2) * 2;
        color("silver") union() {
            translate([x, 0, -0.15]) cube([0.5, 0.5, 6.5], center=true);
            translate([x, 2.75, 3.1]) cube([0.5, 6, 0.5], center=true);
        }
    }
}

module pcm12_switch() {
    color("silver") translate([-6.7/2, -2.6/2, 0]) cube([6.7, 2.6, 1.4]);
    color("dimgrey") translate([-1.3, 2.58/2, 0.4]) cube([1.3, 1.5, 0.8]);
    color("silver") translate([-7.7/2, -2.6/2, 0]) cube([7.7, 0.66, 0.15]);
    color("silver") translate([-7.7/2, 2.6/2-0.66, 0]) cube([7.7, 0.66, 0.15]);
    color("gold") translate([-0.75-0.2, -2.6/2-0.9, 0]) cube([0.4, 1, 0.15]);
    color("gold") translate([-2.25-0.2, -2.6/2-0.9, 0]) cube([0.4, 1, 0.15]);
    color("gold") translate([2.25-0.2, -2.6/2-0.9, 0]) cube([0.4, 1, 0.15]);
}

module reset_button() {
    color("silver") linear_extrude(height=0.8, center=false)
        polygon([
            [-2.55, 1.35], [-1.35, 2.55], [ 1.35, 2.55], [ 2.55, 1.35],
            [ 2.55,-1.35], [ 1.35,-2.55], [-1.35,-2.55], [-2.55,-1.35]
        ]);
    color("silver") translate([0, 0, 0.79])
        cylinder(h=0.41, r1=2.2, r2=2.0, center=false);
    color("palegoldenrod") translate([0, 0, 1.19])
        cylinder(h=0.31, r=1.0, center=true);
    color("silver") translate([0, 1.85, 0.05])
        cube([6.6, 0.5, 0.1], center=true);
    color("silver") translate([0, -1.85, 0.05])
        cube([6.6, 0.5, 0.1], center=true);
}

module controller() {
    ex = $explode;
    y0 = -2.54*6;
    usb_mount_z = 0;
    translate([-7.62, y0, 8.4 + 1*ex]) male_header(2.49, 6, 3, 12);
    translate([ 7.62, y0, 8.4 + 1*ex]) male_header(2.49, 6, 3, 12);
    color(pcb_color) translate([-mcu_size.x/2, -mcu_size.y/2, 10.9 + ex])
        difference() {
            cube([mcu_size.x, mcu_size.y, 1.6]);
            if (usb_mount_z < 1.6)
                translate([(mcu_size.x - 9.3)/2, mcu_size.y - 10.6, -0.1])
                    cube([9.3, 10.7, 1.8]);
        }
    translate([0, mcu_size.y/2, 10.9 + ex - usb_mount_z]) usb_port(10.5);
}

module main_pcb_assembly(show_mcu=true) {
    main_pcb();
    translate([0, hy, 0]) rotate([0, 180, 0]) ffc_connector();
    translate([-17, 4*hy/3, 0]) rotate([0, 180, 0]) ffc_connector();
    translate([0, mcu_top - 2.6/2, 0]) rotate([0, 180, 0])
        pcm12_switch();
    translate([-17, mcu_top - 8.89 - 1.85, 0]) rotate([0, 180, 0])
        reset_button();
    translate([0, mcu_y, pcb_thickness]) {
        y0 = -2.54*6;
        translate([-7.62, y0, 0]) female_header(8.39, 3.2, 12);
        translate([ 7.62, y0, 0]) female_header(8.39, 3.2, 12);
        if (show_mcu) controller();
    }
    translate([-4, mcu_y-12, pcb_thickness]) rotate([0, 0, 180]) jst_ph(5);
    translate([14, 13, pcb_thickness]) rotate([0, 0, 150]) jst_ph(2);
}

module raised_pcb_assembly() {
    raised_pcb();
    translate([0, hy-9, 0]) rotate([0, 180, 180]) ffc_connector();
}

module niceview() {
    // PCB with through-hole pads
    difference() {
        union() {
            color(pcb_color) linear_extrude(height=1)
                offset(r=1) square([12, 34], center = true);
            for (i = [0:4])
                color("gold") translate([-5.12+i*2.54, -16.7, -0.05])
                    cylinder(h=1.1, r=2.54/3, center=false);
        }
        for (i = [0:4])
            translate([-5.12+i*2.54, -16.7, -0.1])
                    cylinder(h=1.2, r=2.54/6, center=false);
    }
    // Display
    color("darkslategrey") translate([0, -0.325, 1.45])
        cube([13.5, 29.35, 0.9], center=true);
    // Visible area
    color("aliceblue") translate([0, -0.75, 1.9])
        linear_extrude(height=0.01, center=true) difference() {
            square([10.8, 25.3], center=true);
            rotate(90)
                text("Mantis v1.0", size = 2.5, font=":style=bold",
                     halign="center", valign="center");
        }

    // Ribbon cable
    color("goldenrod") translate([0, 13.7, 0.5]) rotate([0, 90, 0])
        linear_extrude(height=10, center=true)
        offset(r=0.5) square([0.5, 8], center=true);
    // Ribbon connector on the bottom
    translate([0, 10, 0]) rotate([0, 180, 180]) ffc_connector_hirose();
}

module niceview_cutout() union() {
    // PCB + display
    translate([0, 0, 0.95]) cube([14.2, 36.2, 1.91], center=true);
    // Ribbon cable
    below_ribbon = 1;
    translate([0, 13.7, 0.5-below_ribbon]) rotate([0, 90, 0])
        linear_extrude(height=10.5, center=true)
        offset(r=0.75) square([0.5+2*below_ribbon, 8], center=true);

    // Opening for visible area with 0.5mm margin and 1mm fillet
    wh = main_height + raised_height + display_bump_height -
         (display_position.z + 1.9);
    points = [[-10.8/2,  25.3/2], [ 10.8/2,  25.3/2],
              [ 10.8/2, -25.3/2], [-10.8/2, -25.3/2]];
    translate([0, -0.75, wh+1+1.9]) rotate([180, 0, 0])
        fillet_polyhedron(points, wh+1, wh, wh+1, wh+1, wh, wh, 5, false);
    //cube([10.8, 25.3, 10.01], center=true);

    h = display_position.z - // latch height
        (main_height + raised_height - deck_thickness);
    l = 12;   // snap length
    r = 0.8;  // snap width
    g = 0.8;  // gap width
    w = 3;    // latch width
    d = 0.5;  // latch depth

    // 3mm space underneath, with a 1mm ledge near the top
    // and a latch near the bottom
    translate([0, -0.5, -1.5]) difference() {
        cube([14.2, 35.2, 3.01], center=true);
        multmatrix([[1, 0, 0,   (l - w)/2 - g],
                    [0, 1, d/h, -35.2/2-1.01],
                    [0, 0, 1,   1.5-h],
                    [0, 0, 0,   1]])
            cube([w, 2, 6], center=true);
    }
    // Space around the latch
    translate([0, -36.2/2 - r/2, -0.55]) difference() {
        linear_extrude(height=4.91, center=true) offset(r=g)
            square([l-2*g, r], center=true);
        translate([-g, g, -g]) cube([l, 2*g+r, 4.91], center=true);
    }
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
    color("#ffffff", 0.3) lens(-0.01);
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
module mezzanine_relief() translate([0, 0, main_height - deck_thickness +
                                     mezzanine_thickness - base_relief_depth])
    flat_extrusion("outlines/mezzanine_relief.dxf", base_relief_depth+vfit);
module mezzanine(fast_shadow=false) {
    ca = render_case ? 0 : case_alpha;
    mc = render_case ? undef : mezzanine_color;
    difference() {
        color(mc, alpha=ca) union() {
            translate([0, 0, main_height - deck_thickness])
                raised_extrusion(mezzanine_thickness,
                                 s_pcb, f_key + s_key);
            raised_gasket_pads();
        }
        main_key_slots(main_height + raised_height);
        translate([0, 0, main_height - deck_thickness - 0.01])
            mcu(base_thickness + gasket_pad_thickness_raised + 0.02, spacing);
        translate([0, 0, main_height - deck_thickness - 0.01])
            display_cable_cutout(base_thickness +
                                 gasket_pad_thickness_raised + 0.02,
                                 spacing);

        for(p = mounting_points_raised)
            translate([p.x, p.y, main_height - deck_thickness
                       + mezzanine_thickness - base_thickness])
                countersunk_screw(base_thickness, hfit);
        if (!fast_shadow)
            mezzanine_relief();
    }
}

module bearings(size, offset, what=0) {
    translate(trackball_position) rotate([9, 0, 0]) {
        for (phi = [0:120:240])
            rotate([-50, 0, phi]) translate([0, 0, -trackball_radius - size/2])
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
                else if (what == 5) {
                    translate([-size/4, 0, 0])
                        cube([size/2, size/2 + offset, size/2]);
                    rotate([0, 0, 120]) translate([-size/4, 0, 0])
                        cube([size/2, size/2 + offset, size/2]);
                    rotate([0, 0, 240]) translate([-size/4, 0, 0])
                        cube([size/2, size/2 + offset, size/2]);
                }
    }
}

module trackball_holder(fast_shadow=false) intersection() {
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
                    mezzanine(fast_shadow);
                    color(mc, alpha=ca) {
                        translate(trackball_position) rotate([60, 0, 0])
                            translate([0, 0, -trackball_radius - 2.4 + vfit])
                            cylinder(2.5, 5, 5);
                        bearings(bearing_size, 4.5 - bearing_size/2);
                    }
                }
                w = 2*hx + dx;
                h = 24;
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
            if (!fast_shadow) {
                difference() {
                    bearings(bearing_size, 1.5, what=4);
                    bearings(bearing_size, 0.25, what=3);
                }
                bearings(bearing_size, 0.01);
                bearings(bearing_size, -0.1, what=1);
                bearings(bearing_size, -0.5, what=2);
                bearings(bearing_size, 1.4, what=5);

                translate(trackball_position) rotate([60, 0, 0]) {
                    translate([0, 0, -trackball_radius-2.5])
                        cylinder(2.5, 2.5, 1.5, center=false);
                    for (p = mounting_points_sensor)
                        translate([p.x, p.y,
                                   -trackball_radius - 9.05+1.65 + 1.6])
                            cylinder(5, d = bore_diameter);
                }
            }
        }
    }
    render(convexity=10) case_inside(hfit, vfit);
}

module key_profile(x, key_color="") {
    $fa = $fs*2;
    $choc_version = switch_type;
    $rgb = rgb;
    $slope = slope;
    $dish_diam = dish_diam;
    $explode=$explode/2;
    $key_color=key_color;
    $color_scheme=switch_colors;
    z_off = switch_type == 2 ? 0.5 : 0;

    if (x == 0) {
        switch_key($tilt=tilt1, $rise=rise1+z_off, $saddle=saddle);
    } else if (x == 1) {
        switch_key($tilt=tilt2, $rise=rise2+z_off, $saddle=saddle);
    } else if (x == 2) {
        switch_key($tilt=tilt3, $rise=rise3+z_off, $saddle=saddle);
    }
}

module keyboard(fast_shadow=false) {
    ex = $explode;
    case_shadow = (show_case && show_base && fast_shadow);

    if (!case_shadow) {
        if (show_main_pcb) translate([0, 0, main_pcb_z + 2*ex]) {
            main_pcb_assembly(show_misc);
            if (show_foam && !fast_shadow)
                translate([0, 0, -ex]) main_pcb_foam();
        }
        if (show_raised_pcb) translate([0, 0, raised_pcb_z + 7*ex]) {
            raised_pcb_assembly();
            if (show_foam && !fast_shadow)
                translate([0, 0, -ex]) raised_pcb_foam();
        }

        if (show_main_plate) translate([0, 0, main_plate_z + 4*ex]) {
            main_plate();
            if (!fast_shadow) {
                if (show_misc) main_gaskets();
                if (show_foam) translate([0, 0, -ex]) main_plate_foam();
            }
        }
        if (show_raised_plate) translate([0, 0, raised_plate_z + 9*ex]) {
            raised_plate();
            if (!fast_shadow) {
                if (show_misc) raised_gaskets();
                if (show_foam) translate([0, 0, -ex]) raised_plate_foam();
            }
        }
    }

    if (show_sensor && !case_shadow)
        translate(trackball_position + [0, 0, 3*ex]) {
        if (show_misc) {
            rotate([60, 0, 0]) for (p = mounting_points_sensor)
                translate([p.x, p.y, -trackball_radius - 9.05+1.65])
                    flat_head_screw(bolt_length);
        }
        rotate([60, 0, 0]) translate([0, 0, -trackball_radius]) sensor();
    }

    if (has_display && show_display && !case_shadow)
        translate(display_position+[0, 0, 8*ex]) niceview();

    if (show_trackball) {
        color(trackball_color) translate(trackball_position + [0, 0, 11*ex])
            rotate([30, 0, 180]) corr_sphere(trackball_radius);
    }

    if ((show_key || show_switch) && !fast_shadow) {
        colors = [key_color, key_color2];
        main_fingers = [
            [0.5,3,  0,0,0],[1.5,3, -60,1,0],[2.5,3, -60,1,0],[3.5,3, -60,1,0],
            [0.0,2,120,0,0],[1.0,2,-120,0,1],[2.0,2,-120,0,1],[3.0,2,-120,0,1],
                            [0.5,1, 180,2,0],[1.5,1, 180,2,0],[2.5,1, 180,2,0],
                                                              [2.0,0, 180,1,0]
        ];
        raised_fingers = [
            [4.0,2, -60,1,0],[4.5,1,-120,1,0],
            [3.5,1,-120,0,1],[4.0,0,-120,1,0],
            [3.0,0, 180,2,0]
        ];
        raised_thumbs =   [[2.5,-1,60,0,0],[3.5,-1,0,0,1]];
        main_thumbs =     [[4.0,-2, 0,1,0]];
        union() {
            main_z = main_switch_z + 5*ex;
            raised_z = raised_switch_z + 11*ex;
            hx = hx + ex/3;
            hy = hy + ex/3;
            for (k = main_fingers) {
                translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy, main_z])
                    rotate([0, 0, k[2]]) key_profile(k[3],colors[k[4]]);
                translate([5*hx + dx/2 - k[0]*hx, k[1]*hy, main_z])
                    rotate([0, 0,-k[2]]) key_profile(k[3],colors[k[4]]);
            }
            for (k = main_thumbs) {
                translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy - dy, main_z])
                    rotate([0, 0, k[2]]) key_profile(k[3],colors[k[4]]);
                translate([5*hx + dx/2 - k[0]*hx, k[1]*hy - dy, main_z])
                    rotate([0, 0,-k[2]]) key_profile(k[3],colors[k[4]]);
            }
            for (k = raised_fingers) {
                translate([-5*hx - dx/2 + k[0]*hx, k[1]*hy, raised_z])
                    rotate([0, 0, k[2]]) key_profile(k[3],colors[k[4]]);
                translate([5*hx + dx/2 - k[0]*hx, k[1]*hy, raised_z])
                    rotate([0, 0,-k[2]]) key_profile(k[3],colors[k[4]]);
            }
            for (k = raised_thumbs) {
                translate([-5*hx -dx/2 + k[0]*hx, k[1]*hy - dy, raised_z])
                    rotate([0, 0, k[2]]) key_profile(k[3],colors[k[4]]);
                translate([5*hx + dx/2 - k[0]*hx, k[1]*hy - dy, raised_z])
                    rotate([0, 0,-k[2]]) key_profile(k[3],colors[k[4]]);
            }
        }
    }

    if (show_mezzanine && !case_shadow) {
        if (show_misc) {
            if (show_misc) translate([0, 0,  5*ex]) bearings(bearing_size, 0);

            for(p = mounting_points_raised)
                translate([p.x, p.y, main_height - deck_thickness +
                           mezzanine_thickness - base_thickness + hfit +
                           5*ex])
                    countersunk_screw(bolt_length, 0);
        }
        pivot = [0, mcu_top - post_diameter, main_height - deck_thickness];
        angle = [12 - abs($t-0.5)*24, 0, 0];
        translate([0, 0, 5*ex] + pivot) rotate(angle) translate(-pivot) {
            if (render_case)
                color(mezzanine_color, alpha=case_alpha)
                    render(convexity=8) trackball_holder(fast_shadow);
            else
                color(alpha=case_alpha) trackball_holder(fast_shadow);
        }
    }

    if (show_base && !case_shadow) {
        if (show_misc) {
            for (p = mounting_points_main)
                translate([p.x, p.y, hfit])
                    countersunk_screw(bolt_length, 0);
        }
        if (render_case)
            color(base_color, alpha=case_alpha) render(convexity=8)
                base_plate(fast_shadow);
        else
            color(alpha=case_alpha) base_plate(fast_shadow);

        if (show_misc) {
            for (p = bump_positions)
                color("white", alpha=0.2)
                    translate([p.x, p.y, bump_recess]) bump();
        }
    }

    if (show_case) {
        if (render_case)
            translate([0, 0, 10.2*ex]) color(case_color, alpha=case_alpha)
                render(convexity=10) case(case_shadow);
        else
            translate([0, 0, 10.2*ex]) color(alpha=case_alpha)
                case(case_shadow);
    }
}

module desk() color(desk_color) rotate([0, 0, $explode ? 0 : -5])
    translate([-300, $explode ? -175 : -100, -20])
    cube([600, 350, 20]);
module shadow(sun) projection(cut=false)
    multmatrix([[1, 0, sun.x/sun.z, 0],
                [0, 1, sun.y/sun.z, 0],
                [0, 0,           1, 0]])
    keyboard(fast_shadow, $fs=2);

if (show_desk && $preview) {
    elevation = max(0, bump_height - bump_recess);
    desk();

    // Slanted shadow angled away from an imaginary sun
    sun = [0.30, -0.50, 1 + $explode/10];
    color("black", alpha=0.2/(shadow_softness+1))
        linear_extrude(height=0.02, center=true) shadow(sun);
    if (shadow_softness > 0) for (i = [1:shadow_softness]) {
        a = i * 360/shadow_softness-30;
        d = shadow_softness > 1 ? shadow_spread/2 : 0;
        s = [sun.x + d*sin(a), sun.y + d*cos(a), sun.z];
        color("black", alpha=0.2/(shadow_softness+1))
            linear_extrude(height=0.02*(i+1), center=true) shadow(s);
    }

    // Core shadow slightly smaller than the outline
    if (show_base || show_main_pcb || show_main_plate || show_mezzanine) {
        o = (show_base       ? elevation :
             show_main_pcb   ? elevation + main_pcb_z :
             show_main_plate ? elevation + main_plate_z :
                               elevation + main_height-deck_thickness)/2;
        a = min(0.15/o, 0.5);
        color("black", alpha=a)
            linear_extrude(height=0.02*(shadow_softness+2), center=true)
            offset(r = 10 + 8*o - o*o) // expand to slightly below original size
            offset(r = -10 - 10*o) // shrink
            offset(r = 2*o) // fuse small holes
            projection(cut=false) if (!$explode)
                keyboard(true, $fs=2);
            else
                base_plate(true);
    }
}

translate([0, 0, bump_height - bump_recess]) keyboard();
