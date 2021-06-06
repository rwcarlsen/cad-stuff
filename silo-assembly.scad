include <silo-common.scad>

use <stairs.scad>
use <cabinets.scad>
use <window.scad>
use <silo-structure.scad>

window_w = 27.5;
window_h = 47;
stair_angle = stairAngle(stair_run, stair_r_inner, stair_width);

wall_plates();
roof();
difference() {
    wall();
    window_hole(24, 48, 0, 36);
}
window(24, 48, 0, 36);

rotate(-stair_angle) staircase();
cabinets();
