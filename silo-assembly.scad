include <silo-common.scad>

use <stairs.scad>
use <cabinets.scad>
use <window.scad>
use <silo-structure.scad>

window_w = 27.5;
window_h = 47;
stair_angle = stairAngle(stair_run, stair_r_inner, stair_width);
vestibule_width = 12*12;


module silo1(wall=true) {
    floor_start = floor1_ceil_h + joist_height;
    floor2_ceil_h = bin_eave_h - floor_start;
    
    wall_plates();
    roof();
    if (wall) {
        difference(convexity=100) {
            wall();
            window_hole(window_w, window_h, -25, 36, floor_start=0);
            window_hole(window_w, window_h, -68, 36, floor_start=0);
            window_hole(window_w, window_h, 70, 36, floor_start=0);
            window_hole(window_w, window_h, 135, 36, floor_start=0);
            window_hole(window_w, window_h, -30, 36, floor_start=floor_start);
            window_hole(window_w, window_h, -80, 36, floor_start=floor_start);
            window_hole(window_w, window_h, 70, 36, floor_start=floor_start);
            window_hole(window_w, window_h, 135, 36, floor_start=floor_start);
        }
    }
    
    window_h = 50;
    window_w = 27.5;
    
    window(window_w, window_h, -25, 36);
    window(window_w, window_h, -68, 36);
    window(window_w, window_h, 70, 36);
    window(window_w, window_h, 135, 36);
    window(window_w, 48, -30, 36, floor_start=floor_start, ceil_h=floor2_ceil_h);
    window(window_w, window_h, -80, 36, floor_start=floor_start, ceil_h=floor2_ceil_h);
    window(window_w, window_h, 70, 36, floor_start=floor_start, ceil_h=floor2_ceil_h);
    window(window_w, window_h, 135, 36, floor_start=floor_start, ceil_h=floor2_ceil_h);


    rotate(-stair_angle) staircase();
    cabinets();
}

module silo2() {
    wall();
    roof();
}

module vestibule() {
    h_high = bin_eave_h - 6;
    h_low = floor1_ceil_h + joist_height;
    dx = -bin_d - 44;
    dy1 = vestibule_width / 2 - 2*wall_thickness;
    dy2 = -vestibule_width / 2;
    eps = 1e-1;
    difference(convexity=50) {
        group() {
            color("pink") translate([dx, dy1, 0]) cube([bin_d, wall_thickness, h_low - eps]);
            color("pink") translate([dx, dy2, 0]) cube([bin_d, wall_thickness, h_low - eps]);
        }
        translate([dx, 0, -.5]) cylinder(h=2*bin_eave_h + 1, d=bin_d);
        translate([0,0,-.5]) cylinder(h=2*bin_eave_h + 1, d=bin_d);
    }
}

module high_deck() {
    h_high = bin_eave_h - 6;
    dx = -bin_d - 44;
    dy2 = -vestibule_width / 2;
    eps = 1e-1;
    difference(convexity=50) {
        group() {
            translate([dx, dy2, h_high - wall_thickness]) cube([bin_d, vestibule_width, wall_thickness]);
            
            // railing
            rail_spacing = 5;
            nrailing = floor(bin_d / rail_spacing);
            rail_height = 36;
            for (n = [0:nrailing-1]) {
                translate([dx + n*rail_spacing, vestibule_width/2, h_high]) cylinder(h=rail_height, r=0.75);
                translate([dx + n*rail_spacing, -vestibule_width/2, h_high]) cylinder(h=rail_height, r=0.75);
            }
            translate([dx, vestibule_width/2, h_high + rail_height]) cube([bin_d, 2, 2]);
            translate([dx, -vestibule_width/2, h_high + rail_height]) cube([bin_d, 2, 2]);
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

rotate(80) silo1(wall=false);
translate([-bin_d - 44, 0, 0]) silo2();
vestibule();
color("tan") deck();
color("skyblue") high_deck();