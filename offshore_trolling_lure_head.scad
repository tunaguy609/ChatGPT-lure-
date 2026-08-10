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
    // Front center region (shallow concave entry)
    [0.00, cup_depth],
    [1.50, 3.20],
    [3.00, 3.45],
    [6.00, 3.30],
    [9.00, 2.90],
    [11.00, 2.20],
    [12.50, 1.20],
    [13.50, 0.00],

    // Transition to outer nose/body
    [14.00, 14.75],
    [16.00, 15.20],
    [18.00, 15.55],
    [21.00, 15.85],
    [24.00, max_radius],

    // Full bulbous body
    [27.00, 15.95],
    [30.00, 15.85],
    [33.00, 15.65],
    [36.00, 15.40],
    [39.00, 15.00],
    [42.00, 14.55],

    // Rear body closing
    [45.00, 14.00],
    [48.00, 13.20],
    [51.00, 12.00],
    [53.00, 11.00],
    [55.00, 10.00],
    [56.00, 9.00],

    // 18 mm skirt collar
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
