include <silo-common.scad>

use <stairs.scad>
use <cabinets.scad>
use <window.scad>
use <silo-structure.scad>

window_w = 27.5;
window_h = 47;
stair_angle = stairAngle(stair_run, stair_r_inner, stair_width);
vestibule_width_back = 6*12;
vestibule_width_front = 7.5*12;
vestibule_width = vestibule_width_back + vestibule_width_front;

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

module silo2(wall=true) {
    if (wall) wall();
    roof();
}

module vestibule() {
    h_high = bin_eave_h - 6;
    h_low = floor1_ceil_h + joist_height;
    //h_low = h_high;
    dx = -bin_d - 44;
    dy1 = vestibule_width_back - 2*wall_thickness;
    dy2 = -vestibule_width_front;
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
    dy2 = -vestibule_width_front;
    eps = 1e-1;
    difference(convexity=50) {
        group() {
            translate([dx, dy2, h_high - wall_thickness]) cube([bin_d, vestibule_width, wall_thickness]);
            
            // railing
            rail_spacing = 5;
            nrailing = floor(bin_d / rail_spacing);
            rail_height = 36;
            for (n = [0:nrailing-1]) {
                translate([dx + n*rail_spacing, vestibule_width_back, h_high]) cylinder(h=rail_height, r=0.75);
                translate([dx + n*rail_spacing, -vestibule_width_front, h_high]) cylinder(h=rail_height, r=0.75);
            }
            translate([dx, vestibule_width_back, h_high + rail_height]) cube([bin_d, 2, 2]);
            translate([dx, -vestibule_width_front, h_high + rail_height]) cube([bin_d, 2, 2]);
        }
        translate([dx, 0, -.5]) cylinder(h=2*bin_eave_h + 1, d=bin_d);
        translate([0,0,-.5]) cylinder(h=2*bin_eave_h + 1, d=bin_d);
    }
}

module circle_railing(d, spacing, height) {
    nrailing = floor(PI * d / spacing);
    for (n = [0:nrailing-1]) {
        dtheta = -n*360/nrailing;
        rotate(dtheta) translate([d / 2, 0, 0]) cylinder(h=height, r=0.75);
        rotate(-dtheta) translate([d / 2, 0, 0]) cylinder(h=height, r=0.75);
    }
    framing_plate(height, d=d, t=2, h=2);
}

module deck() {
    deck_thickness = wall_thickness;
    deck_d = 22*12;
    front_protrusion = 60;
    back_protrusion = 12;
    dy_front = (deck_d - bin_d)/2 - front_protrusion;
    dy_back = -(deck_d - bin_d)/2 + back_protrusion;
    deck_h = floor1_ceil_h + joist_height;
    difference(convexity=100) {
        group() {
            translate([-bin_d / 2 - 44 / 2, dy_front, deck_h - deck_thickness]) cylinder(h=deck_thickness, d=deck_d);
            translate([-bin_d / 2 - 44 / 2, dy_back, deck_h - deck_thickness]) cylinder(h=deck_thickness, d=deck_d);
            
            // railing
            rail_spacing = 5;
            nrailing = floor(PI/2 * deck_d / rail_spacing);
            rail_height = 36;
            difference() {
                translate([-bin_d / 2 - 44/2, dy_front, deck_h]) circle_railing(deck_d, rail_spacing, rail_height);
                translate([-bin_d / 2 - 44/2, dy_back, 0]) cylinder(h=bin_eave_h, d=deck_d);
            }
            difference() {
                translate([-bin_d / 2 - 44/2, dy_back, deck_h]) circle_railing(deck_d, rail_spacing, rail_height);
                translate([-bin_d / 2 - 44/2, dy_front, 0]) cylinder(h=bin_eave_h, d=deck_d);
            }
        }            
        translate([-bin_d - 44, 0, 0]) cylinder(h=bin_eave_h, d=bin_d);
        cylinder(h=bin_eave_h, d=bin_d);
    }
}

module climbing_wall(mezanine_x_offset, mezanine_y_offset) {
    inside_r = bin_d/2 - wall_thickness;
    angle_to_corner = 45;

    doorway = 42;
    side_space = mezanine_x_offset;

    backwall_cord = 2 * sqrt(inside_r^2 - mezanine_y_offset^2);
    side_wall_length = 11*12;
    back_wall_length = inside_r - doorway + mezanine_x_offset;
    back_wall_dx = -mezanine_x_offset;
    echo("side_wall:", side_wall_length);
    echo("back_wall:", back_wall_length);
    
    left_h = bin_eave_h;
    roof_peak = bin_d / 2 * roof_pitch + bin_eave_h;
    wallboard = 1;
    side_angle = -atan(2/10);
    front_angle = -atan(1/5);
    
    wall_peak = roof_peak;
    side_wall_vlength = bin_eave_h / cos(side_angle);
    side_wall_dx = back_wall_dx;// + wall_peak * sin(side_angle);
  
    difference(convexity=50) {
        union() {
            // center verticle tall wall
            color("lightgreen") translate([back_wall_dx,-mezanine_y_offset,0]) cube([back_wall_length, wallboard, wall_peak]);
            // front wall
            //translate([back_wall_dx,mezanine_offset - side_wall_length,0]) rotate([front_angle,0,0]) cube([back_wall_length, wallboard, wall_peak]);
            // side wall
            color("lightpink") translate([side_wall_dx,-mezanine_y_offset,0]) rotate([0,-side_angle,0]) cube([wallboard,side_wall_length, side_wall_vlength]);
            // side wall top verticle portion
            color("lavender") translate([side_wall_dx - bin_eave_h * tan(side_angle), -mezanine_y_offset, bin_eave_h]) cube([wallboard, side_wall_length, roof_pitch * bin_d / 2]);
            // roof
            color("skyblue") translate([side_wall_dx - bin_eave_h * tan(side_angle),-mezanine_y_offset, bin_d / 2 * roof_pitch*.77 + bin_eave_h]) rotate([-atan(0.5*.67), 0, 0]) cube([72, (inside_r + mezanine_y_offset)/sin(atan(2)), wallboard]);
        }
        silo_negative();
    }
}

module silo2_mezanine(x_offset, y_offset, overhang) {
    floor_thickness = 1;
    translate([0,0,floor1_ceil_h + joist_height]) linear_extrude(floor_thickness)
        difference(convexity=50) {
            circle(d=bin_d);
            translate([-x_offset+overhang, -y_offset]) square([bin_d, bin_d]);
        }
}

//rotate(80) silo1(wall=false);
//translate([-bin_d - 44, 0, 0]) {
    mezanine_y_offset = 24; // y offset from bin center for climbing room
    mezanine_x_offset = 78; // x offset from bin center for climbing room
    overhang=24; // how far the mezanine overhangs the lower side wall 
    //silo2(wall=false);
    silo2_mezanine(mezanine_x_offset, mezanine_y_offset, overhang);
    climbing_wall(mezanine_x_offset, mezanine_y_offset);
//}

//vestibule();
//color("tan") deck();
//color("skyblue") high_deck();