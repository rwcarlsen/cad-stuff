$fn=80;

r_inner = 6;
stair_rise = 8;
stair_run = 10; // at mid-point
stair_width = 30;
staircase_height = 8*12+10;
pipe_thickness = 0.25;
stair_thickness = 1.5;

sidebar_height = 10;

r_outer = r_inner + stair_width;
r_mid = r_inner + 0.5 * stair_width;
circ_mid = 2 * PI * r_mid;
stair_rise_actual = staircase_height / ceil(staircase_height / stair_rise);
n_stairs = round(staircase_height / stair_rise_actual);
stair_angle = stair_run / circ_mid * 360;
staircase_angle = n_stairs * stair_angle;
echo("staircase_angle", staircase_angle);
echo("stair_angle", stair_angle);
echo("n_stairs", n_stairs);
echo("actual_rise", stair_rise_actual);

module stair_top(r_inner, r_outer, stair_angle) {
    difference(convexity=10) {
        circle(r=r_outer);
        circle(r=r_inner);
        rotate(1.15*stair_angle) translate([-1.5*r_outer,0,0]) square(3*r_outer);
        rotate(0) translate([-1.5*r_outer,-3*r_outer,0]) square(3*r_outer);
    }
}

// wrapping-side-bars
//ndivs = 200;
//dl = staircase_angle / 360 * 2 * PI *r_outer / ndivs * 1.1;
//for (i = [0:ndivs-1]) {
//    dtheta = staircase_angle * i/ndivs;
//    dtheta_prev = staircase_angle * (i - 1)/ndivs;
//    dz = staircase_height * i / ndivs;
//    dz_prev = staircase_height * (i - 1) / ndivs;
//    hull() {
//        translate([0,0,dz]) rotate(dtheta) translate([r_outer, 0, sidebar_height/2]) cube([.5, , dl, sidebar_height], center=true);
//        translate([0,0,dz_prev]) rotate(dtheta_prev) translate([r_outer, 0, sidebar_height/2]) cube([.5, , dl, sidebar_height], center=true);
//    }
//    
//    hull() {
//        translate([0,0,dz]) rotate(dtheta) translate([r_inner, 0, sidebar_height/2]) cube([.5, , dl, sidebar_height], center=true);
//        translate([0,0,dz_prev]) rotate(dtheta_prev) translate([r_inner, 0, sidebar_height/2]) cube([.5, , dl, sidebar_height], center=true);
//    }
//}

// stairs themselves
for (i = [0:n_stairs - 1]) {

    support_length = 2/3*stair_width;
    support_height = 2/3*stair_rise_actual;
    support_width = 4;
    support_thickness = 0.25;
    
    dz = i*stair_rise_actual+stair_rise_actual;
    dtheta = i*stair_angle;
    // angle-slice stairs
    translate([0,0,dz + support_thickness]) rotate(dtheta) linear_extrude(stair_thickness) stair_top(r_inner, r_outer, stair_angle);
    
    dtheta2 = dtheta + stair_angle/ 2;
    
    // side bracket
    rotate(dtheta2) translate([r_inner,-support_width/2,dz - support_height])
        cube([support_thickness, support_width, support_height]);
    // top bracket
    rotate(dtheta2) translate([r_inner,-support_width/2,dz])
        cube([support_length, support_width, support_thickness]);
    // angle bracket
    translate([0,0,dz - support_height])
        rotate([90,0,dtheta2])
            linear_extrude(support_thickness)
                translate([r_inner,0,0]) polygon([[0,0], [0, support_height], [support_length, support_height], [0, 0]]);
    
}

// person simulator
//translate([20,-20,0]) cylinder(78,r=12);

// center post
difference(convexity=10) {
    cylinder(h=staircase_height, r=r_inner);
    translate([0,0,-0.5]) cylinder(h=staircase_height+1, r=r_inner - pipe_thickness);
    // flue pipe hole
    translate([0,0,48]) rotate([90,0,0]) cylinder(h=r_inner*2, d=8);
}
