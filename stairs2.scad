$fn = 100;

// config params
pipe_diameter = 10;
pipe_thickness = 0.375;
staircase_height = 117;
staircase_angle = 360;
n_steps = 14; // number of steps up
handrail_height = 36;
handrail_diameter = 2;
ballister_side = 1; // side-length of square tube for ballister
ballister_thickness = .125;
ballister_plate_thickness = .125;
angle_support_thickness = 0.25; // angle iron that the stairs rest on that is welded to the pipe
angle_iron_vert=3;
angle_iron_horiz=2;
n_angle_holes = 4; // holes to screw angle into tread
angle_hole_dia = .125; // holes to screw angle into tread
tread_thickness = 1.5;
bound_ring_diameter = 84; // e.g. the radial distance to things outside of the stairs
outer_handrail_gap = 1.5; // distance between outer edge of handrail and e.g. the posts or ring beam

// calc'd params
stair_angle = staircase_angle / (n_steps - 1);
stair_rise = staircase_height / n_steps;
ballister_length = stair_rise + tread_thickness + angle_support_thickness + handrail_height - handrail_diameter;
stair_width = (bound_ring_diameter - pipe_diameter)/2 - outer_handrail_gap - handrail_diameter/2 + ballister_side/2;
stair_outer_radius = pipe_diameter/2 + stair_width;
stair_inner_radius = pipe_diameter/2;
stair_arclength = stair_outer_radius*2*PI*stair_angle/360;
ballister_top_angle = atan(stair_rise/stair_arclength);
ballister_length_with_angle = tan(ballister_top_angle)*ballister_side + ballister_length;
pipe_height = staircase_height + handrail_height;

echo("stair rise:", stair_rise);
echo("stair angle:", stair_angle);
echo("stair width:", stair_width);
echo("stair arclength:", stair_arclength);
echo("ballister length:", ballister_length);
echo("ballister top angle:", ballister_top_angle);
echo("ballister length with angle:", ballister_length_with_angle);
echo("pipe height:", pipe_height);



module pipe(height, radius, thickness) {
    difference() {
        cylinder(h=height, r=radius);
        cylinder(h=3*height, r=radius-thickness, center=true);
    }
}

module angle_iron(length, leg1, leg2, thickness) {
    cube([length, leg1, thickness]);
    translate([0, leg1 - thickness, 0]) cube([length, thickness, leg2]);
}

module tube(length, leg1, leg2, thickness) {
    difference() {
        cube([length, leg1, leg2]);
        translate([-length/2, thickness, thickness]) cube([2*length, leg1-2*thickness, leg2 - 2*thickness]);
    }
}

module wedge(r1, r2, thickness) {
    rotate([0, 0, 90]) difference() {
        cylinder(h=thickness, r=r2);
        cylinder(h=3*thickness, r=r1, center=true);
        translate([0, -1.5*r2, -thickness/2]) cube([2*r2, 3*r2, 2*thickness]);
        rotate([0, 0, 180-stair_angle]) translate([0, -1.5*r2, -thickness/2]) cube([2*r2, 3*r2, 2*thickness]);
    }
}

//pipe(120, 5, .375);
//angle_iron(35, 2, 3, .25);
//tube(45, 1, 1, .125);



module holed_angle_iron(length, leg1, leg2, thickness, n_holes, hole_dia) {
    dx = length/n_holes;
    difference() {
        angle_iron(length, leg1, leg2, thickness);
        for(n=[0:n_holes-1]) {
            x = n*dx + dx/2;
            y = leg1/2;
            translate([x, y, 0]) cylinder(h=thickness*3, r=hole_dia/2, center=true);
        }
    }
}

module angle_iron_support() {
    // create angle iron support for back of tread
    rotate([0,0,180]) translate([-stair_width-stair_inner_radius, -angle_iron_horiz+angle_support_thickness, 0]) holed_angle_iron(stair_width, angle_iron_horiz, angle_iron_vert, angle_support_thickness, n_angle_holes, angle_hole_dia);
}
module ballister() {
    rotate(-stair_angle) translate([stair_outer_radius, -ballister_side-angle_support_thickness, 0]) difference() {
        length=ballister_length_with_angle;
        rotate([0,-90,0]) tube(length, ballister_side, ballister_side, ballister_thickness);
    
        translate([0,0,length]) rotate([-ballister_top_angle,0,0]) translate([-ballister_side*2, -ballister_side*2, 0]) cube(4*ballister_side);
    }
}

module ballister_plate() {
    difference() {
        cube([2*ballister_side, 2*ballister_side, ballister_plate_thickness]);
        translate([-ballister_side,-ballister_side,-1.5*ballister_plate_thickness]) cube([2*ballister_side, 2*ballister_side, 3*ballister_plate_thickness]);
        cylinder(h=3*ballister_plate_thickness, r=
    }
}

module tread() {
    translate([0,0,angle_support_thickness]) wedge(stair_inner_radius, stair_outer_radius, tread_thickness);
}

module support_pipe() {
    echo("foo", pipe_height, pipe_diameter, pipe_thickness);
    pipe(pipe_height, pipe_diameter/2, pipe_thickness);
}

module full_stair() {
    color("tan") tread();
    color("darkgrey") rotate(-stair_angle) angle_iron_support();
    color("skyblue") ballister();
}

module staircase() {
    color("grey") support_pipe();
    for (n=[0:n_steps-2]) {
        dz = stair_rise + n*stair_rise;
        dtheta = -n*stair_angle;
        rotate(dtheta) translate([0,0,dz]) full_stair();
    }
}

ballister_plate();
//staircase();

