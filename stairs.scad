$fn=80;

r_inner = 16;
stair_rise = 7;
stair_run = 10; // at mid-point
stair_width = 30;
staircase_height = 9*12;

sidebar_height = 10;

r_outer = r_inner + stair_width;
r_mid = r_inner + 0.5 * stair_width;
circ_mid = 2 * PI * r_mid;
stair_rise_actual = staircase_height / ceil(staircase_height / stair_rise);
n_stairs = round(staircase_height / stair_rise_actual);
stair_angle = stair_run / circ_mid * 360;
staircase_angle = n_stairs * stair_angle;

ndivs = 200;
dl = staircase_angle / 360 * 2 * PI *r_outer / ndivs * 1.1;
for (i = [0:ndivs-1]) {
    dtheta = staircase_angle * i/ndivs;
    dtheta_prev = staircase_angle * (i - 1)/ndivs;
    dz = staircase_height * i / ndivs;
    dz_prev = staircase_height * (i - 1) / ndivs;
    hull() {
        translate([0,0,dz]) rotate(dtheta) translate([r_outer, 0, sidebar_height/2]) cube([.5, , dl, sidebar_height], center=true);
        translate([0,0,dz_prev]) rotate(dtheta_prev) translate([r_outer, 0, sidebar_height/2]) cube([.5, , dl, sidebar_height], center=true);
    }
    hull() {
        translate([0,0,dz]) rotate(dtheta) translate([r_inner, 0, sidebar_height/2]) cube([.5, , dl, sidebar_height], center=true);
        translate([0,0,dz_prev]) rotate(dtheta_prev) translate([r_inner, 0, sidebar_height/2]) cube([.5, , dl, sidebar_height], center=true);
    }
}

for (i = [0:n_stairs - 1]) {
    translate([0,0,i*stair_rise_actual+stair_rise_actual]) rotate(i*stair_angle) stair(r_inner, r_outer, stair_angle);
}

module stair(r_inner, r_outer, stair_angle) {
    difference(convexity=10) {
        circle(r=r_outer);
        circle(r=r_inner);
        rotate(stair_angle) translate([-1.5*r_outer,0,0]) square(3*r_outer);
        rotate(0) translate([-1.5*r_outer,-3*r_outer,0]) square(3*r_outer);
    }
}