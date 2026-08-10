//
// 32mm OFFSHORE TROLLING LURE HEAD
// Parametric OpenSCAD Design
//
// All dimensions are in millimeters.
//

$fn = 160;


// ============================================================
// USER PARAMETERS
// ============================================================

// Overall dimensions
overall_length = 68.0;
max_diameter   = 32.0;

// Center leader bore
leader_bore = 2.0;

// Front concave cup
cup_depth = 3.5;

// Rear skirt collar
skirt_diameter = 18.0;
skirt_length   = 12.0;


// ============================================================
// DERIVED VALUES
// ============================================================

max_radius   = max_diameter / 2;
bore_radius  = leader_bore / 2;
skirt_radius = skirt_diameter / 2;


// ============================================================
// OUTER PROFILE
//
// Z = length of lure
// R = radius from centerline
//
// IMPORTANT:
// - Points must be ordered with increasing Z for a valid polygon.
// - This list defines a single continuous radial profile.
// ============================================================

profile = [
    // Front (start slightly off axis to avoid degenerate face)
    [0.00, 0.20],
    [1.20, 1.20],
    [2.60, 2.40],
    [4.20, 5.00],
    [6.20, 8.20],
    [8.60, 11.20],
    [11.20, 13.40],
    [14.00, 14.75],
    [18.00, 15.55],
    [24.00, max_radius],

    // Mid body
    [27.00, 15.95],
    [33.00, 15.65],
    [39.00, 15.00],
    [45.00, 14.00],
    [51.00, 12.00],
    [55.00, 10.00],
    [56.00, 9.00],

    // Skirt collar
    [overall_length - skirt_length + 2.00, skirt_radius],
    [overall_length - skirt_length + 4.00, skirt_radius],
    [overall_length - skirt_length + 6.00, skirt_radius],
    [overall_length - skirt_length + 8.00, skirt_radius],
    [overall_length, skirt_radius]
];


// ============================================================
// CREATE MAIN BODY
// ============================================================

module lure_body()
{
    rotate_extrude(angle = 360, convexity = 20)
        polygon(
            points = concat(
                // Convert [z,r] -> [x,y] where x = radius, y = z
                [for (p = profile) [p[1], p[0]]],

                // Close polygon along axis back to start
                [
                    [0, profile[len(profile) - 1][0]],
                    [0, profile[0][0]]
                ]
            )
        );
}


// ============================================================
// CENTER LEADER BORE
// ============================================================

module center_bore()
{
    translate([0, 0, -1])
        cylinder(
            h = overall_length + 2,
            r = bore_radius,
            center = false
        );
}


// ============================================================
// FINAL LURE
// ============================================================

difference()
{
    lure_body();
    center_bore();
}
