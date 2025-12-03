function rotate_x(point, angle) = let (sin_a = sin(angle), cos_a = cos(angle)) [
    point.x,
    point.y*cos_a - point.z*sin_a,
    point.z*cos_a + point.y*sin_a
];
function rotate_x_around(point, angle, origin=[0, 0, 0]) =
    rotate_x(point - origin, angle) + origin;

function rotate_z(point, angle) = let (sin_a = sin(angle), cos_a = cos(angle)) [
    point.x*cos_a - point.y*sin_a,
    point.y*cos_a + point.x*sin_a,
    point.z
];
function rotate_z_around(point, angle, origin=[0, 0, 0]) =
    rotate_z(point - origin, angle) + origin;

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

function wrap(vec, i) = let (n = len(vec)) vec[(i + n) % n];

/* Create a point list of an offset, filleted polygon
 *
 * point_list - Template polygon, ordered counter-clockwise
 * offset - How much to grow or shrink the polygon
 * fi - inside fillet radius (for concave corners)
 * fo - outside fillet radius (for convex corners)
 * corner_points - Number of points in each fillet
 *
 * All fillets have the same number of points. This allows easy construction
 * of polyhedron faces when stacking many polygons with varying fillet radii.
 *
 * Limitations:
 * - corner angles must be > 0°
 * - Doesn't support  merging of neighboring fillet arcs if the vertices
 *   are too close together
 */
function offset_fillet_poly(points, offset, fi, fo, corner_points) = let (
    n = len(points),
    corners = [for (i = [0:n-1]) let (
        p0 = points[i],
        d1 = wrap(points, i-1) - p0, d2 = wrap(points, i+1) - p0,
        u1 = d1 / norm(d1), u2 = d2 / norm(d2),
        v0 = -u1 - u2, u0 = v0 / norm(v0), w0 = [u0.y, -u0.x],
        r1 = [-u1.y, u1.x], s = r1 * u2 < 0 ? -1 : 1,
        beta = acos(u1 * u2) / 2, gamma = 90 - beta,
        c = s * offset / sin(beta),
        f = s < 0 ? fi : fo
    )  [p0 + u0 * (c - f/cos(gamma)), u0, w0, f, s*gamma]]
) /*echo(corners)*/ [for (c = corners) each let (
        pc = c[0], u0 = c[1], w0 = c[2], f = c[3], gamma = c[4]
    ) [for (t = [-gamma : 2*gamma/corner_points : gamma])
        pc + f*u0 * cos(t) + f*w0 * sin(t)]];

/* Create a point list of an offset, filleted polygon v2
 *
 * point_list - Template polygon, ordered counter-clockwise
 * offset - How much to grow or shrink the polygon
 * fi - inside fillet radius (for concave corners)
 * di - inside apex offset
 * fo - outside fillet radius (for convex corners)
 * do - outside apex offset
 * corner_points - Number of points in each fillet
 *
 * di and do modify the fillet radii in order to offset the apex by the
 * specified amount.
 *
 * All fillets have the same number of points. This allows easy construction
 * of polyhedron faces when stacking many polygons with varying fillet radii.
 * di and do offset the fillet radius to move the apex of the fillet in or
 * out by the specified amount.
 *
 * Limitations:
 * - corner angles must be > 0°
 * - Doesn't support  merging of neighboring fillet arcs if the vertices
 *   are too close together
 */
function offset_fillet_poly2(points, offset, fi, di, fo, do, corner_points)
= let (
    n = len(points),
    corners = [for (i = [0:n-1]) let (
        p0 = points[i],
        d1 = wrap(points, i-1) - p0, d2 = wrap(points, i+1) - p0,
        u1 = d1 / norm(d1), u2 = d2 / norm(d2),
        v0 = -u1 - u2, u0 = v0 / norm(v0), w0 = [u0.y, -u0.x],
        r1 = [-u1.y, u1.x], s = r1 * u2 < 0 ? -1 : 1,
        beta = acos(u1 * u2) / 2, gamma = 90 - beta,
        c = s * offset / sin(beta),
        df = 1 / (1 / sin(beta) - 1),
        f = s < 0 ? fi + di*df : fo + do*df
    )  [p0 + u0 * (c - f/cos(gamma)), u0, w0, f, s*gamma]]
) /*echo(corners)*/ [for (c = corners) each let (
        pc = c[0], u0 = c[1], w0 = c[2], f = c[3], gamma = c[4]
    ) [for (t = [-gamma : 2*gamma/corner_points : gamma])
        pc + f*u0 * cos(t) + f*w0 * sin(t)]];

// Helper to add a z-coordinate to 2D points
function at_z(points, z) = [for (p = points) [p.x, p.y, z]];

// Polyhedron with variable fillets along z
// points: points of a polygon describing the outline in x-y plane
// h: height
// o: offset in x-y plane
// fxy: fillet in x-y plane of the bulk
// f_edge: fillet of the top/bottom edge
// f_corner: fillet of the corners
// f_style: edge/corner fillet style (0: chamfer, 1: root, 2: circle, 3: parabola)
// round_bottom: true if bottom side is fillet, false if bottom is flat
module fillet_polyhedron(points, h, o, fxy, f_edge, f_corner,
                         f_style, round_bottom=true, round_top=true) {
    assert(f_edge <= f_corner);
    fillet_style = f_style % 4;
    invert = (f_style >= 4);

    n = len(points);                    // # corners
    m = round(3.1416 / 3 * fxy / $fs);  // points per corner
    p = n * (m + 1);                    // points per polygon
    ac = 1 / f_corner;                  // parabolic coefficient for corners
    ae = 1 / f_edge;                    // parabolic coefficient for edges
    zc1 = f_corner;                     // z-height of corner fillets
    ze1 = f_edge;                       // z-height of edge fillets
    q = round(zc1 * 1.5708 / $fs);      // # corner fillet layers one side
    Q = (round_bottom ? q : 0) + (round_top ? q : 0);
                                        // # corner fillet layers top+bottom
    //echo(ac, zc1, q);

    bottom = at_z(round_bottom ?
        offset_fillet_poly2(points, o-f_edge, fxy+f_edge, 0,
                            fxy-f_edge, f_corner-f_edge, m) :
        offset_fillet_poly(points, o, fxy, fxy, m), 0);
    top = at_z(round_top ?
        offset_fillet_poly2(points, o-f_edge, fxy+f_edge, 0,
                            fxy-f_edge, f_corner-f_edge, m) :
        offset_fillet_poly(points, o, fxy, fxy, m), h);

    fillet = [for (i = [1 : q]) let (
        z = f_style == 2 ? cos(90*i/q) * zc1 :
            f_style == 6 ? (1 - sin(90*i/q)) * zc1 :
            f_style == 3 ? zc1 - ac * (i/q*f_corner)^2 :
            f_style == 7 ? ac * ((1-i/q)*f_corner)^2 :
                           (1 - i/q) * zc1,
        _ze = max(0, z - zc1 + ze1),
        ze = invert ? ze1 - _ze : _ze,
        zc = invert ? zc1 - z : z,
        _re = fillet_style == 0 ? ze :
              fillet_style == 1 ? ae * ze^2 :
              fillet_style == 2 ? ze1 - sqrt(f_edge^2 - ze^2) :
                                  f_edge - sqrt((ze1 - ze)/ae),
        _rc = fillet_style == 0 ? zc :
              fillet_style == 1 ? ac * zc^2 :
              fillet_style == 2 ? zc1 - sqrt(f_corner^2 - zc^2) :
                                  f_corner - sqrt((zc1 - zc)/ac),
        re = invert ? f_edge - _re : _re,
        rc = invert ? f_corner - _rc : _rc
    ) at_z(offset_fillet_poly2(points, o - re, fxy + re, 0,
                               fxy - re, rc - re, m), z)];

    bottom_fillet = round_bottom ? [for (i = [0 : q-1])
        for(p = fillet[i]) [p.x, p.y, zc1 - p.z]] : [];
    top_fillet = round_top ? [for (i = [q-1 : -1  : 0])
        for(p = fillet[i]) [p.x, p.y, h - zc1 + p.z]] : [];
    points = concat(bottom, bottom_fillet, top_fillet, top);

    bottom_face = [for (i = [p-1 : -1 : 0]) i];
    top_face = [for (i = [p * (1 + Q) : p * (2 + Q) - 1]) i];
    side_faces = [for (i = [0 : Q]) each
        [for (j = [0 : p-1]) each
            [[i*p + j, i*p + (j+1)%p, (i+1)*p + (j+1)%p],
             [i*p + j, (i+1)*p + (j+1)%p, (i+1)*p + j]]
        ]
    ];
    faces = concat([bottom_face, top_face], side_faces);
    polyhedron(points, faces, convexity=10);
}

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
/*
color("red") corr_sphere(2.5/2, $fs=1.8);
color("white", alpha=0.5) corr_sphere(2.5/2, $fs=0.1);

translate([0, 0, -1.5]) color("red") half_sphere(2.5/2, $fa=360/20);
*/

/*
poly = [[-10, 0], [0, 5], [10, 0], [10, -10], [0, -5], [-10, -10]];
x = offset_fillet_poly(poly, 1, 2, 2, 5);

color("grey") polygon(poly);
color("red") translate([0, 0, -1.1]) polygon(x);
color("red") translate([0, -12.5, -1.1]) polygon(x);
*/