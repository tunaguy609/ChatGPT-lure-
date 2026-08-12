// offshore_trolling_lure_head.scad (v2 print-safe)
// Units: mm

$fn = 180;

// =====================
// Requested dimensions
// =====================
head_len               = 25.4;   // 1 inch
head_max_dia           = 24.0;
head_max_r             = head_max_dia / 2;

cup_dia                = 18.0;
cup_r                  = cup_dia / 2;
cup_depth              = 5.0;

leader_bore_dia        = 2.2;
leader_bore_r          = leader_bore_dia / 2;

eye_dia                = 8.0;
eye_r                  = eye_dia / 2;
eye_depth              = 2.5;

collar_outer_len       = 24.0;   // external rear collar section
collar_ramp_len        = 12.0;   // two ramps, each 12 mm
collar_od              = 19.0;
collar_r               = collar_od / 2;

skirt_pocket_dia       = 16.25;
skirt_pocket_r         = skirt_pocket_dia / 2;
skirt_pocket_into_head = 20.0;   // pocket extends 20 mm into head

overall_len            = head_len + collar_outer_len;

// =====================
// Print/manifold controls
// =====================
hex_facets             = 6;
edge_round_radius      = 0.85;   // rounded-over hex edges
eps                    = 0.02;   // tiny overlap to prevent coincident faces
min_wall_target        = 1.20;   // design intent floor

// Nose asymmetry (top lip slightly longer)
nose_top_extra         = 1.0;    // effective via asym trim cutter

// Eye placement (behind cup)
eye_z                  = 11.2;
eye_angle_pair         = 90;

// Jets (4 total)
jet_count              = 4;
jet_dia                = 2.0;    // slightly reduced for wall safety
jet_r                  = jet_dia / 2;
jet_entry_ring_r       = 5.5;    // inside cup
jet_entry_z            = 1.1;    // within dish
jet_exit_z             = 14.0;   // behind eyes
jet_exit_radial_bias   = 0.90;   // fraction of local radius at exit

// =====================
// Helpers
// =====================
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Head radius profile from z=0 (nose) to z=head_len (rear shoulder)
function head_radius(z) =
    z <= 18.0
    ? let(t = clamp(z/18.0, 0, 1))
      (head_max_r * (0.30 + 0.70*(1 - pow(1 - t, 2.1))))
    : let(t2 = clamp((z - 18.0)/(head_len - 18.0), 0, 1))
      (head_max_r - 2.0*t2);

// Useful z where pocket starts
pocket_start_z = head_len - skirt_pocket_into_head; // 5.4 mm

// =====================
// Core solids
// =====================
module head_profile_2d() {
    pts = concat(
        [for (z = [0:0.4:head_len]) [head_radius(z), z]],
        [[0, head_len], [0, 0]]
    );
    polygon(pts);
}

module head_revolved() {
    rotate_extrude(convexity=30)
        head_profile_2d();
}

// Rounded hex envelope to make hex body with softened edges
module rounded_hex_envelope(h) {
    linear_extrude(height=h + eps)
        offset(r=edge_round_radius)
            circle(r=head_max_r - edge_round_radius, $fn=hex_facets);
}

module faceted_head() {
    intersection() {
        head_revolved();
        rounded_hex_envelope(head_len);
    }
}

module skirt_collar_external() {
    z0 = head_len;
    z1 = head_len + collar_ramp_len;
    z2 = head_len + collar_outer_len;

    union() {
        // ramp 1: from head shoulder to collar OD
        hull() {
            translate([0,0,z0]) cylinder(h=eps, r=head_radius(head_len), $fn=120);
            translate([0,0,z1]) cylinder(h=eps, r=collar_r, $fn=120);
        }

        // ramp 2: from collar OD to rear taper
        hull() {
            translate([0,0,z1]) cylinder(h=eps, r=collar_r, $fn=120);
            translate([0,0,z2]) cylinder(h=eps, r=collar_r*0.72, $fn=120);
        }
    }
}

module outer_solid() {
    union() {
        faceted_head();
        skirt_collar_external();
    }
}

// =====================
// Cutters
// =====================

// Cupped dish 18 mm dia, 5 mm deep + asym lip (top longer)
module nose_cup_cutter() {
    // base cup
    module base_cup() {
        intersection() {
            translate([0,0, cup_depth - (cup_r*1.33)])
                sphere(r=cup_r*1.33, $fn=160);

            translate([0,0,-0.2])
                cylinder(h=cup_depth + 0.4, r=cup_r, $fn=160);
        }
    }

    // lower-lip trim to make top appear slightly longer
    difference() {
        base_cup();

        // remove more on "bottom" side ( +Y here )
        translate([0, cup_r*0.30, cup_depth*0.50])
            rotate([12,0,0])
                cube([cup_dia*1.6, cup_dia*1.6, cup_depth*1.8], center=true);
    }
}

// Center leader bore only from nose to pocket start
module leader_bore_cutter() {
    cylinder(h=pocket_start_z + eps, r=leader_bore_r, $fn=96);
}

// Skirt pocket bore starts at pocket_start_z and goes to tail
module skirt_pocket_cutter() {
    translate([0,0,pocket_start_z - eps])
        cylinder(h=(overall_len - pocket_start_z) + 2*eps, r=skirt_pocket_r, $fn=160);
}

// Eye pockets: 8 mm dia, 2.5 mm depth
module eye_pocket(side=1) {
    a  = side * eye_angle_pair;
    rr = head_radius(eye_z) - eye_depth/2;

    translate([rr*cos(a), rr*sin(a), eye_z])
        rotate([0,90,0])
            cylinder(h=eye_depth + 0.8, r=eye_r, center=true, $fn=120);
}

// Jet tube made by hulling spheres along entry->exit line
module one_jet(i=0) {
    ang = i*360/jet_count + 45; // avoid direct eye axis

    entry = [jet_entry_ring_r*cos(ang), jet_entry_ring_r*sin(ang), jet_entry_z];

    local_r = head_radius(jet_exit_z);
    exit_r  = local_r * jet_exit_radial_bias;
    exitpt  = [exit_r*cos(ang), exit_r*sin(ang), jet_exit_z];

    hull() {
        translate(entry) sphere(r=jet_r, $fn=42);
        translate(exitpt) sphere(r=jet_r, $fn=42);
    }
}

// Keep jets from cutting into skirt pocket by clipping jet cutters to head-only zone
module all_jets_cutter() {
    intersection() {
        union() {
            for (i=[0:jet_count-1]) one_jet(i);
        }
        // Restrict jets to front/head region
        translate([0,0,-1])
            cylinder(h=head_len - 2.0, r=head_max_r + 2, $fn=96);
    }
}

// Optional cleanup nib at nose to avoid zero-thickness apex
module nose_apex_cleanup() {
    translate([0,0,-0.3])
        cylinder(h=0.8, r=0.35, $fn=40);
}

// =====================
// Final model
// =====================
difference() {
    outer_solid();

    nose_cup_cutter();
    nose_apex_cleanup();

    leader_bore_cutter();
    skirt_pocket_cutter();

    eye_pocket( 1);
    eye_pocket(-1);

    all_jets_cutter();
}

// =====================
// Quick sanity echoes
// =====================
echo("Min wall target (design): ", min_wall_target);
echo("Pocket start z: ", pocket_start_z);
echo("Leader bore length: ", pocket_start_z);
