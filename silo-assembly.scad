include <silo-common.scad>

use <stairs.scad>
use <cabinets.scad>
use <window.scad>
use <silo-structure.scad>

window_w = 27.5;
window_h = 47;
stair_angle = stairAngle(stair_run, stair_r_inner, stair_width);
vestibule_width = 12*12;


module silo1() {
    wall_plates();
    roof();
    difference(convexity=100) {
        wall();
        window_hole(24, 48, 0, 36);
    }
    window(24, 48, 0, 36);

    rotate(-stair_angle) staircase();
    cabinets();
}

module silo2() {
    wall();
    roof();
}

module vestibule() {
    h = bin_eave_h - 6;
    //h = floor1_ceil_h + joist_height;
    dx = -bin_d - 44;
    dy1 = vestibule_width / 2 - 2*wall_thickness;
    dy2 = -vestibule_width / 2;
    difference(convexity=50) {
        group() {
            translate([dx, dy1, 0]) cube([bin_d, wall_thickness, h]);
            translate([dx, dy2, 0]) cube([bin_d, wall_thickness, h]);
            translate([dx, dy2, h - wall_thickness]) cube([bin_d, vestibule_width, wall_thickness]);
            
            // railing
            rail_spacing = 5;
            nrailing = floor(bin_d / rail_spacing);
            rail_height = 36;
            for (n = [0:nrailing-1]) {
                translate([dx + n*rail_spacing, vestibule_width/2, h]) cylinder(h=rail_height, r=0.75);
                translate([dx + n*rail_spacing, -vestibule_width/2, h]) cylinder(h=rail_height, r=0.75);
            }
        }
        translate([dx, 0, -.5]) cylinder(h=2*bin_eave_h + 1, d=bin_d);
        translate([0,0,-.5]) cylinder(h=2*bin_eave_h + 1, d=bin_d);
    }
}

module deck() {
    deck_thickness = wall_thickness;
    deck_d = bin_d + 60;
    front_protrusion = 48;
    dy = (deck_d - bin_d)/2 - front_protrusion;
    deck_h = floor1_ceil_h + joist_height;
    difference(convexity=100) {
        group() {
            translate([-bin_d / 2 - 44 / 2, dy, deck_h - deck_thickness]) cylinder(h=deck_thickness, d=deck_d);
            
            // railing
            rail_spacing = 5;
            nrailing = floor(PI * deck_d / rail_spacing);
            rail_height = 36;
            for (n = [0:nrailing-1]) {
                dtheta = n*360/nrailing;
                translate([-bin_d / 2 - 44/2, dy, 0]) rotate(dtheta) translate([deck_d / 2, 0, deck_h]) cylinder(h=rail_height, r=0.75);
            }
            translate([-bin_d/2 - 44/2, dy, 0]) framing_plate(deck_h + rail_height, d=deck_d, t=2, h=2);
        }            
        translate([-bin_d - 44, 0, 0]) cylinder(h=bin_eave_h, d=bin_d);
        cylinder(h=bin_eave_h, d=bin_d);
    }
}

silo1();
translate([-bin_d - 44, 0, 0]) silo2();
color("pink") vestibule();
color("tan") deck();