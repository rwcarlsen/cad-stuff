$fn=100;

// gear parameters
tooth_count = 15;
tooth_width = 1;
pressure_angle = 13;
tooth_width_clearance = .03; // extra absolute distance to leave between meshing teeth



addendum_clearance = 0.05; // fraction of addendum
addendum = tooth_width*2/PI; // how far above+below pitch line teeth go

////// end user parameters /////
addendum_big = (1 + addendum_clearance) * addendum;
addendum_small = (1 - addendum_clearance) * addendum;
circum = tooth_width * 2 * tooth_count;
diameter = circum / PI;
radius = diameter / 2;

// calculate tooth points
tooth_width_plus = tooth_width + tooth_width_clearance;
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
            for (j = [-25:25]) {
                dx = j / 50 * 4 * tooth_width;
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
