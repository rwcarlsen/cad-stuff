$fn=80;

r_inner = 6;
stair_rise = 8;
stair_run = 10; // at mid-point
stair_width = 30;
staircase_height = 9*12+10;
pipe_thickness = 0.25;
stair_thickness = 1.5;

sidebar_height = 10;

r_outer = r_inner + stair_width;
r_mid = r_inner + 0.5 * stair_width;
circ_mid = 2 * PI * r_mid;
stair_rise_actual = staircase_height / ceil(staircase_height / stair_rise);
n_stairs = round(staircase_height / stair_rise_actual) - 1;
stair_angle = stair_run / circ_mid * 360;
staircase_angle = n_stairs * stair_angle;
echo("staircase_angle", staircase_angle);
echo("stair_angle", stair_angle);
echo("n_stairs", n_stairs);
echo("actual_rise", stair_rise_actual);

angle_iron_length = stair_width;
angle_iron_width = 3;
support_thickness = 0.25;
stair_overlap_frac = 0.15;
railing_height = 32;
railing_d = .75;
railing_inset = 1.5;

module stair_top(r_inner, r_outer, stair_angle, overlap_frac) {
    difference(convexity=10) {
        circle(r=r_outer);
        circle(r=r_inner);
        rotate((1+overlap_frac)*stair_angle) translate([-1.5*r_outer,0,0]) square(3*r_outer);
        rotate(0) translate([-1.5*r_outer,-3*r_outer,0]) square(3*r_outer);
    }
}

// stairs themselves
for (i = [0:n_stairs - 1]) {   
    dz = i*stair_rise_actual+stair_rise_actual;
    dtheta = i*stair_angle;
    // angle-slice stairs
    color("tan") translate([0,0,dz + support_thickness]) rotate(dtheta) linear_extrude(stair_thickness) stair_top(r_inner, r_outer, stair_angle, stair_overlap_frac);
    
    dtheta2 = dtheta + stair_angle*(1+stair_overlap_frac);
    
    // angle iron support
    color("grey") rotate(dtheta2) translate([r_inner-1,-angle_iron_width,dz])
        cube([angle_iron_length+1, angle_iron_width, support_thickness]);
    color("grey") rotate(dtheta2) translate([r_inner-1,-support_thickness,dz-angle_iron_width + support_thickness])
        cube([angle_iron_length+1, support_thickness, angle_iron_width]);
    
    // railing
    color("lightgrey") rotate(dtheta2 - stair_angle*(stair_overlap_frac/2)) translate([r_outer - railing_inset, 0, dz]) cylinder(h=railing_height+stair_rise, d=railing_d);
    
}

// person simulator
//translate([20,-20,0]) cylinder(78,r=12);

// center post
color("skyblue") difference(convexity=10) {
    cylinder(h=staircase_height, r=r_inner);
    translate([0,0,-0.5]) cylinder(h=staircase_height+1, r=r_inner - pipe_thickness);
    // flue pipe hole
    translate([0,0,48]) rotate([90,0,0]) cylinder(h=r_inner*2, d=8);
}
