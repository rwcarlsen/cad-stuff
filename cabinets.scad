$fn=100;
inside_d1 = 6*12+1;
inside_d2 = inside_d1 + 2*7.5*12;
cabinet_depth = 2*12;
cabinet_height = 34;

module cabinet(inside_d) {
    outside_d = inside_d + 2*cabinet_depth;
    linear_extrude(cabinet_height) difference() {
        circle(d=outside_d);
        circle(d=inside_d);
        mirror([0,1,0]) translate([-outside_d, 0, 0]) square([outside_d*2, outside_d * 2]);
        rotate(-80) mirror([0,1,0]) translate([-outside_d, 0, 0]) square([outside_d*2, outside_d * 2]);
    }
}

color("pink") cabinet(inside_d1);
color("pink") cabinet(inside_d2);


