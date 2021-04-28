$fn = 60;

// backlash is extra absolute distance to leave between meshing teeth
function gearParams(tooth_count, tooth_width, pressure_angle, backlash) = [tooth_count, tooth_width, pressure_angle, backlash];
function gearToothCount(params) = params[0];
function gearToothWidth(params) = params[1];
function gearPressureAngle(params) = params[2];
function gearBacklash(params) = params[3];
function gearRadius(tooth_width, tooth_count) = tooth_width * 2 * tooth_count / PI / 2;
function modBacklash(params, backlash) = [params[0], params[1], params[2], backlash];

module gear(params) {
    tooth_width = gearToothWidth(params);
    tooth_count = gearToothCount(params);
    pressure_angle = gearPressureAngle(params);
    backlash = gearBacklash(params);

    addendum_clearance = 0.05; // fraction of addendum
    addendum = tooth_width*2/PI; // how far above+below pitch line teeth go

    addendum_big = (1 + addendum_clearance) * addendum;
    addendum_small = (1 - addendum_clearance) * addendum;
    circum = tooth_width * 2 * tooth_count;
    diameter = circum / PI;
    radius = diameter / 2;

    // calculate tooth points
    tooth_width_plus = tooth_width + backlash;
    x1 = -tooth_width_plus / 2 - addendum_big*sin(pressure_angle);
    y1 = radius + addendum_big*cos(pressure_angle);
    x2 = -1 * x1;
    y2 = y1;
    x3 = x2 - 2*addendum_big*sin(pressure_angle);
    y3 = y2 - 2 * addendum_big*cos(pressure_angle);
    x4 = -1 * x3;
    y4 = y3;

    pt1 = [x1, y1];
    pt2 = [x2, y2];
    pt3 = [x3, y3];
    pt4 = [x4, y4];
    pts = [pt1, pt2, pt3, pt4];

    ndivs = 15;
    difference() {
        circle(d=diameter + 2*addendum_small);
        // subtract out the hole each meshing tooth takes out of our gear as it passes by
        for (i = [0:tooth_count-1]) {
            rotate(a=[0, 0, i*360/tooth_count]) {
                // simulate each tooth by translating it along the x axis
                for (j = [-(ndivs-1):ndivs-1]) {
                    dx = j / (2*ndivs) * 4 * tooth_width;
                    dtheta = dx / circum * 360;
                    // and rotating it as much as our gear would have to rotate
                    rotate(a=[0, 0, dtheta]) {
                        translate([dx,0,0]){
                            polygon(pts);
                        }
                    }
                }
            }
        }
    }
}

module ring(tooth_count, inner_gear_params) {
    tooth_width = gearToothWidth(inner_gear_params);
    inner_tooth_count = gearToothCount(inner_gear_params);
    pressure_angle = gearPressureAngle(inner_gear_params);
    backlash = gearToothClearance(inner_gear_params);
    modded_params = modBacklash(inner_gear_params, -backlash);

    inner_circum = tooth_width * 2 * inner_tooth_count;
    inner_diameter = inner_circum / PI;
    inner_radius = inner_diameter / 2;
    outer_circum = tooth_width * 2 * tooth_count;
    outer_diameter = outer_circum / PI;
    outer_radius = outer_diameter / 2;
    
    addendum_clearance = 0.15; // fraction of addendum
    addendum = tooth_width*2/PI; // how far above+below pitch line teeth go
    addendum_small = (1 - addendum_clearance) * addendum;
    
    ring_width = 2 * tooth_width;
    inner_axle_radius = outer_radius - inner_radius;
    ndivs = 7;
    difference() {
        difference() {circle(r=outer_radius + ring_width);circle(r=outer_radius - addendum_small);}
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i/tooth_count*360]) {
                for (j = [-ndivs+1:ndivs-1]){
                    frac = j / ndivs;
                    dtheta_outer = frac * 360 / tooth_count;
                    dtheta_inner = -frac / inner_tooth_count * 360;
                    rotate([0,0,dtheta_outer]) translate([0,inner_axle_radius,0]) rotate([0,0,dtheta_inner]) gear(modded_params);
                }
            }
        }
    }
}

module hole(d) {
    difference() {children(0); circle(d=d);}
}

// create the gears/assembly
module planetary_gear_stage(n_planets, planet_params, sun_params, ring_teeth, sun_hole, planet_hole, thickness) {
    sun_teeth = gearToothCount(sun_params);
    assert((ring_teeth - sun_teeth) % 2 == 0, "difference between sun and ring tooth count must be even");
    assert(sun_teeth % n_planets == 0, "sun_teeth count must be a multiple of n_planets");
    assert(ring_teeth % n_planets == 0, "ring_teeth count must be a multiple of n_planets");
    linear_extrude(height=thickness) {
        for (i = [0:n_planets - 1]) hole(d=planet_hole) gear(planet_params);
        hole(d=sun_hole) gear(sun_params);
        ring(ring_teeth,planet_params);
    }
}

module planet_carrier(n_arms, arm_width, arm_length, hole_dia, thickness) {
    union() {
        linear_extrude(height=thickness) {
            for (i = [0:n_arms - 1]) {
                angle = 360 / n_planets * i;
                rotate([0,0,angle]) {
                    difference() {
                        union() {
                            circle(d=arm_width);
                            translate([0,arm_length,0]) circle(d=arm_width);
                            translate([0,arm_length/2,0]) square([arm_width,arm_length],true);
                        }
                        circle(d=hole_dia);
                    }
                }
            }
        }

        for (i = [0:n_arms - 1]) {
            angle = 360 / n_arms * i;
            rotate([0,0,angle]) translate([0,arm_length,0]) cylinder(h=2*thickness, d=hole_dia);
        }
    }
}

module assemble(planet_params, sun_params, carrier_lift=0) {
    n_planets = $children - 3;
    for (i = [0:n_planets - 1]) {
        dtheta = 360 / n_planets * i;
        rotate([0,0,dtheta]) translate([0,planet_axle_radius,0]) children(i);
    }
    sun_index = n_planets + 0;
    sun_rot = (1 - gearToothCount(planet_params) % 2) * 360 / 2 / gearToothCount(sun_params);
    rotate(sun_rot) children(sun_index);
    carrier_index = n_planets + 2;
    translate([0,0,carrier_lift]) rotate([0,180,0]) children(carrier_index);
};


// user custom parameters
tooth_width = 3/16;
backlash = .003;
pressure_angle = 18;
n_planets = 3;
sun_teeth = 9; // must be multiple of n_planets;
ring_teeth = 33; // must be multiple of n_planets and "ring_teeth-sun_teeth" must be even.
sun_hole = .375;
planet_hole = .375;
thickness = 0.25;
carrier_arm_width = 2.5*planet_hole;


// calc various relevant parameters
planet_teeth = (ring_teeth - sun_teeth) / 2;
sun_params = gearParams(sun_teeth, tooth_width, pressure_angle, backlash);
planet_params = gearParams(planet_teeth, tooth_width, pressure_angle, backlash);
planet_radius = gearRadius(tooth_width, planet_teeth);
sun_radius = gearRadius(tooth_width, sun_teeth);
ring_radius = gearRadius(tooth_width, ring_teeth);
planet_arm_radius = ring_radius - planet_radius;
echo("ring_diameter=", 2*ring_radius);

assemble(planet_params, sun_params, carrier_lift=2) {
    planetary_gear_stage(n_planets, planet_params, sun_params, ring_teeth, sun_hole, planet_hole, thickness);
    planet_carrier(n_planets, carrier_arm_width, planet_arm_radius, hole_dia, thickness);
}
