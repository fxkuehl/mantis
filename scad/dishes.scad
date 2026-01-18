use <utils.scad>

function __points_helper(size) = [[-size/2, -size/2, -size],
                                  [ size/2, -size/2, -size],
                                  [ size/2,  size/2, -size],
                                  [-size/2,  size/2, -size]];

function __faces_helper(n) = let (
    n_top = (n + 1)^2,
    faces_top = [for (i = [0 : n-1]) each
        [for (j = [0 : n-1]) let (k = i * (n+1) + j)
            [k, k + n + 1, k + n + 2, k + 1]
        ]],
    face_front = concat([for (i = [0 : n])             i], [n_top+1, n_top  ]),
    face_left  = concat([for (i = [0 : n]) (n - i)*(n+1)], [n_top  , n_top+3]),
    face_right = concat([for (i = [0 : n])   i*(n+1) + n], [n_top+2, n_top+1]),
    face_back  = concat([for (i = [0 : n]) n_top - i - 1], [n_top+3, n_top+2]),
    face_bot   = [n_top, n_top + 1, n_top + 2, n_top + 3]
) concat(faces_top, [face_front, face_left, face_right, face_back, face_bot]);

function __offset_helper(points, n, o) = let (
    face_normals = [for (i = [0 : n-1])
        [for (j = [0 : n-1]) let (
            k = i * (n+1) + j,
            a = points[k+1] - points[k],
            b = points[k+n+1] - points[k],
            normal = [a.y*b.z - a.z*b.y,
                      a.z*b.x - a.x*b.z,
                      a.x*b.y - a.y*b.x]
        ) normal / norm(normal)]
    ],
    normals = [for (k = [0 : (n+1)^2 - 1]) let (
        i = floor(k / (n+1)), j = k % (n+1),
        sum = (i > 0 && j > 0 ? face_normals[i-1][j-1] : [0, 0, 0]) +
              (i > 0 && j < n ? face_normals[i-1][j  ] : [0, 0, 0]) +
              (i < n && j > 0 ? face_normals[i  ][j-1] : [0, 0, 0]) +
              (i < n && j < n ? face_normals[i  ][j  ] : [0, 0, 0])
    ) sum / norm(sum)]
) points + o*normals;

// All dishes below are defined as a cartesian grid on top of a
// size x size x size box with rim at z = 0. Common parameters:
//
// d - rim diameter
// alpha - rim slope angle
// _alpha - virtual rim slope angle for the side saddle
// size - bounding box size
// n - grid resolution
// o - offset along the normal vectors

// Parabolic dish
module parabolic_dish(d, alpha, _alpha, size, n, o = 0, side_saddle = false) {
    b = tan(alpha) / d;
    _b = side_saddle ? -tan(_alpha) / d : b;
    a = -b * (d/2)^2;
    points = [for (i = [0 : n]) each let (y = i * size / n - size/2)
        [for (j = [0 : n]) let (x = j * size / n - size/2)
            [x, y, a +
             (x > 0 ? _b : b) * x^2 +
             b * y^2]
        ]
    ];
    points_offset = o ? __offset_helper(points, n, o) : points;
    polyhedron(points = concat(points_offset, __points_helper(size)),
               faces = __faces_helper(n),
               convexity = 10);
}

// Spherical dish
//
// With d = 14, alpha = 15, the spherical dish is 0.01mm shallower than the
// parabolic one. Other than that, they are virtually identical.
module spherical_dish(d, alpha, size, n, o = 0) {
    r = d / (2*sin(alpha));
    o = sqrt(r^2 - (d/2)^2);
    points = [for (i = [0 : n]) each let (y = i * size / n - size/2)
        [for (j = [0 : n]) let (x = j * size / n - size/2)
            [x, y, o - sqrt(r^2 - (x^2 + y^2))]
        ]
    ];
    points_offset = o ? __offset_helper(points, n, o) : points;
    polyhedron(points = concat(points_offset, __points_helper(size)),
               faces = __faces_helper(n),
               convexity = 10);
}

// Saddle-shaped dish
//
// Parabolic in x-direction. 4th-order polynomial in y-direction with a
// small parabolic dip in the middle and sloping down beyond that.
//
// D - major diameter of the parabolic dish in x-direction
// d - minor diameter of the parabolic dip in y-direction
// side_saddle - Use 4th-order polynomial for positive x
//
// At x = 0, y = +-d/2 the slope is 0
module saddle_dish(D, d, alpha, size, n, o = 0, side_saddle = false) {
    b = tan(alpha) / D;
    a = -b * (D/2)^2;
    c = -2*b / d^2;
    _c = side_saddle ? c : 0;
    /*
    echo(a, b, c);
    echo("f(0,0)=", a);
    echo("f(D/2,0)=", b * (D/2)^2 + a);
    echo("f(0,d/2)=", c * (d/2)^4 + b * (d/2)^2 + a);
    echo("f(0,size/2)=", c * (size/2)^4 + b * (size/2)^2 + a);
    */
    points = [for (i = [0 : n]) each let (y = i * size / n - size/2)
        [for (j = [0 : n]) let (x = j * size / n - size/2)
            [x, y,
             c * y^4 + (x > 0 ? _c : 0) * x^4 +
             b * (x^2 + y^2) + a]
        ]
    ];
    points_offset = o ? __offset_helper(points, n, o) : points;
    polyhedron(points = concat(points_offset, __points_helper(size)),
               faces = __faces_helper(n),
               convexity = 10);
}

// Saddle-shaped dish with reverse parabolic side-saddle option
//
// Parabolic in x-direction. 4th-order polynomial in y-direction with a
// small parabolic dip in the middle and sloping down beyond that.
//
// D - major diameter of the parabolic dish in x-direction
// d - minor diameter of the parabolic dip in y-direction
// side_saddle - Use reverse parabola in to slope down for positive x
//
// At x = 0, y = +-d/2 the slope is 0
module saddle2_dish(D, d, alpha, _alpha, size, n, o = 0, side_saddle = false) {
    b = tan(alpha) / D;
    _b = side_saddle ? -tan(_alpha) / D : b;
    a = -b * (D/2)^2;
    c = -2*b / d^2;
    /*
    echo(a, b, c);
    echo("f(0,0)=", a);
    echo("f(D/2,0)=", b * (D/2)^2 + a);
    echo("f(0,d/2)=", c * (d/2)^4 + b * (d/2)^2 + a);
    echo("f(0,size/2)=", c * (size/2)^4 + b * (size/2)^2 + a);
    */
    points = [for (i = [0 : n]) each let (y = i * size / n - size/2)
        [for (j = [0 : n]) let (x = j * size / n - size/2)
            [x, y,
             c * y^4 + b * y^2 + a +
             (x > 0 ? _b : b) * x^2]
        ]
    ];
    points_offset = o ? __offset_helper(points, n, o) : points;
    polyhedron(points = concat(points_offset, __points_helper(size)),
               faces = __faces_helper(n),
               convexity = 10);
}

// Saddle-shaped dish with cubic side-saddle option
//
// Parabolic in x-direction. 4th-order polynomial in y-direction with a
// small parabolic dip in the middle and sloping down beyond that.
//
// D - major diameter of the parabolic dish in x-direction
// d - minor diameter of the parabolic dip in y-direction
// side_saddle - Use cubic curve in x direction to slope down for positive x
//
// At x = 0, y = +-d/2 the slope is 0
module saddle3_dish(D, d, alpha, size, n, o = 0, side_saddle = false) {
    b = tan(alpha) / D;
    c = -2*b / d^2;
    p = side_saddle ? 0 : b;
    q = side_saddle ? -tan(alpha) / (3 * (D/2)^2) : 0;
    a = side_saddle ? q * (D/2)^3 : -b * (D/2)^2;
    points = [for (i = [0 : n]) each let (y = i * size / n - size/2)
        [for (j = [0 : n]) let (x = j * size / n - size/2)
            [x, y,
             c * y^4 + b * y^2 + a +
             q * x^3 + p * x^2]
        ]
    ];
    points_offset = o ? __offset_helper(points, n, o) : points;
    polyhedron(points = concat(points_offset, __points_helper(size)),
               faces = __faces_helper(n),
               convexity = 10);
}

/*
color(alpha=1) render(convexity = 10) intersection() {
    saddle_dish(14, 14/sqrt(2), 15, 20, 80, o=1.4);
    //translate([0, 0, -15.01]) cube([30, 30, 30], center = true);
}*/
color(alpha=1) render(convexity = 10) difference() {
    intersection() {
        saddle2_dish(14, 14/sqrt(2), 15, 28, 20, 39, o=0, side_saddle=true);
        translate([0, 0, -15.01]) cube([30, 30, 35], center = true);
    }
    intersection() {
        translate([0, 0, -0.01]) saddle2_dish(14, 14/sqrt(2), 15, 28, 20, 39, o=-1.4, side_saddle=true);
        translate([0, 0, -16.4]) cube([30, 30, 35], center = true);
    }
}
