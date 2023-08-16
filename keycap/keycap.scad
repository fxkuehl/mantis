// Angular resolution
$fa = 2;
// Whether to render RGB LED cutouts in the keycaps
$rgb = true;
// Whether to use a minkowski sum for more consistent thickness
$minkowski = false;

// Key parameters:
// Tilt angle of the keycap surface
$tilt = 15;
// Slope angle of the dish at the rim
$slope = 15;
// Droop from the stem interface to the base of the key
$droop = 1.5;
// Rise from the stem interface to the front rim of the dish (minus thickness)
$rise = -0.5;
// Approximate thickness of the wall
$thickness = 1.4;
// Width of the hexagonal key
$key_width = 20.96;
// Diameter of the spherical dish
$dish_diam = 14;
// Fillet radius
$fillet = 3;
// Maximum dish excentricity (tilt / 7.5)
$max_exc = 2.5;

// How far the keys are pressed down (0-3mm)
travel = 0.1;
// Mantis plate explosion offset
$explode = 0;
// Set by files including this one
no_key = false;
// Show the key
show_key = true;
// Show the switch
show_switch = false;
// One key sliced and exploded to show wall thickness
show_sliced_key = false;
// Print some key stats
$print_stats = false;

use <utils.scad>

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

    // parabola for interpolating zf-coordinates that is
    // 0 at b=0
    // 1 at b=1
    // has slope s at b=1 (the rim) that matches the slope of the dish
    sf = tan(tilt-slope) * (yf2 - yf1) / (zf2 - zf1);
    af = sf - 1;
    bf = 2 - sf;

    // parabola for interpolating yb-coordinates that is
    // 0 at b = 0
    // 1 at b = 1
    // has slope s at b=0 (the outside edge) that matches the slope at the
    // front edge of the key
    sb = -0.5 * (zb2 - zb1) / (yb2 - yb1);
    ab = 1 - sb;
    bb = sb;

    steps_cone = max(3, floor(steps / 15));
    points_cone = [for (b = [0 : 1/steps_cone : 1 - 1/steps_cone]) each
        let (b2f = b * (af*b + bf),
             b2b = b * (ab*b + bb),
             r = interpolate(r1, r2, b2f),
             yf = interpolate(yf1, yf2, b),
             zf = interpolate(zf1, zf2, b2f),
             yb = interpolate(yb1, yb2, b2b),
             zb = interpolate(zb1, zb2, b),
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
    if ($print_stats) {
        point_center = points_dish[len(points_dish)-1];
        total_height = h + 2*R2*sin(tilt);
        mounted_height = total_height - h + $thickness;
        target_depth = -point_center.y/tan(tilt) - (point_center.z - h)
                     - $thickness;
        echo(total_height=total_height, mounted_height=mounted_height,
             dish_depth=dish_depth, target_depth=target_depth,
             center_y=point_center.y, center_z=point_center.z);
    }
}

// How far the the switch can be inserted into the bottom of the key
function key_offset() = let (
    exc = min($max_exc, $tilt/7.5),
    dish_radius = $dish_diam/2 * sqrt(1 + 1/tan($slope)^2),
    dish_depth = (1.0-cos($slope))*dish_radius,
    front_offset = $droop + $rise + 0.5,
    mid_offset = rotate_x_around(
        [0, -3, $droop + $rise - dish_depth], $tilt,
        [0, -exc - $dish_diam/2, $droop + $rise]).z)
    min(front_offset, mid_offset);

module choc_peg() {
    r = 0.1;
    module cross_section() {
        offset(r = -2*r) offset(delta = r) polygon([
    [ 0.65,-1.5], [ 0.65,-0.4], [ 0.449,-0.4], [ 0.449,0.4], [ 0.65,0.4], [ 0.65,1.5],
    [-0.65,1.5], [-0.65,0.4], [-0.449,0.4], [-0.449,-0.4], [-0.65,-0.4], [-0.65,-1.5]
        ]);
    }
    translate([0, 0, r]) minkowski() {
        linear_extrude(height = 4 - 2*r, convexity = 2) {
            cross_section();
        }
        half_sphere(r, $fa = 360/$fn);
    }
}

module choc_stem(offset) {
    translate([0, 0, offset]) difference() {
        translate([0, 0, 3]) union() {
            linear_extrude(height = 6, center = true) {
                offset(r = 2) offset(delta = -2) square([12, 6.5], center = true);
            }
            linear_extrude(height = 7, center = true) {
                offset(r = 1) offset(delta = -1) square([10, 4.5], center = true);
            }
            translate([0, 0, -3.5]) cube([8.3, 2.8, 0.502], center = true);
        }
        translate([-1.65, 0, -0.751]) rotate([90, 0, 0])
            cylinder(3, r = 0.751, center = true);
        translate([1.65, 0, -0.751]) rotate([90, 0, 0])
            cylinder(3, r = 0.751, center = true);

        translate([0, 0, -0.5]) cube([3.3, 3, 1], center = true);
        translate([0, 0, -0.751]) intersection() {
            union() {
                translate([-4.05, 0, 0])  rotate([90, 0, 0])
                    cylinder(3, r = 0.751, center = true);
                translate([4.05, 0, 0]) rotate([90, 0, 0])
                    cylinder(3, r = 0.751, center = true);
            }
            cube([8.5, 3, 1.502], center = true);
        }
    }

    translate([-2.85, 0, offset - 3.5]) choc_peg($fn = $fn/2);
    translate([ 2.85, 0, offset - 3.5]) choc_peg($fn = $fn/2);
}

module difkey(detail = 32) {
    R1 = $key_width / 2;
    R2 = $dish_diam / 2;
    r1 = $fillet;
    r2 = R2;
    exc = min($max_exc, $tilt/7.5);
    Ri = R1 - $thickness;
    ri = max(0, r1 - $thickness);
    exc_i = exc - $thickness * sin($tilt);
    height = $droop + $rise + $thickness;
    height_i = $droop + $rise;
    max_offset = key_offset();
    if ($droop > max_offset) {
        echo("Warning: key interferes with switch. Increase $rise by",
             $droop - max_offset);
    }

    intersection() {
        union() {
            difference() {
                translate([0, 0, R1*1.5 + 0.01]) cube(R1*3, center=true);
                fillet_hexagon_cone(Ri, R2, ri, r2, exc_i,
                                    $tilt, $slope, height_i, da=5,
                                    $print_stats=false);
            }
            choc_stem($droop, $fn = detail);
        }
        union() {
            fillet_hexagon_cone(R1, R2, r1, r2, exc,
                                $tilt, $slope, height);
            translate([0, 0, -4.99]) cube(10, center = true);
        }
    }
}

module minkey(detail = 32) {
    R1 = $key_width / 2;
    R2 = $dish_diam / 2;
    r1 = $fillet;
    r2 = R2;
    exc = min($max_exc, $tilt/7.5);
    height = $droop + $rise + $thickness;
    max_offset = key_offset();
    if ($droop > max_offset) {
        echo("Warning: key interferes with switch. Increase $rise by",
             $droop - max_offset);
    }

    intersection() {
        union() {
            minkowski() {
                difference() {
                    translate([0, 0, R1*1.5 + 0.01]) cube(R1*3, center=true);
                    fillet_hexagon_cone(R1, R2, r1, r2, exc,
                                        $tilt, $slope, height, da=5,
                                        $print_stats=false);
                }
                half_sphere($thickness, $fa = 360/16);
            }
            choc_stem($droop, $fn = detail);
        }
        union() {
            fillet_hexagon_cone(R1, R2, r1, r2, exc,
                                $tilt, $slope, height);
            translate([0, 0, -4.99]) cube(10, center = true);
        }
    }
}

module key(detail = 32) {
    y0 = 5.5;
    dx = 2.3;
    dy = dx * sqrt(3)/2;
    hole_pos = [        [-1.5, 1],[-0.5, 1],[ 0.5, 1],[ 1.5,  1],
         [-3.0, 0],[-2.0, 0],[-1.0, 0],[ 0.0, 0],[ 1.0, 0],[ 2.0, 0],[ 3.0,  0],
    [-3.5,-1],[-2.5,-1],                                        [ 2.5,-1],[ 3.5,-1],
         [-3.0,-2],                                                  [ 3.0,-2],
    [-3.5,-3],                                                            [ 3.5,-3]];

    render(convexity=8) difference () {
        if ($minkowski)
            minkey(detail);
        else
            difkey(detail);
        if ($rgb) for (p = hole_pos)
            translate([dx * p.x, y0 + dy * p.y, 0]) rotate([0, 0, 30])
                cylinder($fn=6, h=10, d=1.6);
    }
}

// A key cut into slices to make the wall thickness visible
module sliced_key(slice=[30, 30, 1], offset=[0, 0, 0], dir=[0, 0, 1],
                  slice_list=[0,1,2,3,4,5,6,7], factor=2) {
    for(i = slice_list) {
        translate(dir*i*factor) render(convexity = 10) intersection() {
            key($rgb = false);
            translate(dir*i + offset) cube(slice, center=true);
        }
    }
}

module choc_switch() {
    color("gray") render(convexity = 4) difference() {
        union() {
            linear_extrude(height = 0.701, scale = 1.05) {
                offset(r = 0.6/1.05) square(12.6/1.05, center = true);
            }
            translate([0, 0, 0.7]) linear_extrude(height = 1.51) {
                offset(r = 0.6) square(12.6, center = true);
            }
            translate([0, 0, 2.2]) linear_extrude(height = 0.8) {
                offset(r = 1.2) square(12.6, center = true);
            }
            translate([0, 0, -2]) cylinder(h = 2.01, d = 3.2);
            translate([0, 0, -2.65]) cylinder(h = 0.66, d1 = 2.8, d2 = 3.2);
            translate([-5.22, 0, -2   ]) cylinder(h = 2.01, d = 1.8);
            translate([-5.22, 0, -2.65]) cylinder(h = 0.66, d1 = 1.4, d2 = 1.8);
            translate([ 5.22, 0, -2   ]) cylinder(h = 2.01, d = 1.8);
            translate([ 5.22, 0, -2.65]) cylinder(h = 0.66, d1 = 1.4, d2 = 1.8);
        }
        translate([0, 0, 6.9]) cube(12.65, center = true);
        translate([0, 4.7, 0]) cube([5.3, 3.25, 2], center = true);
        translate([7.4, 0, 2.5]) cube([1, 10.8, 1], center = true);
        translate([-7.4, 0, 2.5]) cube([1, 10.8, 1], center = true);
    }
    color("gold") translate([0, -5.9, -1]) rotate([90, 0, 0])
    linear_extrude(height = 0.2, center = true) {
        offset(r = 0.5) square([0.01, 3], center = true);
    }
    color("silver") translate([-5, -3.8, -1]) rotate([90, 0, 0])
    linear_extrude(height = 0.2, center = true) {
        offset(r = 0.5) square([0.01, 3], center = true);
    }
    color("red") translate([0, 0, 5+1.01-travel]) render(convexity = 4) difference() {
        union() {
            cube([10.2, 4.5, 4], center = true);
            translate([0, -2.74, 0]) cube([3, 1.02, 4], center = true);
        }
        translate([-2.85, 0, 0.51]) cube([1.2, 3, 3], center = true);
        translate([ 2.85, 0, 0.51]) cube([1.2, 3, 3], center = true);
        translate([0, -2.76, -0.5]) cube([2, 1.02, 4], center = true);
    }
    color("white", 0.2) render(convexity = 4) difference() {
        union() {
            translate([0, 0, 2.99])
            linear_extrude(height = 0.51) {
                offset(r = 0.6) square([12.4, 12.6], center = true);
            }
            translate([0, 0, 3.499])
            linear_extrude(height = 1.501, scale = 0.9) {
                offset(r = 0.6) square([12.4, 12.6], center = true);
            }
            translate([0, 0, 4.99])
            linear_extrude(height = 0.51, convexity = 2, scale = 0.96) {
                offset(r = 0.4) polygon([
                [-5.7, -2.85], [-5.7,  2.85], [ 5.7,  2.85], [ 5.7, -2.85],
                [ 2.0, -2.85], [ 2.0, -1.85], [-2.0, -1.85], [-2.0, -2.85]
                ]);
            }
        }
        translate([0, 0, 2.98])
        linear_extrude(height = 1.52, scale = 0.9) {
            square(12.65, center = true);
        }
        translate([0, 0, 5]) cube([10.22, 4.52, 2], center = true);
        translate([0, -2.74, 5]) cube([3.02, 1.04, 2], center = true);
    }
}

module switch_key() {
    if (show_key)
        translate([0, 0, 5.5 + 3 - travel - $droop + $explode/5]) render(convexity = 10) key(detail = 8);
    choc_switch();
}

if (no_key) {
    // nothing
} else if (show_switch && show_key) { // Single key with switch
    intersection() {
        switch_key($fn = 32);
        color("white", 0.75) translate([-8.8, 0, $explode/2]) cube([30, 30, 30+$explode], center = true);
    }
} else if (show_switch) { // Choc switch
    choc_switch($fn = 32);
} else if (show_sliced_key) { // Sliced view of key to show wall thickness
    %render(convexity = 10) intersection() {
        key($rgb = false);
        translate([-15, 0, 0]) cube(30, center = true);
    }
    translate([0, 0, 15])  sliced_key([30, 30, 1], [-15, 0, 0], [0, 0, 1],
                                      [for (i = [-2.01 : 7.99]) i+0.5], 2);
    translate([0, -15, 0]) sliced_key([30, 1, 20], [-15, 0, 0], [0, 1, 0],
                                      [for (i = [-11 : 0]) i-0.5], 2);
    translate([0, 15, 0])  sliced_key([30, 1, 20], [-15, 0, 0], [0, 1, 0],
                                      [for (i = [0 : 11]) i+0.5], 2);
    translate([-15, 0, 0]) sliced_key([1, 30, 20], [0, 0, 0], [1, 0, 0],
                                      [for (i = [-10 : 0]) i-0.5], 2);
} else {
    key();
}
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
//translate([0, 0, -2]) fillet_hexagon(21/2, 3, 2);
