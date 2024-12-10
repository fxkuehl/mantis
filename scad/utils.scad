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

function scale_x(point, factor) = [point.x * factor, point.y, point.z];

// Soft clamping of z coordinates using hyperbola
// z1: z value to start clamping at
// z2: asymptotic maximum z value
// Uses an inverted hyperbolic functon to compress z values
// from [z1, inf) into the range [z1, z2)
function clamp_z_hyper(points, z1, z2) = let (d = z2 - z1)
    [for (p = points)
        [p.x, p.y, p.z < z1 ? p.z :
         z2 - d / (1 + (p.z - z1) / d)]
    ];

// Soft clamping of z coordinates using exponential function
// z1: z value to start clamping at
// z2: asymptotic maximum z value
// Uses an inverted exponential functino to compress z values
// from [z1, inf) into the range [z1, z2)
function clamp_z_exp(points, z1, z2) = let (d = z2 - z1)
    [for (p = points)
        [p.x, p.y, p.z < z1 ? p.z :
         z2 - d * exp((z1 - p.z) / d)]
    ];

function part_sums(seq) = [for (a = 0, i = 0; i <= len(seq);
                                a = a + seq[min(i, len(seq)-1)],
                                i = i + 1) a];

// Faces filling the space between concentric rings of points with
// shrinking numbers of points per ring towards the center
function concentric_faces(n, n_points, offset = 0, staggered = false) = let (
    offsets = part_sums(n_points),
    faces0 = [if (n_points[0] == 1 && n > 1)
        for (i = [0 : n_points[1] - 1])
            [0, i + 1, (i + 1) % n_points[1] + 1]
    ],
    faces1 = [for (i = [0 : n - 1]) each let (
            o = offsets[i] + offset,
            ni = n_points[i],
            ni_1 = n_points[i + 1],
            ratio = ni_1 / ni,
            s = staggered ? (i % 2) : 0.5
        )
        [for (j = [0 : ni - 1])
            [(j + 1) % ni + o, j + o,
             ni + round((j + s) * ratio) % ni_1 + o]
        ]
    ],
    faces2 = [for (i = [0 : n - 1]) each let (
            o = offsets[i],
            o_1 = offsets[i + 1],
            ni = n_points[i],
            ni_1 = n_points[i + 1]
        )
        [for (i = 0; i < ni; i = i + 1)
            for (j = faces1[i + o][2]; j != faces1[(i + 1) % ni + o][2];
                 j = (j - o_1 + 1) % ni_1 + o_1)
                [j, (j - o_1 + 1) % ni_1 + o_1, faces1[i + o][0]]
        ],
    ],
    faces1_ = [for (f = faces1)
                   if (f[0] != f[1] && f[1] != f[2] && f[2] != f[0]) f]/*,
    total = len(faces0)+len(faces1_)+len(faces2),
    reduction = (n_points[0] == 1 ? 1 : 0) +
                (n_points[n] == 1 ? 1 : 0),
    dumb = max(n_points) * (n*2 - reduction),
    dummy = echo("Reduced faces from ", dumb, "to", total,
                 " saving ", 100 * (dumb - total) / dumb, "%")*/
) concat(faces0, faces1_, faces2);

function fa_from_fs(radius) = 360 / max(3, ceil(6.2832 * radius / $fs));

// Half sphere with optimized number of faces for faster minkowski sums
module half_sphere(r, staggered = true) {
    n = max(2, ceil(90 / $fa));
    da = 90 / n;
    n_points = concat([for (a = [0 : da : 89.9])
            max(3, ceil(cos(a) * 360 / $fa))
        ], [1]);
    points = [for (i = [0 : n]) each let (
            a = da * i,
            q = r * cos(a),
            s = staggered ? (i % 2) / 2 : 0
        )
        [for (j = [0 : n_points[i] - 1]) let (b = 360 / n_points[i] * (j + s))
            [q * sin(b), q * cos(b), -r * sin(a)]/*[i, j, a, b]*/
        ]
    ];

    face_top = [for (i = [0 : n_points[0] - 1]) i];
    faces = concat([face_top], concentric_faces(n, n_points, 0, staggered));

    polyhedron(points, faces);
}

// Full sphere with optimized number of faces for faster minkowski sums
module full_sphere(r, staggered = true) {
    n = max(2, ceil(180 / $fa));
    da = 180 / n;
    n_points = concat([1], [for (a = [-90+da : da : 89.9])
            max(3, ceil(cos(a) * 360 / $fa))
        ], [1]);
    points = [for (i = [0 : n]) each let (
            a = -90 + da * i,
            q = r * cos(a),
            s = staggered ? (i % 2) / 2 : 0
        )
        [for (j = [0 : n_points[i] - 1]) let (b = 360 / n_points[i] * (j + s))
            [q * sin(b), q * cos(b), -r * sin(a)]/*[i, j, a, b]*/
        ]
    ];

    faces = concentric_faces(n, n_points, 0, staggered);

    polyhedron(points, faces);
}

// Sphere that takes its resolution from $fs and corrects its size to
// make low resolution spheres look about the correct
module corr_sphere(r, override_fa = 0) {
    fa = override_fa ? override_fa : fa_from_fs(r);
    n = ceil(360 / fa);
    // Correct the size to balance the error of being outside and inside
    // of the circle by making the area of the circle section equal to the
    // area of the triangle with corrected radius.
    a_section = 3.1415927 / n;
    half_angle = 360 / (2*n);
    a_triangle = sin(half_angle) * cos(half_angle);
    corr = sqrt(a_section / a_triangle);
    full_sphere(r * corr, true, $fa=fa);
}

//full_sphere(3, true, $fa = 360 / 8);
color("red") corr_sphere(2.5/2, $fs=1.8);
color("white", alpha=0.5) corr_sphere(2.5/2, $fs=0.1);

translate([0, 0, -1.5]) color("red") half_sphere(2.5/2, $fa=360/20);
