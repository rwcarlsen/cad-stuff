$fn = 60;
resolution = 10; // 10 is high/good

// backlash is extra absolute distance to leave between meshing teeth
function gearParams(tooth_count, tooth_width, pressure_angle, backlash, addendum_factor=2/PI) = [tooth_count, tooth_width, pressure_angle, backlash, addendum_factor];
function gearToothCount(params) = params[0];
function gearToothWidth(params) = params[1];
function gearPressureAngle(params) = params[2];
function gearBacklash(params) = params[3];
function gearAddendum(params) = params[4]*gearToothWidth(params);
function gearRadius(tooth_width, tooth_count) = tooth_width * 2 * tooth_count / PI / 2;
function gearRadiusP(params) = gearToothWidth(params) * 2 * gearToothCount(params) / PI / 2;
function modBacklash(params, backlash) = [params[0], params[1], params[2], backlash, params[4]];

module spurToothHole(params, addendum_clearance) {
    tooth_width = gearToothWidth(params);
    tooth_count = gearToothCount(params);
    pressure_angle = gearPressureAngle(params);
    backlash = gearBacklash(params);
    addendum = gearAddendum(params);

    addendum_big = (1 + addendum_clearance) * addendum;
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

    ndivs = 2*resolution;
    // simulate each contact position by translating it along the x axis
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

module spurTooth(params, addendum_clearance) {
    tooth_count = gearToothCount(params);
    addendum = gearAddendum(params);
    eps=.001;

    addendum_small = (1 - addendum_clearance) * addendum;
    circum = tooth_width * 2 * tooth_count;
    diameter = circum / PI;
    outer_dia = diameter + 2*addendum_small;
    
    rotate(-360/(2*tooth_count)) {
        difference() {
            circle(d=outer_dia);

            // subtract off the rest of the gear/circle except a single pie slice around tooth
            translate([0, -(outer_dia+eps)/2, 0]) square(outer_dia+eps);
            rotate(360/tooth_count) translate([-outer_dia+eps, -(outer_dia+eps)/2, 0]) square(outer_dia+eps);
            // subtract out the hole each meshing tooth takes out of our gear as it passes by
            for (i = [0, 1]) {
                rotate(a=[0, 0, i*360/tooth_count]) spurToothHole(params, addendum_clearance);
            }
        }
    }
}

module spurGear(params, addendum_clearance=0.05) {
    tooth_count = gearToothCount(params);
    addendum = gearAddendum(params);

    addendum_small = (1 - addendum_clearance) * addendum;
    circum = tooth_width * 2 * tooth_count;
    diameter = circum / PI;

    difference() {
        circle(d=diameter + 2*addendum_small);
        // subtract out the hole each meshing tooth takes out of our gear as it passes by
        for (i = [0:tooth_count-1]) {
            rotate(a=[0, 0, i*360/tooth_count]) spurToothHole(params, addendum_clearance);
        }
    }
}

// generally the inner_gear_params should be for the planet gears.
module ring(tooth_count, inner_gear_params, hole_dia, thickness, addendum_clearance=0.05) {
    tooth_width = gearToothWidth(inner_gear_params);
    inner_tooth_count = gearToothCount(inner_gear_params);
    pressure_angle = gearPressureAngle(inner_gear_params);
    backlash = gearBacklash(inner_gear_params);
    addendum = gearAddendum(inner_gear_params);
    modded_params = modBacklash(inner_gear_params, -backlash);

    inner_circum = tooth_width * 2 * inner_tooth_count;
    inner_diameter = inner_circum / PI;
    inner_radius = inner_diameter / 2;
    outer_circum = tooth_width * 2 * tooth_count;
    outer_diameter = outer_circum / PI;
    outer_radius = outer_diameter / 2;
    
    ring_addendum_clearance = 0.15; // for the ring specifically - not the ring's inner gear(s)
    addendum_small = (1 - ring_addendum_clearance) * addendum;
    
    ring_width = 2 * tooth_width;
    inner_axle_radius = outer_radius - inner_radius;
    ndivs = resolution;
    // bottom plate
    linear_extrude(height=thickness) {
        difference() { circle(r=outer_radius + ring_width); circle(r=outer_radius - inner_radius);}
        intersection() {
            circle(r=outer_radius + ring_width);
            hole(d=hole_dia) translate([-outer_diameter,-hole_dia,0]) square([2*outer_diameter, 2*hole_dia]);
        }
    }
    
    rotate(360/(2*ring_teeth)) linear_extrude(height=2*thickness) {
        difference() {
            difference() {circle(r=outer_radius + ring_width); circle(r=outer_radius - addendum_small);}
            for (i = [0:tooth_count-1]) {
                dtheta_initial = i/tooth_count*360;
                rotate([0,0,i/tooth_count*360]) {
                    for (j = [-ndivs+1:ndivs-1]) {
                        frac = j / ndivs;
                        dtheta_outer = frac * 360 / tooth_count;
                        dtheta_inner = -frac / inner_tooth_count * 360;
                        rotate([0,0,dtheta_outer]) rotate(dtheta_initial) translate([0,inner_axle_radius,0]) rotate(dtheta_inner) spurTooth(modded_params, addendum_clearance);
                    }
                }
            }
        }
    }
    
    // top bracket alignment pins
    pin_height = thickness/2;
    translate([-outer_radius-tooth_width, 0, thickness]) cylinder(h=thickness+pin_height, d=tooth_width);
    translate([+outer_radius+tooth_width, 0, thickness]) cylinder(h=thickness+pin_height, d=tooth_width);
}

module hole(d) {
    difference(convexity=10) {children(0); circle(d=d);}
}

module spurGear3D(params, thickness, shaft_d=0) {
    inset = thickness / 4;
    addendum = gearAddendum(params);
    inset_r2 = gearRadiusP(params) - addendum-1/16;
    inset_r1 = shaft_d/2 + 1/16;
    difference(convexity=10) {
        linear_extrude(height=thickness, convexity=10) hole(d=shaft_d) spurGear(params);
        translate([0,0,-.05*thickness])
            linear_extrude(height=0.1*thickness, convexity=10) hole(d=2*inset_r1) circle(r=inset_r2);
    }
}

module topBracket(tooth_count, inner_gear_params, hole_dia, thickness) {
    tooth_width = gearToothWidth(inner_gear_params);
    inner_tooth_count = gearToothCount(inner_gear_params);
    pressure_angle = gearPressureAngle(inner_gear_params);
    addendum = gearAddendum(inner_gear_params);

    outer_circum = tooth_width * 2 * tooth_count;
    outer_diameter = outer_circum / PI;
    outer_radius = outer_diameter / 2;
    
    ring_width = 2 * tooth_width;
    pin_height = thickness/2;
    difference(convexity=10) {
        linear_extrude(height=2*thickness, convexity=10) {
            intersection(convexity=10) {
                circle(r=outer_radius + ring_width);
                hole(d=hole_dia) square([2*outer_diameter, 2*hole_dia], center=true);
            }
        }
        // the 0.1 are just to avoid quick-prievew/render artifacts
        translate([0,0,-1.1*thickness]) cylinder(h=2.1*thickness, r=outer_radius + addendum);
        // alignment pin holes
        translate([-outer_radius-tooth_width,0,-2*thickness+pin_height]) cylinder(h=2*thickness, d=tooth_width);
        translate([+outer_radius+tooth_width,0,-2*thickness+pin_height]) cylinder(h=2*thickness, d=tooth_width);

    }
}

module planet_carrier(n_arms, arm_width, arm_length, hole_dia, thickness) {
    length = arm_length - (arm_width - hole_dia) *0.25; // reduced length to match arm outer curve to carrier pins
    tolerance = .001; // space to make pins smaller than holes to allow free turning
    union() {
        linear_extrude(height=thickness-1/32, convexity=10) {
            for (i = [0:n_arms - 1]) {
                angle = 360 / n_planets * i;
                rotate([0,0,angle]) {
                    difference(convexity=10) {
                        union() {
                            circle(d=arm_width);
                            translate([0,length,0]) circle(d=arm_width);
                            translate([0,length/2,0]) square([arm_width,length],true);
                        }
                        circle(d=hole_dia);
                    }
                }
            }
        }
        
        pad_radius = length+arm_width/2-arm_length;
        linear_extrude(height=thickness, convexity=10) hole(d=hole_dia) circle(r=pad_radius); // center pad
        for (i = [0:n_arms - 1]) {
            angle = 360 / n_arms * i;
            rotate([0,0,angle]) translate([0,arm_length,0]) cylinder(h=2*thickness, d=hole_dia-tolerance); // pins
            rotate([0,0,angle]) translate([0,arm_length,0]) cylinder(h=thickness, r=pad_radius); // pads
        }
    }
}

module assembly_layout(n_planets, planet_params, sun_params, ring_teeth, thickness, carrier_lift=0) {
    planet_arm_radius = gearRadius(gearToothWidth(planet_params), ring_teeth) - gearRadiusP(planet_params);;
    assert($children == 5, "wrong number of child pieces passed in to assemble module");
    planet_index = 0;
    sun_index = 1;
    ring_index = 2;
    carrier_index = 3;
    bracket_index = 4;
    
    sun_radius = gearRadiusP(sun_params);
    sun_circ = 2*PI*sun_radius;
    planet_radius = gearRadiusP(planet_params);
    ring_radius = gearRadius(gearToothWidth(planet_params), ring_teeth);
    t_mult = $t * (1+ring_radius / sun_radius);
    sun_time_angle = t_mult * 270;
    planet_time_angle = -$t * 270 * ring_radius / planet_radius;
    carrier_time_angle = t_mult * 270 * (1/(1+ring_radius / sun_radius));
    
    for (i = [0:n_planets - 1]) {
        dtheta = 360 / n_planets * i + carrier_time_angle;
        rotate(dtheta) translate([0,planet_arm_radius,0]) rotate(planet_time_angle) color("plum") children(planet_index);
    }
    sun_rot = (1 - gearToothCount(planet_params) % 2) * 360 / 2 / gearToothCount(sun_params);
    rotate(sun_rot + sun_time_angle) color("gold") children(sun_index);
    translate([0,0,-thickness]) color("red") children(ring_index);
    rotate(carrier_time_angle) translate([0,0,carrier_lift + 2*thickness]) rotate([0,180,0]) color("green") children(carrier_index);
    translate([0,0,thickness + 2*carrier_lift])  color("pink") children(bracket_index);
};

module milling_layout(n_planets, planet_params, sun_params, ring_teeth, thickness) {
    assert($children == 5, "wrong number of child pieces passed in to assemble module");
    planet_index = 0;
    sun_index = 1;
    ring_index = 2;
    carrier_index = 3;
    bracket_index = 4;


    addendum = gearAddendum(sun_params);
    ring_radius = gearRadius(gearToothWidth(planet_params), ring_teeth);
    sun_radius = gearRadiusP(sun_params);
    planet_radius = gearRadiusP(planet_params);
    planet_arm_radius = ring_radius - gearRadiusP(planet_params);
    gears_dx = 2.75*ring_radius;

    tabwidth = gearToothWidth(sun_params)*.75;
    tablength = 3*addendum;
    tabspine_start = ring_radius;
    tabspine_length = 3*planet_radius + 1.3*addendum + floor(n_planets/2) * (2 * planet_radius + 4 * addendum);
    translate([tabspine_start, -tabwidth/2, 0]) cube([tabspine_length,tabwidth,thickness/2]);
    
    for (i = [0:n_planets]) {
        gear_params = i == 0 ? sun_params : planet_params;
        // calculate rotation angles so "inside" facing teeth point directly towards
        // eath other to allow for supports while machining
        rot = ((gearToothCount(gear_params) + i % 2 + 1) % 2) * 360 / 2 / gearToothCount(gear_params);
        dx = ring_radius + 2*planet_radius + floor(i/2) * (2 * planet_radius + 4 * addendum);
        dy = (2*(i % 2) - 1) * (planet_radius + 2 * addendum);
        child_index = i == 0 ? sun_index : planet_index;
        gear_color = i == 0 ? "gold" : "plum";
        color(gear_color) translate([dx, dy, thickness]) rotate([180,0,rot]) children(child_index);
            
        // build/add support tabs
        translate([dx-tabwidth/2, -tablength, 0]) cube([tabwidth, 2*tablength, thickness/2]);
        translate([tabspine_start, -tabwidth/2+dy-(2*(i%2)-1)*.7*addendum, 0]) cube([tabspine_length,tabwidth,thickness/2]);
    }
    
    color("green") translate([-2*ring_radius-addendum,0,0]) children(carrier_index);
    color("red") children(ring_index);
    bracket_dx = -3*ring_radius-3*addendum;
    color("pink") translate([bracket_dx,0,2*thickness]) rotate([0,180,90]) children(bracket_index);
    max_dx = ring_radius + 2*planet_radius + floor(n_planets/2) * (2 * planet_radius + 4 * addendum);
    echo("geometry_length=", max_dx - bracket_dx + sun_radius + planet_radius);
};

module gearToothTabs(gear_params, length, height, tabbed_teeth) {
    width = gearToothWidth(gear_params);
    r = gearRadiusP(gear_params);
    nteeth = gearToothCount(gear_params);
    for (n = tabbed_teeth) {
        dtheta = 360 / (nteeth * 2)*(nteeth%2) + (360*n/nteeth);
        rotate(dtheta) translate([-width/2, r, 0]) cube([width, length, height]);
    }
}

// user custom parameters
$vpr = [20, $t*360, 0];
tooth_width = 2.3/16;
backlash = .003;
pressure_angle = 18;
n_planets = 3;
sun_teeth = 9; // must be multiple of n_planets;
ring_teeth = 27; // must be multiple of n_planets and "ring_teeth-sun_teeth" must be even.
sun_hole = .25;
planet_hole = .25;
thickness = 0.1875;
carrier_arm_width = 2*planet_hole;
hole_tolerance = 0.001;

assert((ring_teeth - sun_teeth) % 2 == 0, "difference between sun and ring tooth count must be even");
assert(sun_teeth % n_planets == 0, "sun_teeth count must be a multiple of n_planets");
assert(ring_teeth % n_planets == 0, "ring_teeth count must be a multiple of n_planets");

// calc various relevant parameters
planet_teeth = (ring_teeth - sun_teeth) / 2;
sun_params = gearParams(sun_teeth, tooth_width, pressure_angle, backlash);
planet_params = gearParams(planet_teeth, tooth_width, pressure_angle, backlash);
planet_radius = gearRadiusP(planet_params);
sun_radius = gearRadiusP(sun_params);
ring_radius = gearRadius(tooth_width, ring_teeth);
planet_arm_radius = ring_radius - planet_radius;
echo("ring_diameter=", 2*(ring_radius+2*tooth_width));
echo("gear_ratio=", 1+ring_radius / sun_radius);

//assembly_layout(n_planets, planet_params, sun_params, ring_teeth, thickness, carrier_lift=0) {
//    spurGear3D(planet_params, thickness, shaft_d=planet_hole);
//    spurGear3D(sun_params, thickness, shaft_d=sun_hole);
//    ring(ring_teeth,planet_params, sun_hole + hole_tolerance, thickness);
//    planet_carrier(n_planets, carrier_arm_width, planet_arm_radius, planet_hole, thickness);
//    topBracket(ring_teeth,planet_params, sun_hole + hole_tolerance, thickness);
//}
milling_layout(n_planets, planet_params, sun_params, ring_teeth, thickness) {
    spurGear3D(planet_params, thickness, shaft_d=planet_hole);
    spurGear3D(sun_params, thickness, shaft_d=sun_hole);
    ring(ring_teeth,planet_params, sun_hole + hole_tolerance, thickness);
    planet_carrier(n_planets, carrier_arm_width, planet_arm_radius, planet_hole, thickness);
    topBracket(ring_teeth,planet_params, sun_hole + hole_tolerance, thickness);
}
