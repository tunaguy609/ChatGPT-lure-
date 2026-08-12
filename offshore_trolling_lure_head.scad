$fn = 220;

// Parameters
overall_length = 68.0;
max_diameter   = 32.0;
leader_bore    = 2.0;
skirt_diameter = 18.0;
skirt_length   = 12.0;

max_radius   = max_diameter / 2;
bore_radius  = leader_bore / 2;
skirt_radius = skirt_diameter / 2;

// Smoother profile with less mid-body waist
profile = [
    [0.0,  0.6],
    [2.0,  1.8],
    [4.0,  4.2],
    [6.5,  7.8],
    [9.0,  10.8],
    [12.0, 13.2],
    [16.0, 15.0],
    [20.0, max_radius],   // single apex
    [24.0, 16.0],
    [28.0, 16.4],
    [32.0, 16.8],
    [36.0, 17.2],
    [40.0, 17.2],
    [44.0, 17.0],
    [48.0, 16.6],
    [52.0, 16.0],
    [56.0, 15.2],
    [overall_length - skirt_length + 2.0, skirt_radius],
    [overall_length - skirt_length + 6.0, skirt_radius],
    [overall_length, skirt_radius]
];

module lure_2d_profile() {
    pts = concat(
        [for (p = profile) [p[1], p[0]]], // [x=radius, y=z]
        [[0, profile[len(profile)-1][0]], [0, profile[0][0]]]
    );
    offset(r=0) polygon(points = pts);
}

module lure_body() {
    rotate_extrude(convexity = 20, $fn = 6)
        lure_2d_profile();
}

module center_bore() {
    translate([0,0,-1])
        cylinder(h = overall_length + 2, r = bore_radius);
}

// Final model
scale([0.5, 0.5, 0.5])
difference() {
    lure_body();
    center_bore();
}
