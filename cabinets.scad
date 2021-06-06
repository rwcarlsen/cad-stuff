include <silo-common.scad>

offset_r = 12;
cabinet_depth = 2*12;
cabinet_height = 34;
inside_d1 = (stair_r_inner + stair_width)*2 + 2*offset_r;
inside_d2 = bin_d - 2*wall_thickness - 2*cabinet_depth;

module cabinet(inside_d, angle) {
    outside_d = inside_d + 2*cabinet_depth;
    linear_extrude(cabinet_height) difference() {
        circle(d=outside_d);
        circle(d=inside_d);
        mirror([0,1,0]) translate([-outside_d, 0, 0]) square([outside_d*2, outside_d * 2]);
        rotate(-180+angle) mirror([0,1,0]) translate([-outside_d, 0, 0]) square([outside_d*2, outside_d * 2]);
    }
}

module cabinets() {
    color("pink") cabinet(inside_d1, 80);
    color("pink") cabinet(inside_d2, 100);
    color("red") rotate(-155) translate([-36,0,0]) cabinet(inside_d1, 20);
}

cabinets();


