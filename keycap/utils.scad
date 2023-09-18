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

function part_sums(seq) = [for (a = 0, i = 0; i <= len(seq);
                                a = a + seq[min(i, len(seq)-1)],
                                i = i + 1) a];

// Faces filling the space between concentric rings of points with
// shrinking numbers of points per ring towards the center
function concentric_faces(n, n_points, offset = 0) = let (
    offsets = part_sums(n_points),
    faces1 = [for (i = [0 : n - 1]) each let (
            o = offsets[i] + offset,
            ni = n_points[i],
            ni_1 = n_points[i + 1],
            ratio = ni_1 / ni
        )
        [for (j = [0 : ni - 1])
            [(j + 1) % ni + o, j + o,
             ni + round((j + 0.5) * ratio) % ni_1 + o]
        ]
    ],
    faces2 = [for (i = [0 : n - 2]) each let (
            o = offsets[i],
            ni = n_points[i]
        )
        [for (i = 0; i < ni; i = i + 1)
            if (faces1[i + o][2] != faces1[(i + 1) % ni + o][2])
                [faces1[i + o][2], faces1[(i + 1) % ni + o][2],
                 faces1[i + o][0]]
        ]
    ]) concat(faces1, faces2);

// Half sphere with optimized number of faces for faster minkowski sums
module half_sphere(r) {
    n = max(2, ceil(90 / $fa));
    da = 90 / n;
    n_points = concat([for (a = [0 : da : 89.9])
            max(3, ceil(cos(a) * 360 / $fa))
        ], [1]);
    points = [for (i = [0 : n]) each let (a = da * i, q = r * cos(a))
        [for (j = [0 : n_points[i] - 1]) let (b = 360 / n_points[i] * j)
            [q * sin(b), q * cos(b), -r * sin(a)]/*[i, j, a, b]*/
        ]
    ];

    face_top = [for (i = [0 : n_points[0] - 1]) i];
    faces = concat([face_top], concentric_faces(n, n_points));
        
    polyhedron(points, faces);
}

half_sphere(3, $fa = 360 / 16);