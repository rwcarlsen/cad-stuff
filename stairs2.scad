$fn = 300;

//////////////// config params //////////////////
level1_floor_thickness = 0.75;
level2_floor_thickness = 0.75;

staircase_angle = 360;
n_steps = 14; // number of steps up
stair_overlap_middle = .5;
handrail_height = 36;
handrail_diameter = 1.75;
ballister_side = 1; // side-length of square tube for ballister
ballister_thickness = .125;
ballister_plate_thickness = .25;
angle_support_thickness = 0.25; // angle iron that the stairs rest on that is welded to the pipe
angle_iron_vert=3;
angle_iron_horiz=2;
n_angle_holes = 4; // holes to screw angle into tread
angle_hole_dia = .125; // holes to screw angle into tread
tread_thickness = 1.375;
outer_handrail_gap = 1.5; // distance between outer edge of handrail and e.g. the posts or ring beam

//////////////// Actual fixed physical params //////////////////
landing_arclength = 35;
post_angle_offset = 52.52; // angle rotation of post from start of first stair.
joist_height = 7.25;
pipe_diameter = 10;
pipe_thickness = 0.375;
staircase_height_raw = 117; // without floors
bound_ring_diameter = 83; // e.g. the min radial clearance to things outside of the stairs


//////////// calc'd params //////////////////
staircase_height = staircase_height_raw - level1_floor_thickness + level2_floor_thickness;
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
stair_run_middle = (stair_outer_radius + stair_inner_radius) * PI * stair_angle/360;
stair_angle_with_overlap = (1 + stair_overlap_middle/stair_run_middle) * stair_angle;
stair_arclength_with_overlap = stair_outer_radius*2*PI*stair_angle_with_overlap/360;
stair_overlap_outer = stair_arclength_with_overlap - stair_arclength;
head_clearance = 360/stair_angle*stair_rise - stair_rise - landing_arclength/stair_arclength*stair_rise;
landing_angle = (landing_arclength + ballister_side + angle_support_thickness) / PI / bound_ring_diameter * 360;
landing_angle_with_overlap = landing_angle + (stair_angle_with_overlap - stair_angle);

// height of the bottom of the first stair angle iron support off of the concrete
first_stair_height = stair_rise - tread_thickness - angle_support_thickness + level1_floor_thickness;

echo("stair outer radius:", stair_outer_radius);
echo("head clearance:", head_clearance);
echo("landing angle:", landing_angle);
echo("staircase height:", staircase_height);
echo("first stair support vertical offset:", first_stair_height);
echo("stair rise:", stair_rise);
echo("stair run middle:", stair_run_middle);
echo("stair angle:", stair_angle);
echo("stair width:", stair_width);
echo("stair arclength:", stair_arclength);
echo("ballister length:", ballister_length);
echo("ballister top angle:", ballister_top_angle);
echo("ballister length with angle:", ballister_length_with_angle);
echo("pipe height:", pipe_height);
echo("stair angle with overlap:", stair_angle_with_overlap);
echo("stair arclength with overlap:", stair_arclength_with_overlap);
echo("stair overlap outer:", stair_overlap_outer);

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

module wedge(r1, r2, angle, thickness) {
    rotate([0, 0, 90]) difference() {
        cylinder(h=thickness, r=r2);
        cylinder(h=3*thickness, r=r1, center=true);
        translate([0, -1.5*r2, -thickness/2]) cube([2*r2, 3*r2, 2*thickness]);
        rotate([0, 0, 180-angle]) translate([0, -1.5*r2, -thickness/2]) cube([2*r2, 3*r2, 2*thickness]);
    }
}

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
    rotate(-stair_angle_with_overlap) translate([stair_outer_radius + angle_support_thickness, -ballister_side-angle_support_thickness, 0]) difference() {
        length=ballister_length_with_angle;
        rotate([0,-90,0]) tube(length, ballister_side, ballister_side, ballister_thickness);
    
        translate([0,0,length]) rotate([-ballister_top_angle,0,0]) translate([-ballister_side*2, -ballister_side*2, 0]) cube(4*ballister_side);
    }
}
module landing_ballister() {
    rotate(-stair_angle_with_overlap) translate([stair_outer_radius, -ballister_side-angle_support_thickness, 0])
        rotate([0,-90,0]) tube(handrail_height - handrail_diameter/2, ballister_side, ballister_side, ballister_thickness);
}

module tread() {
    translate([0,0,angle_support_thickness]) wedge(stair_inner_radius, stair_outer_radius, stair_angle_with_overlap, tread_thickness);
}

module support_pipe() {
    pipe(pipe_height, pipe_diameter/2, pipe_thickness);
}

module full_stair() {
    color("tan") tread();
    color("silver") rotate(-stair_angle_with_overlap) angle_iron_support();
    color("grey") ballister();
    color("pink") outer_stair_support();
}

module landing() {
    color("tan") translate([0,0,angle_support_thickness]) wedge(stair_inner_radius, stair_outer_radius, landing_angle_with_overlap, tread_thickness);
    color("silver") rotate(-landing_angle_with_overlap) angle_iron_support();
    color("grey") rotate(stair_angle_with_overlap-landing_angle_with_overlap) landing_ballister();
    color("pink") outer_stair_support(arclength=landing_arclength);
}

// negative radius means rolled/curved leg-in; positive radius is for leg-out.
// leg1 points along the rolled/curved axis and its outer edge lies on the radius;
module bent_angle_iron(length, leg1, leg2, thickness, radius) {
    theta = length/(2*PI*radius)*360;
    rotate_extrude(angle=theta, convexity=10) translate([radius,0,0]) {
        square([leg2, thickness]);
        square([thickness, leg1]);
    }
}

module staircase() {
    color("grey") support_pipe();
    for (n=[0:n_steps-2]) {
        dz = first_stair_height + n*stair_rise;
        dtheta = -n*stair_angle;
        echo(stair=n+1, height=dz, angle=-dtheta+stair_angle_with_overlap);
        rotate(dtheta) translate([0,0,dz]) full_stair();
    }
    dz = first_stair_height + (n_steps-1)*stair_rise;
    echo("landing height (farthest clockwise angle support bottom dz off concrete):", dz);
    echo("landing angle:", staircase_angle + landing_angle);
    translate([0,0,dz]) rotate(staircase_angle) landing();
    color("pink") handrail();
}

module handrail() {
    start_height = ballister_length - tread_thickness +  level1_floor_thickness;
    
    r_rail = stair_outer_radius - 0.5*ballister_side;
    n = 360;
    d_arc = 2*PI*r_rail/n;
    d_theta = staircase_angle/n;
    d_h = (staircase_height-stair_rise)/n;
    for (i=[0:n+3]) {
        theta = i*d_theta;
        arc = i*d_arc;
        
        h = start_height + i*d_h;
        length = 1.2*d_arc;
        rotate(-theta) translate([0,0,h]) rotate([90-ballister_top_angle,0,0]) translate([r_rail,0,-length/2]) pipe(length, handrail_diameter/2, 0.125);
    }
}

module support_ring() {
    ring_height = 7;
    ring_radius = 42;
    translate([0,0,staircase_height - joist_height - ring_height]) linear_extrude(ring_height) difference() {
        circle(r=ring_radius + 2);
        circle(r=ring_radius);
    }
    ring_post(post_angle_offset + 0, ring_radius + 1, ring_height);
    ring_post(post_angle_offset + 120, ring_radius + 1, ring_height);
    ring_post(post_angle_offset + 240, ring_radius + 1, ring_height);
}
module ring_post(angle, r_outer, ring_height) {
    rotate(angle) translate([r_outer, 0, 0]) translate([1.5, -1.5, 0]) rotate([0,-90,0]) tube(staircase_height - joist_height - ring_height, 3, 3, 0.25);
}

staircase();
color("skyblue") support_ring();

module outer_stair_support(arclength=stair_arclength) {
    length = arclength - ballister_side;
    echo("stair_support:", length);
    leg = 1.5;
    thickness = 0.25;
    notch_length = angle_iron_horiz;
    position_dtheta = (notch_length + angle_support_thickness)/2/PI/stair_outer_radius*360;
    theta_notch = (length-notch_length)/2/PI/stair_outer_radius*360;
    translate([thickness,0,0]) rotate(180-position_dtheta) difference(convexity=50) {
        bent_angle_iron(length, leg, leg, thickness, -stair_outer_radius);
        rotate(-theta_notch) translate([0,0,-.2*thickness]) bent_angle_iron(1.05*notch_length, 1.5*leg, 1.5*leg, 1.5*thickness, -stair_outer_radius + thickness);
    }
}

