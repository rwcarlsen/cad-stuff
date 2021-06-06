include <silo-common.scad>

staircase_height = floor1_ceil_h+joist_height;

function stairAngle(run, r_inner, width) = run / (2 * PI * (r_inner + 0.5*width)) * 360;

pipe_thickness = 0.25;
stair_thickness = 1.5;

angle_iron_length = stair_width;
angle_iron_width = 3;
support_thickness = 0.25;
stair_overlap_frac = 0.15;
railing_height = 32;
railing_d = .75;
railing_inset = 1.5;

ring_height = 6;
r_outer = stair_r_inner + stair_width;
r_mid = stair_r_inner + 0.5 * stair_width;
circ_mid = 2 * PI * r_mid;
stair_rise_actual = staircase_height / ceil(staircase_height / stair_rise);
n_stairs = round(staircase_height / stair_rise_actual) - 1;
stair_angle = stairAngle(stair_run, stair_r_inner, stair_width);
staircase_angle = n_stairs * stair_angle;
echo("staircase_angle", staircase_angle);
echo("stair_angle", stair_angle);
echo("n_stairs", n_stairs);
echo("actual_rise", stair_rise_actual);

head_clearance = (floor(360 / stair_angle) - 1 - 1) * stair_rise_actual - stair_thickness - angle_iron_width;
head_clearance_ft = floor(head_clearance/12);
echo("head_clearance: ", head_clearance_ft, "ft.", head_clearance - 12*head_clearance_ft, "in.");

module stair_top(stair_r_inner, r_outer, stair_angle, overlap_frac) {
    difference(convexity=10) {
        circle(r=r_outer);
        circle(r=stair_r_inner);
        rotate((1+overlap_frac)*stair_angle) translate([-1.5*r_outer,0,0]) square(3*r_outer);
        rotate(0) translate([-1.5*r_outer,-3*r_outer,0]) square(3*r_outer);
    }
}

// stairs themselves
module staircase() {
    for (i = [0:n_stairs - 1]) {   
        dz = i*stair_rise_actual+stair_rise_actual;
        dtheta = i*stair_angle;
        // angle-slice stairs
        color("tan") translate([0,0,dz + support_thickness]) rotate(dtheta) linear_extrude(stair_thickness) stair_top(stair_r_inner, r_outer, stair_angle, stair_overlap_frac);
        
        dtheta2 = dtheta + stair_angle*(1+stair_overlap_frac);
        
        // angle iron support
        color("grey") rotate(dtheta2) translate([stair_r_inner-1,-angle_iron_width,dz])
            cube([angle_iron_length+1, angle_iron_width, support_thickness]);
        color("grey") rotate(dtheta2) translate([stair_r_inner-1,-support_thickness,dz-angle_iron_width + support_thickness])
            cube([angle_iron_length+1, support_thickness, angle_iron_width]);
        
        // railing
        color("lightgrey") rotate(dtheta2 - stair_angle*(stair_overlap_frac/2)) translate([r_outer - railing_inset, 0, dz]) cylinder(h=railing_height+stair_rise, d=railing_d);
    }
    
    support_ring(r_outer, ring_height);
    color("skyblue") center_post();
}

// center post
module center_post() {
    difference(convexity=10) {
        cylinder(h=staircase_height, r=stair_r_inner);
        translate([0,0,-0.5]) cylinder(h=staircase_height+1, r=stair_r_inner - pipe_thickness);
        // flue pipe hole
        translate([0,0,48]) rotate([90,0,0]) cylinder(h=stair_r_inner*2, d=8);
    }
}

module support_ring(r_outer, height) {
    translate([0,0,staircase_height - joist_height - height]) linear_extrude(ring_height) difference() {
        circle(r=r_outer + 3 + 2);
        circle(r=r_outer + 3);
    }
    angle = stairAngle(stair_rise, stair_r_inner, stair_width);
    ring_post(0 + angle, r_outer);
    ring_post(120 + angle, r_outer);
    ring_post(240 + angle, r_outer);
}
module ring_post(angle, r_outer) {
    rotate(angle) translate([r_outer + 2*2, 0, 0]) cylinder(h=staircase_height - joist_height - ring_height, r=2);
}

staircase();

// person simulator
//translate([23,-15,stair_rise]) cylinder(75,r=9);

