$fn = 100;

bin_d = 26.5*12;
wall_h = 9*12;
wall_thickness = 6;
window_w = 27.5;
window_h = 47;
window_depth_behind = 2 + 7/16;
window_depth_infront = 7/8;
window_flange_width = 1 + 1/4;
studs_on_center = 16;
stud_thickness = 1.5;
window_elevation = 36;
header_h = 6;
corrugation_thickness = 1;

module wall_plates() {
    inner_circ = PI * (bin_d - 2*wall_thickness);
    stud_dtheta = 16 / inner_circ * 360;
    nstuds = ceil(inner_circ / 16);
    color("lightgray") difference(convexity=10) {
        cylinder(h=wall_h, d=bin_d);
        translate([0,0,-.5]) cylinder(h = wall_h + 1, d=bin_d - 2*wall_thickness);
        translate([0,0,stud_thickness]) cylinder(h=wall_h - 2*stud_thickness, d=bin_d+1);
    }
//    for (i = [0:nstuds - 1]) {
//        rotate(i*stud_dtheta) translate([bin_d/2 - wall_thickness, stud_thickness/2, 0]) cube([wall_thickness, stud_thickness, wall_h]);
//    }
}
module wall() {
    color("tan") difference(convexity=10) {
        cylinder(h=wall_h, d=bin_d+2*corrugation_thickness);
        translate([0,0,-.5]) cylinder(h = wall_h + 1, d=bin_d);
    }
}

module window_frame() {
    window_h_big = window_h + 2*stud_thickness;
    window_w_big = window_w + 2*stud_thickness;
    window_elevation_big = window_elevation - stud_thickness;
    
    cripple_h = window_elevation_big - 2*stud_thickness;
    jack_h = window_elevation_big + window_h_big - stud_thickness;
    king_h = wall_h - 2*stud_thickness;
    color1 = "violet";
    color2 = "lightgreen";
    color3 = "skyblue";
    
    translate([-2*stud_thickness - window_w/2,-wall_thickness,stud_thickness]) group() {
        // jack studs
        color(color1) cube([stud_thickness, wall_thickness, jack_h]);
        color(color1) translate([window_w_big + stud_thickness, 0, 0]) cube([stud_thickness, wall_thickness, jack_h]);
        // king studs
        color(color2) translate([-stud_thickness,0,0]) cube([stud_thickness, wall_thickness, king_h]);
        color(color2) translate([window_w_big + 2*stud_thickness,0,0]) cube([stud_thickness, wall_thickness, king_h]);
        // sill cripples
        color(color3) translate([stud_thickness, 0, 0]) cube([stud_thickness, wall_thickness, cripple_h]);
        color(color3) translate([window_w_big, 0, 0]) cube([stud_thickness, wall_thickness, cripple_h]);
        // sill
        color(color2) translate([stud_thickness, 0, cripple_h]) cube([window_w_big, wall_thickness, stud_thickness]);
        //header
        color(color3) translate([0, 0, jack_h]) cube([window_w_big+2*stud_thickness, stud_thickness, wall_thickness]);
        color(color3) translate([0, wall_thickness-stud_thickness, jack_h]) cube([window_w_big+2*stud_thickness, stud_thickness, wall_thickness]);
        
        // wide frame
        //overhang = bin_d / 2 - 1/2*sqrt(bin_d^2 - (window_w + 6 * stud_thickness)^2) + corrugation_thickness;
        g_inner = bin_d / 2 - 1/2*sqrt(bin_d^2 - (window_w + 4 * stud_thickness)^2);
        bin_d_outer = bin_d + 2*corrugation_thickness;
        g_outer = bin_d_outer / 2 - 1/2*sqrt(bin_d_outer^2 - window_w^2);
        overhang = corrugation_thickness - g_outer + g_inner;
        frame_thickness = wall_thickness + overhang;
        echo("frame depth: ", frame_thickness);
        color(color1) translate([2*stud_thickness, 0, cripple_h+stud_thickness]) cube([window_w_big-2*stud_thickness, frame_thickness, stud_thickness]);
        color(color2) translate([stud_thickness, 0, jack_h - stud_thickness]) cube([window_w_big, frame_thickness, stud_thickness]);
        color(color3) translate([stud_thickness, 0, cripple_h + stud_thickness]) cube([stud_thickness, frame_thickness, window_h + stud_thickness]);
        color(color3) translate([window_w_big, 0, cripple_h + stud_thickness]) cube([stud_thickness, frame_thickness, window_h + stud_thickness]);
    }
}

module window_hole() {
    w = window_w + 2*stud_thickness;
    h = window_h + 2*stud_thickness;
    translate([-w / 2, 0, window_elevation - stud_thickness]) cube([w, wall_thickness * 2, h]);
}

//include <stairs.scad>
//include <cabinets.scad>

wall_plates();
offset = bin_d/2 - 1/2*sqrt(bin_d^2 - (window_w + 6*stud_thickness)^2);
translate([0, bin_d/2 - offset, 0]) window_frame();
difference(convexity=10) {
    wall();
    translate([0, bin_d/2 - wall_thickness/2, 0]) window_hole();
}


