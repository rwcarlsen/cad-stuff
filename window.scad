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

module wall() {
    inner_circ = PI * (bin_d - 2*wall_thickness);
    stud_dtheta = 16 / inner_circ * 360;
    nstuds = ceil(inner_circ / 16);
    difference() {
        cylinder(h=wall_h, d=bin_d);
        translate([0,0,-.5]) cylinder(h = wall_h + 1, d=bin_d - 2*wall_thickness);
        translate([0,0,stud_thickness]) cylinder(h=wall_h - 2*stud_thickness, d=bin_d+1);
    }
    for (i = [0:nstuds - 1]) {
        rotate(i*stud_dtheta) translate([bin_d/2 - wall_thickness, stud_thickness/2, 0]) cube([wall_thickness, stud_thickness, wall_h]);
    }
}

module window_frame() {
    cripple_h = window_elevation - 2*stud_thickness;
    jack_h = window_elevation + window_h;
    king_h = wall_h - 2*stud_thickness;
    
    // jack studs
    color("red") cube([stud_thickness, wall_thickness, jack_h]);
    color("red") translate([window_w + stud_thickness, 0, 0]) cube([stud_thickness, wall_thickness, jack_h]);
    // king studs
    color("green") translate([-stud_thickness,0,0]) cube([stud_thickness, wall_thickness, king_h]);
    color("green") translate([window_w + 2*stud_thickness,0,0]) cube([stud_thickness, wall_thickness, king_h]);
    // sill cripples
    color("blue") translate([stud_thickness, 0, 0]) cube([stud_thickness, wall_thickness, cripple_h]);
    color("blue") translate([window_w, 0, 0]) cube([stud_thickness, wall_thickness, cripple_h]);
    // sill
    color("green") translate([stud_thickness, 0, cripple_h]) cube([window_w, wall_thickness, stud_thickness]);
    //header
    color("blue") translate([0, 0, jack_h]) cube([window_w+2*stud_thickness, stud_thickness, wall_thickness]);
    color("blue") translate([0, wall_thickness-stud_thickness, jack_h]) cube([window_w+2*stud_thickness, stud_thickness, wall_thickness]);
}

//wall();
window_frame();