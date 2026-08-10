$fn = 160;

// Parameters
overall_length = 68.0;
max_diameter   = 32.0;
leader_bore    = 2.0;
skirt_diameter = 18.0;
skirt_length   = 12.0;

max_radius   = max_diameter / 2;
bore_radius  = leader_bore / 2;
skirt_radius = skirt_diameter / 2;

// Strictly increasing Z, radius always > 0
profile = [
    [0.0, 0.6],
    [2.0, 1.8],
    [4.0, 4.2],
    [6.5, 7.8],
    [9.0, 10.8],
    [12.0, 13.2],
    [15.0, 14.8],
    [20.0, 15.6],
    [24.0, max_radius],
    [30.0, 15.7],
    [36.0, 15.2],
    [42.0, 14.5],
    [48.0, 13.2],
    [53.0, 11.0],
    [56.0, 9.0],
    [overall_length - skirt_length + 2.0, skirt_radius],
    [overall_length - skirt_length + 6.0, skirt_radius],
    [overall_length, skirt_radius]
];

module lure_2d_profile() {
    // Build closed 2D polygon in XY:
    // outer curve (x=radius, y=z), then back along axis at x=0
    pts = concat(
        [for (p = profile) [p[1], p[0]]],
        [[0, profile[len(profile)-1][0]], [0, profile[0][0]]]
    );
    // offset(r=0) often fixes minor polygon validity issues
    offset(r=0) polygon(points = pts);
}

module lure_body() {
    rotate_extrude(convexity = 20)
        lure_2d_profile();
}

module center_bore() {
    translate([0,0,-1])
        cylinder(h = overall_length + 2, r = bore_radius);
}

difference() {
    lure_body();
    center_bore();
}
