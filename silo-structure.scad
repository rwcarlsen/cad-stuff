include <silo-common.scad>

module wall() {
    color("tan") difference(convexity=10) {
        cylinder(h=bin_eave_h, d=bin_d+2*corrugation_thickness);
        translate([0,0,-.5]) cylinder(h = bin_eave_h + 1, d=bin_d);
    }
}

module wall_plates() {
    framing_plate(0);
    framing_plate(floor1_ceil_h - stud_width);
    framing_plate(bin_eave_h - stud_width);
}

module framing_plate(h) {
    translate([0,0,h]) linear_extrude(stud_width) difference() {
        circle(d=bin_d);
        circle(d=bin_d - 2 * wall_thickness);
    }
}

module roof() {
    translate([0,0,bin_eave_h]) cylinder(h=bin_d / 2 * roof_pitch, d1=bin_d, d2=0);
}

wall_plates();
wall();
roof();