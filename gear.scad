
// tooth_clearance is extra absolute distance to leave between meshing teeth
function gearParams(tooth_count, tooth_width, pressure_angle, tooth_clearance) = [tooth_count, tooth_width, pressure_angle, tooth_clearance];
function gearToothCount(params) = params[0];
function gearToothWidth(params) = params[1];
function gearPressureAngle(params) = params[2];
function gearToothClearance(params) = params[3];
function gearRadius(tooth_width, tooth_count) = tooth_width * 2 * tooth_count / PI / 2;
function modToothClearance(params, clearance) = [params[0], params[1], params[2], clearance];

module gear(params) {
    tooth_width = gearToothWidth(params);
    tooth_count = gearToothCount(params);
    pressure_angle = gearPressureAngle(params);
    tooth_clearance = gearToothClearance(params);

    addendum_clearance = 0.05; // fraction of addendum
    addendum = tooth_width*2/PI; // how far above+below pitch line teeth go

    addendum_big = (1 + addendum_clearance) * addendum;
    addendum_small = (1 - addendum_clearance) * addendum;
    circum = tooth_width * 2 * tooth_count;
    diameter = circum / PI;
    radius = diameter / 2;

    // calculate tooth points
    tooth_width_plus = tooth_width + tooth_clearance;
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

    difference() {
        circle(d=diameter + 2*addendum_small);
        // subtract out the hole each meshing tooth takes out of our gear as it passes by
        for (i = [0:tooth_count-1]) {
            rotate(a=[0, 0, i*360/tooth_count]) {
                // simulate each tooth by translating it along the x axis
                for (j = [-15:15]) {
                    dx = j / 30 * 4 * tooth_width;
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
    tooth_clearance = gearToothClearance(inner_gear_params);
    modded_params = modToothClearance(inner_gear_params, -tooth_clearance);

    inner_circum = tooth_width * 2 * inner_tooth_count;
    inner_diameter = inner_circum / PI;
    inner_radius = inner_diameter / 2;
    outer_circum = tooth_width * 2 * tooth_count;
    outer_diameter = outer_circum / PI;
    outer_radius = outer_diameter / 2;
    
    addendum_clearance = 0.2; // fraction of addendum
    addendum = tooth_width*2/PI; // how far above+below pitch line teeth go
    addendum_small = (1 - addendum_clearance) * addendum;
    
    ring_width = 2 * tooth_width;
    inner_axle_radius = outer_radius - inner_radius;
    ndivs = 20;
    difference() {
        difference() {circle(r=outer_radius + ring_width);circle(r=outer_radius - addendum_small);}
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i/tooth_count*360]) {
                for (j = [0:ndivs-1]){
                    frac = j / ndivs;
                    dtheta_outer = frac * 360 / tooth_count;
                    dtheta_inner = -frac / inner_tooth_count * 360;
                    rotate([0,0,dtheta_outer]) translate([0,inner_axle_radius,0]) rotate([0,0,dtheta_inner]) gear(modded_params);
                }
            }
        }
    }
}


gear_params = gearParams(15, 1, 18, .03);
inner_axle_radius = gearRadius(1, 50) - gearRadius(1, 15);
translate([0,inner_axle_radius,0]) gear(gear_params);
ring(50,gear_params);
