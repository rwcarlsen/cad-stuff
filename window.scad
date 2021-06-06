include <silo-common.scad>

module window_frame(w, h, elevation, header_h=6) {
    window_h_big = h + 2*stud_width;
    window_w_big = w + 2*stud_width;
    elevation_big = elevation - stud_width;
    
    cripple_h = elevation_big - 2*stud_width;
    jack_h = elevation_big + window_h_big - stud_width;
    king_h = floor1_ceil_h - 2*stud_width;
    color1 = "violet";
    color2 = "lightgreen";
    color3 = "skyblue";
    
    translate([-2*stud_width - w/2,-wall_thickness,stud_width]) group() {
        // jack studs
        color(color1) cube([stud_width, wall_thickness, jack_h]);
        color(color1) translate([window_w_big + stud_width, 0, 0]) cube([stud_width, wall_thickness, jack_h]);
        // king studs
        color(color2) translate([-stud_width,0,0]) cube([stud_width, wall_thickness, king_h]);
        color(color2) translate([window_w_big + 2*stud_width,0,0]) cube([stud_width, wall_thickness, king_h]);
        // sill cripples
        color(color3) translate([stud_width, 0, 0]) cube([stud_width, wall_thickness, cripple_h]);
        color(color3) translate([window_w_big, 0, 0]) cube([stud_width, wall_thickness, cripple_h]);
        // sill
        color(color2) translate([stud_width, 0, cripple_h]) cube([window_w_big, wall_thickness, stud_width]);
        //header
        color(color3) translate([0, 0, jack_h]) cube([window_w_big+2*stud_width, stud_width, header_h]);
        color(color3) translate([0, wall_thickness-stud_width, jack_h]) cube([window_w_big+2*stud_width, stud_width, header_h]);
        
        // wide frame
        //overhang = bin_d / 2 - 1/2*sqrt(bin_d^2 - (w + 6 * stud_width)^2) + corrugation_thickness;
        g_inner = bin_d / 2 - 1/2*sqrt(bin_d^2 - (w + 4 * stud_width)^2);
        bin_d_outer = bin_d + 2*corrugation_thickness;
        g_outer = bin_d_outer / 2 - 1/2*sqrt(bin_d_outer^2 - w^2);
        overhang = corrugation_thickness - g_outer + g_inner;
        frame_thickness = wall_thickness + overhang;
        echo("frame depth: ", frame_thickness);
        color(color1) translate([2*stud_width, 0, cripple_h+stud_width]) cube([window_w_big-2*stud_width, frame_thickness, stud_width]);
        color(color2) translate([stud_width, 0, jack_h - stud_width]) cube([window_w_big, frame_thickness, stud_width]);
        color(color3) translate([stud_width, 0, cripple_h + stud_width]) cube([stud_width, frame_thickness, h + stud_width]);
        color(color3) translate([window_w_big, 0, cripple_h + stud_width]) cube([stud_width, frame_thickness, h + stud_width]);
    }
}

module window_hole(w, h, angle, elevation) {
    ww = w + 2*stud_width;
    hh = h + 2*stud_width;
    rotate(angle) translate([-ww / 2, bin_d/2 - wall_thickness/2, elevation - stud_width]) cube([ww, wall_thickness * 2, hh]);
}

module window(w, h, angle, elevation) {
    offset = bin_d/2 - 1/2*sqrt(bin_d^2 - (w + 6*stud_width)^2);
    rotate(angle) translate([0, bin_d/2 - offset, 0]) window_frame(w, h, elevation);
}

w = 24;
h = 48;
elevation = 36;
window(w, h, 0, elevation);


