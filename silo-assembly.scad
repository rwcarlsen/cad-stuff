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
    difference(convexity=50) {
        group() {
            translate([-bin_d - 44, vestibule_width / 2 - 2*wall_thickness, 0]) cube([bin_d, wall_thickness, h]);
            translate([-bin_d - 44, -vestibule_width / 2, 0]) cube([bin_d, wall_thickness, h]);
            translate([-bin_d - 44, -vestibule_width/2, h - wall_thickness]) cube([bin_d, vestibule_width, wall_thickness]);
        }
        translate([-bin_d - 44, 0, -.5]) cylinder(h=bin_eave_h + 1, d=bin_d);
        translate([0,0,-.5]) cylinder(h=bin_eave_h + 1, d=bin_d);
    }
}

module deck() {
    deck_thickness = wall_thickness;
    deck_d = bin_d + 60;
    front_protrusion = 48;
    dy = (deck_d - bin_d)/2 - front_protrusion;
    difference(convexity=100) {
        translate([-bin_d / 2 - 44 / 2, dy, floor1_ceil_h + joist_height - deck_thickness]) cylinder(h=deck_thickness, d=deck_d);
        translate([-bin_d - 44, 0, 0]) cylinder(h=bin_eave_h, d=bin_d);
        cylinder(h=bin_eave_h, d=bin_d);
    } 
}

silo1();
translate([-bin_d - 44, 0, 0]) silo2();
color("pink") vestibule();
color("tan") deck();