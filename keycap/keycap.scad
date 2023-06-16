// Angular resulution
$fa = 2;
$fs = 0.4;
// Whether to render RGB LED cutouts in the keycaps
$rgb = true;
// Whether to use a minkowski sum for more consistent thickness
$minkowski = false;

// Key parameters:
// Tilt angle of the keycap surface
$tilt = 15;
// Tilt angle for outside keys
$tilt2 = 15;
// Slope angle of the dish at the rim
$slope = 15;
// Height from the bottom of the keycap to the rim at the front of the key
$height = 2.4;
// Approximate thickness of the wall (may be thicker in some places)
$thickness = 1.4;
// Width of the hexagonal key
$key_width = 20.96;
// Diameter of the spherical dish
$dish_diam = 14;
// Fillet radius
$fillet = 3;
// Maximum dish excentricity (tilt / 7.5)
$max_exc = 2.5;
// Mid layer height
$mid_layer_height = 6;

// How far the keys are pressed down (0-3mm)
$travel = 0.1;
// Mantis plate explosion offset
$explode = 0;
// Mantis keyboard with switches and keys
$preview_mantis = false;
// Model of mantis sound channels
$preview_sound = false;
// One switch and key fit check
$preview_switch_key = false;
// One switch
$preview_switch = false;
// One key sliced and exploded to show wall thickness
$preview_exploded_key = false;
// Print some key stats
$show_stats = false;

function rotate_x(point, angle) = [
    point.x,
    point.y*cos(angle) - point.z*sin(angle),
    point.z*cos(angle) + point.y*sin(angle)
];
function rotate_x_around(point, angle, origin=[0, 0, 0]) =
    rotate_x(point - origin, angle) + origin;

function rotate_z(point, angle) = [
    point.x*cos(angle) - point.y*sin(angle),
    point.y*cos(angle) + point.x*sin(angle),
    point.z
];

function part_sums(seq) = [for (a = 0, i = 0; i <= len(seq);
                                a = a + seq[min(i, len(seq)-1)],
                                i = i + 1) a];

cos30 = cos(30);
function fillet_unit_hex_segment(r, a) = a < r*30 ?
    // arc segment
    [-r*sin(a/r), r*cos(a/r) + (1 - r)/cos30, 0] :
    // linear segment
    let (xr30 = -r/2, yr30 = (1 - r)/cos30 + r*cos30,
         dx = -(1 - r) / ((1 - r)*60),
         dy = -(1 - r)/(2*cos30) / ((1 - r)*60))
        [xr30 + dx * (a - r*30), yr30 + dy * (a - r*30), 0];

function fillet_unit_hex_point(r, a) = let (b = (a + r*30) % 60 - r*30)
    rotate_z(fillet_unit_hex_segment(r, b), a-b);

module fillet_hexagon(R, r, h, da=$fa) {
    steps = floor(360/da);
    
    points_lower = [for (a = [0 : da : (steps-1) * da])
        fillet_unit_hex_point(r/R, a)*R
    ];
    points_upper = [for (a = [0 : da : (steps-1) * da])
        fillet_unit_hex_point(r/R, a)*R + [0, 0, h]
    ];
    points = concat(points_lower, points_upper);

    face_bot = [for (i = [0 : 1 : steps-1]) i];
    face_top = [for (i = [0 : 1 : steps-1]) steps*2 - 1 - i];
    faces_rim = [for (i = [0 : 1 : steps-1])
        [(i + 1) % steps, i, steps + i, steps + (i + 1) % steps]
    ];
    faces = concat([face_bot, face_top], faces_rim);

    polyhedron(points, faces);
}

// Linear interpolation
// Interpolates a quantity x between two values x1 and x2 using
// a parameter b such that x(b=0) == x0, x(b=1) == x1. For b
// outside the interval [0, 1] it's a linear extrapolation.
function interpolate(x0, x1, b) = x0 * (1 - b) + x1 * b;

// Fillet Hexagon Cone
// R1/2: Lower/Upper major radius
// r1/2: Lower/Upper fillet radius
// exc: excentricity at top
// tilt: tilt angle of the top
// slope: slope at the inside rim of the dish
// h: padding height
module fillet_hexagon_cone(R1, R2, r1, r2, exc, tilt, slope, h, da=$fa) {
    steps = floor(360/da);

    // y-z coordinates of front and back perimeter and rim for interpolation
    yf1 = -R1/cos30 + r1*(1/cos30 - 1);
    zf1 = 0;
    yf2 = -R2/cos30 + r2*(1/cos30 - 1) - exc;
    zf2 = h;
    yb1 = -yf1;
    zb1 = 0;
    yb2 = yf2 + 2*R2*cos(tilt);
    zb2 = zf2 + 2*R2*sin(tilt);

    // parabolas for interpolating zf/zb-coordinates that is
    // 0 at b=0
    // 1 at b=1
    // has slope s at b=1 (the rim) that matches the slope of the dish
    df = yf2 - yf1;
    sf = tan(tilt-slope) * (zf2 - zf1) / df;
    af = sf - 1;
    bf = 2 - sf;

    db = yb2 - yb1;
    sb = /*tan(tilt+slope)*/0 * (zb2 - zb1) / db;
    ab = sb - 1;
    bb = 2 - sb;

    steps_cone = max(3, floor(steps / 15));
    points_cone = [for (b = [0 : 1/steps_cone : 1 - 1/steps_cone]) each
        let (b2f = b * (af*b + bf),
             b2b = b * (ab*b + bb),
             r = interpolate(r1, r2, b2f),
             yf = interpolate(yf1, yf2, b),
             zf = interpolate(zf1, zf2, b2f),
             yb = interpolate(yb1, yb2, b),
             zb = interpolate(zb1, zb2, b2b),
             D = sqrt((yb - yf)^2 + (zb - zf)^2),
             R = D/2 * cos30 + r * (1 - cos30),
             t = atan2(zb - zf, yb - yf),
             shift = yf + D/2)
        [for (a = [0 : da : (steps-1) * da])
            rotate_x_around(fillet_unit_hex_point(r/R, a)*R,
                            t, [0, -D/2, 0]) + [0, shift, zf]
        ]
    ];

    // Spherical dish with specified slope at the rim, tilted forward by the
    // specified angle
    dish_radius = R2 * sqrt(1 + 1/tan(slope)^2);
    dish_depth = dish_radius * (1 - cos(slope));
    //echo(true_excentricity=(exc + (1-cos(tilt))*R2 - sin(tilt)*dish_depth));

    steps_dish = max(2, floor(slope / da));
    da_dish = slope / steps_dish;
    n_points_dish = [for (b = [slope : -da_dish : 0])
        max(1, ceil(steps * sin(b) / sin(slope)))];
    points_dish = [for (i = [0 : 1 : steps_dish]) each
        let (b = (steps_dish - i) * da_dish, n = n_points_dish[i], da = 360 / n)
        [for (j = [0 : 1 : n-1]) let (a = j * da)
            rotate_x_around(dish_radius*sin(b)*[-sin(a), cos(a), 0] +
                            [0, 0, dish_radius*(1-cos(b)) - dish_depth],
                            tilt, [0, -R2, 0]) + [0, -exc, h]
        ]
    ];

    points = concat(points_cone, points_dish);

    face_bot = [for (i = [0 : 1 : steps-1]) i];
    faces_cone = [for (j = [0 : 1 : steps_cone-1]) each let (o = j * steps)
        [for (i = [0 : 1 : steps-1])
            [(i + 1) % steps + o, i + o, 
             steps + i + o, steps + (i + 1) % steps + o]
        ]
    ];
    o_dish = part_sums(n_points_dish);
    faces_dish1 = [for (j = [0 : 1 : steps_dish-1]) each let (
            o = o_dish[j] + len(points_cone),
            n = n_points_dish[j],
            m = n_points_dish[j + 1],
            r = m / n
        )
        [for (i = [0 : 1 : n-1])
            [(i + 1) % n + o, i + o,
             n + round((i + 0.5)*r) % m + o]
        ]
    ];
    faces_dish2 = [for (i = 1; i < len(faces_dish1); i = i + 1)
        if (faces_dish1[i-1][2] != faces_dish1[i][2])
            [faces_dish1[i-1][2], faces_dish1[i][2],
             faces_dish1[i][1]]
    ];

    faces = concat([face_bot], faces_cone, faces_dish1, faces_dish2);

    polyhedron(points, faces, convexity=2);
    
    // Some stats
    if ($show_stats) {
        point_center = points_dish[len(points_dish)-1];
        total_height = h + 2*R2*sin(tilt);
        mounted_height = total_height - h + $thickness;
        target_depth = -point_center.y/tan(tilt) - (point_center.z - h)
                     - $thickness;
        echo(total_height=total_height, mounted_height=mounted_height,
             dish_depth=dish_depth, target_depth=target_depth);
    }
}

// How far the the switch can be inserted into the bottom of the key
function key_offset() = let (
    exc = min($max_exc, $tilt/7.5),
    dish_radius = $dish_diam/2 * sqrt(1 + 1/tan($slope)^2),
    front_offset = $height - $thickness + 0.5,
    mid_offset = rotate_x_around(
        [0, -3, $height - $thickness - (1.0-cos($slope))*dish_radius], $tilt,
        [0, -exc - $dish_diam/2, $height - $thickness]).z)
    min(front_offset, mid_offset);

module key_stem() {
    linear_extrude(height = 4, convexity = 2) {
        polygon([
    [ 0.65,-1.5], [ 0.65,-0.5], [ 0.4,-0.5], [ 0.4,0.5], [ 0.65,0.5], [ 0.65,1.5],
    [-0.65,1.5], [-0.65,0.5], [-0.4,0.5], [-0.4,-0.5], [-0.65,-0.5], [-0.65,-1.5]
        ]);
    }
}

module difkey() {
    R1 = $key_width / 2;
    R2 = $dish_diam / 2;
    r1 = $fillet;
    r2 = R2;
    exc = min($max_exc, $tilt/7.5);
    Ri = R1 - $thickness;
    ri = max(0, r1 - $thickness);
    exc_i = exc - $thickness * sin($tilt);
    offset = key_offset();

    intersection() {
        union() {
            difference() {
                translate([0, 0, R1*1.5 + 0.01]) cube(R1*3, center=true);
                fillet_hexagon_cone(Ri, R2, ri, r2, exc_i,
                                    $tilt, $slope, $height-$thickness, da=7.5);
            }
            translate([0, 0, offset+3-0.5]) cube([10, 4.5, 6], center = true);
            translate([0, 0, offset+3    ]) cube([12, 6.5, 6], center = true);
        }
        fillet_hexagon_cone(R1, R2, r1, r2, exc,
                            $tilt, $slope, $height);
    }
    translate([-2.85, 0, offset - 3.5]) key_stem();
    translate([ 2.85, 0, offset - 3.5]) key_stem();
}

module minkey() {
    R1 = $key_width / 2;
    R2 = $dish_diam / 2;
    r1 = $fillet;
    r2 = R2;
    exc = min($max_exc, $tilt/7.5);
    offset = key_offset();

    render(convexity=4) intersection() {
        union() {
            minkowski() {
                difference() {
                    translate([0, 0, R1*1.5 + 0.01]) cube(R1*3, center=true);
                    fillet_hexagon_cone(R1, R2, r1, r2, exc,
                                        $tilt, $slope, $height, da=7.5);
                }
                intersection() {
                    sphere(r = $thickness, $fa = 30, $fs = $thickness * 2*PI * 30 / 360);
                    translate([0, 0, -2*$thickness]) cube($thickness*4, center = true);
                }
            }
            translate([0, 0, offset+3-0.5]) cube([10, 4.5, 6], center = true);
            translate([0, 0, offset+3    ]) cube([12, 6.5, 6], center = true);
        }
        fillet_hexagon_cone(R1, R2, r1, r2, exc,
                            $tilt, $slope, $height);
    }
    translate([-2.85, 0, offset - 3.5]) key_stem();
    translate([ 2.85, 0, offset - 3.5]) key_stem();
}

module key() {
    y0 = 5.5;
    dx = 2.3;
    dy = dx * sqrt(3)/2;
    hole_pos = [        [-1.5, 1],[-0.5, 1],[ 0.5, 1],[ 1.5,  1],
         [-3.0, 0],[-2.0, 0],[-1.0, 0],[ 0.0, 0],[ 1.0, 0],[ 2.0, 0],[ 3.0,  0],
    [-3.5,-1],[-2.5,-1],                                        [ 2.5,-1],[ 3.5,-1],
         [-3.0,-2],                                                  [ 3.0,-2],
    [-3.5,-3],                                                            [ 3.5,-3]];

    difference () {
        if ($minkowski)
            minkey();
        else
            difkey();
        if ($rgb) for (p = hole_pos)
            translate([dx * p.x, y0 + dy * p.y, 0]) rotate([0, 0, 30])
                cylinder($fn=6, h=10, d=1.6);
    }
}

// A key cut into slices to make the wall thickness visible
module sliced_key(slice=[30, 30, 1], dir=[0, 0, 1],
                  slice_list=[0,1,2,3,4,5,6,7], factor=2) {
    for(i = slice_list) {
        translate(dir*i*factor) intersection() {
            key($rgb = false);
            translate(dir*i) cube(slice, center=true);
        }
    }
}

module choc_switch() {
    color("gray") difference() {
        union() {
            linear_extrude(height = 2.21) {
                offset(r = 0.4) square(13, center = true);
            }
            translate([0, 0, 2.2]) linear_extrude(height = 0.8) {
                offset(r = 1.0) square(13, center = true);
            }
            translate([0, 0, -2]) cylinder(h = 2.01, d = 3.2);
            translate([0, 0, -2.65]) cylinder(h = 0.66, d1 = 2.8, d2 = 3.2);
            translate([-5.22, 0, -2   ]) cylinder(h = 2.01, d = 1.8);
            translate([-5.22, 0, -2.65]) cylinder(h = 0.66, d1 = 1.4, d2 = 1.8);
            translate([ 5.22, 0, -2   ]) cylinder(h = 2.01, d = 1.8);
            translate([ 5.22, 0, -2.65]) cylinder(h = 0.66, d1 = 1.4, d2 = 1.8);
        }
        translate([0, 0, 6.9]) cube(13, center = true);
        translate([0, 4.7, 0]) cube([5.3, 3.25, 2], center = true);
    }
    color("gold") translate([0, -5.9, -1]) rotate([90, 0, 0])
    linear_extrude(height = 0.2, center = true) {
        offset(r = 0.5) square([0.01, 3], center = true);
    }
    color("silver") translate([-5, -3.8, -1]) rotate([90, 0, 0])
    linear_extrude(height = 0.2, center = true) {
        offset(r = 0.5) square([0.01, 3], center = true);
    }
    color("rosybrown") translate([0, 0, 5+1.01-$travel]) difference() {
        union() {
            cube([10.2, 4.5, 4], center = true);
            translate([0, -2.74, 0]) cube([3, 1.02, 4], center = true);
        }
        translate([-2.85, 0, 0.51]) cube([1.2, 3, 3], center = true);
        translate([ 2.85, 0, 0.51]) cube([1.2, 3, 3], center = true);
        translate([0, -2.76, -0.5]) cube([2, 1.02, 4], center = true);
    }
    color("white", 0.4) difference() {
        union() {
            translate([0, 0, 2.99])
            linear_extrude(height = 2.01, scale = 0.9) {
                offset(r = 0.4) square([12.8, 13], center = true);
            }
            translate([0, 0, 4.99])
            linear_extrude(height = 0.51, convexity = 2, scale = 0.98) {
                offset(r = 0.4) polygon([
                [-5.7, -2.85], [-5.7,  2.85], [ 5.7,  2.85], [ 5.7, -2.85],
                [ 2.0, -2.85], [ 2.0, -1.85], [-2.0, -1.85], [-2.0, -2.85]
                ]);
            }
        }
        translate([0, 0, 2.98])
        linear_extrude(height = 1.62, scale = 0.9) {
            square(13, center = true);
        }
        translate([0, 0, 5]) cube([10.22, 4.52, 2], center = true);
        translate([0, -2.74, 5]) cube([3.02, 1.04, 2], center = true);
    }
}

module switch_key() {
    offset = key_offset();
    if ($show_stats)
        echo(key_offset = offset);
    if ($preview_switch_key)
        translate([0, 0, 5.5 + 3 - $travel - offset + $explode/5]) render(convexity = 10) key();
    choc_switch();
}

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
        linear_extrude(height = $mid_layer_height - 0.01, convexity = 10)
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
    color("orange") translate([-ex1/2, 0, 4.6 + ex2]) main_split();
    color("orange") translate([ ex1/2, 0, 4.6 + ex2]) mirror([1, 0, 0]) main_split();
    color("red") translate([0, 0, 8.4 + $mid_layer_height + ex5]) raised();

    color("white", alpha = 0.4) union() {
        translate([0, 0, 10.0 + $mid_layer_height + ex6]) plate_raised();

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
        linear_extrude(height = 3.8 + $mid_layer_height, convexity = 10)
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
        linear_extrude(height = $mid_layer_height + 0.01, convexity = 10)
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

        translate([0, 0, 8.4 + $mid_layer_height]) raised();
    }
}

module half_mantis() {
    hx = 21.5 + $explode/5;
    hy = -hx*cos30;
    dx = 3;
    dy = -dx/cos30;
    raise = 3.8 + $mid_layer_height + 3*$explode;
    translate([-4.5*hx-dx/2, -3*hy, 0]) {
        translate([0  *hx, 0*hy   ,     0]) rotate([0, 0,    0]) switch_key($tilt = $tilt2);
        translate([1  *hx, 0*hy   ,     0]) rotate([0, 0,  -60]) switch_key($tilt = $tilt2);
        translate([2  *hx, 0*hy   ,     0]) rotate([0, 0,  -60]) switch_key($tilt = $tilt2);
        translate([3  *hx, 0*hy   ,     0]) rotate([0, 0,  -60]) switch_key($tilt = $tilt2);
        translate([3.5*hx, 1*hy   , raise]) rotate([0, 0,  -60]) switch_key($tilt = $tilt2);
        translate([4  *hx, 2*hy   , raise]) rotate([0, 0,  -60]) switch_key($tilt = $tilt2);

        translate([0.5*hx, 1*hy   ,     0]) rotate([0, 0, -120]) switch_key();
        translate([1.5*hx, 1*hy   ,     0]) rotate([0, 0, -120]) switch_key();
        translate([2.5*hx, 1*hy   ,     0]) rotate([0, 0, -120]) switch_key();
        translate([3  *hx, 2*hy   , raise]) rotate([0, 0, -120]) switch_key();
        translate([3.5*hx, 3*hy   , raise]) rotate([0, 0, -120]) switch_key($tilt = $tilt2);

        translate([0  *hx, 2*hy   ,     0]) rotate([0, 0, -180]) switch_key($tilt = $tilt2);
        translate([1  *hx, 2*hy   ,     0]) rotate([0, 0, -180]) switch_key($tilt = $tilt2);
        translate([2  *hx, 2*hy   ,     0]) rotate([0, 0, -180]) switch_key($tilt = $tilt2);
        translate([2.5*hx, 3*hy   , raise]) rotate([0, 0, -180]) switch_key($tilt = $tilt2);

        translate([1.5*hx, 3*hy   ,     0]) rotate([0, 0, -180]) switch_key($tilt = $tilt2);
    
        translate([2  *hx, 4*hy+dy, raise]) rotate([0, 0,   60]) switch_key();
        translate([3  *hx, 4*hy+dy, raise]) rotate([0, 0,    0]) switch_key();
        translate([4  *hx, 4*hy+dy, raise]) rotate([0, 0,  -60]) switch_key();
    
        translate([3.5*hx, 5*hy+dy,     0]) rotate([0, 0,    0]) switch_key();
    }
}

if ($preview_mantis) { // Keyboard
    if ($preview_switch_key || $preview_switch) {
        translate([0, 0, 6.2 + 4*$explode]) half_mantis();
        translate([0, 0, 6.2 + 4*$explode]) mirror([1, 0, 0]) half_mantis();
    }
    mantis($fn = 36);
} else if ($preview_sound) { // sound channels (and some other voids)
    sound_channels($fn = 36);
} else if ($preview_switch_key) { // Single key with switch
    intersection() {
        switch_key();
        translate([-8.8, 0, 0]) cube(30, center = true);
    }
} else if ($preview_switch) { // Choc switch
    choc_switch();
} else if ($preview_exploded_key) { // Exploded view of key to show wall thickness
    %key($rgb = false);
    translate([0, 0, 15])  sliced_key([30, 30, 1], [0, 0, 1],
                                      [for (i = [-2.01 : 7.99]) i+0.5], 2);
    translate([0, -15, 0]) sliced_key([30, 1, 20], [0, 1, 0],
                                      [for (i = [-11 : 0]) i-0.5], 2);
    translate([0, 15, 0])  sliced_key([30, 1, 20], [0, 1, 0],
                                      [for (i = [0 : 11]) i+0.5], 2);
    translate([-15, 0, 0]) sliced_key([1, 30, 20], [1, 0, 0],
                                      [for (i = [-10 : 0]) i-0.5], 2);
    translate([15, 0, 0])  sliced_key([1, 30, 20], [1, 0, 0],
                                      [for (i = [0 : 10]) i+0.5], 2);
} else {
    key();
/*
    R1 = $key_width / 2;
    R2 = $dish_diam / 2;
    r1 = $fillet;
    r2 = R2;
    exc = min($max_exc, $tilt/7.5);
    slope = $slope;
    height = $height;
    fillet_hexagon_cone(R1, R2, r1, r2, exc,
                        $tilt, slope, height);
*/
}
//translate([0, 0, -2]) fillet_hexagon(21/2, 3, 2);
