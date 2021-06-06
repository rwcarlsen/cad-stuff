include <silo-common.scad>

module wall() {
    color("Gainsboro") difference(convexity=100) {
        cylinder(h=bin_eave_h, d=bin_d+2*corrugation_thickness);
        translate([0,0,-.5]) cylinder(h = bin_eave_h + 1, d=bin_d);
    }
}

module wall_plates() {
    framing_plate(0);
    framing_plate(floor1_ceil_h - stud_width);
    framing_plate(bin_eave_h - stud_width);
}

module framing_plate(z, d=bin_d, t=wall_thickness, h=stud_width) {
    translate([0,0,z]) linear_extrude(h, convexity=100) difference() {
        circle(d=d);
        circle(d=d - 2 * t);
    }
}

module roof() {
    lid_d = 24;
    color("Gainsboro") translate([0,0,bin_eave_h]) cylinder(h=bin_d / 2 * roof_pitch, d1=bin_d, d2=lid_d);
}

wall_plates();
wall();
roof();