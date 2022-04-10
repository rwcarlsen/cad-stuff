SetFactory("OpenCASCADE");


inches = 1.0 / 39.3701; // converts inches to m
feet = 12 * inches; // converts feet to m

// beam geometry
radius = 3.5 * feet;

// beam parameters
flange = 2.09 * inches;
beam_height = 7 * inches;
thickness_out = 0.314 * inches; // thickness of the leg at its outer edge
thickness_in = 0.366 * inches; // leg at inner edge (near spine)
thickness_spine = 0.21 * inches; // spine thickness

// post parameters
post_height = 8.2 * feet;
post_width = 3 * inches;
post_thickness = 0.25 * inches;

// gusset parameters
gusset_offset = 2 * feet; // distance from corner (horizontal and verticle) to gusset end
gusset_width = 1 * inches;
gusset_thickness = 0.125 * inches;

// computed params
r_in = radius;
r_out = r_in + flange;
theta = 2*Pi/3;

/////////// points //////////////

Point(1) = {0,0,0};

// beam cross section points:
r_spine_out = r_in + thickness_spine; // radius at outer surface of spine
// bottom r_inner
// bottom r_outer
// bottom leg top surface outer
// bottom leg top surface inner
// top leg bottom surface inner
// top leg bottom surface outer
// top r_outer
// top r_inner
Point(2) = {-r_in*Sin(theta), r_in*Cos(theta), 0};
Point(3) = {-r_out*Sin(theta), r_out*Cos(theta), 0};
Point(4) = {-r_out*Sin(theta), r_out*Cos(theta), thickness_out};
Point(5) = {-r_spine_out*Sin(theta), r_spine_out*Cos(theta), thickness_in};
Point(6) = {-r_spine_out*Sin(theta), r_spine_out*Cos(theta), beam_height-thickness_in};
Point(7) = {-r_out*Sin(theta), r_out*Cos(theta), beam_height-thickness_out};
Point(8) = {-r_out*Sin(theta), r_out*Cos(theta), beam_height};
Point(9) = {-r_in*Sin(theta), r_in*Cos(theta), beam_height};

// posts
pw2 = post_width/2;
Point(11) = {-pw2, -pw2, 0};
Point(12) = {-pw2, pw2, 0};
Point(13) = {pw2, pw2, 0};
Point(14) = {pw2, -pw2, 0};
pw2i = pw2 - post_thickness;
Point(15) = {-pw2i, -pw2i, 0};
Point(16) = {-pw2i, pw2i, 0};
Point(17) = {pw2i, pw2i, 0};
Point(18) = {pw2i, -pw2i, 0};

// gussets
gw2 = gusset_width/2;
Point(31) = {-gw2, -gw2, 0};
Point(32) = {-gw2, gw2, 0};
Point(33) = {gw2, gw2, 0};
Point(34) = {gw2, -gw2, 0};
gw2i = gw2 - post_thickness;
Point(35) = {-gw2i, -gw2i, 0};
Point(36) = {-gw2i, gw2i, 0};
Point(37) = {gw2i, gw2i, 0};
Point(38) = {gw2i, -gw2i, 0};

/////////// curves //////////////

// beam cross section
Line(1) = {2, 3};
Line(2) = {3, 4};
Line(3) = {4, 5};
Line(4) = {5, 6};
Line(5) = {6, 7};
Line(6) = {7, 8};
Line(7) = {8, 9};
Line(8) = {9, 2};

// posts
Line(11) = {11, 12};
Line(12) = {12, 13};
Line(13) = {13, 14};
Line(14) = {14, 11};
Line(15) = {15, 16};
Line(16) = {16, 17};
Line(17) = {17, 18};
Line(18) = {18, 15};

// gussets
Line(31) = {31, 32};
Line(32) = {32, 33};
Line(33) = {33, 34};
Line(34) = {34, 31};
Line(35) = {35, 36};
Line(36) = {36, 37};
Line(37) = {37, 38};
Line(38) = {38, 35};

/////////// curves loops //////////////

// beam
Curve Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};

// posts
Curve Loop(2) = {11, 12, 13, 14};
Curve Loop(3) = {15, 16, 17, 18};

// gussets
Curve Loop(5) = {31, 32, 33, 34};
Curve Loop(6) = {35, 36, 37, 38};

/////////// surfaces //////////////

// beam
Plane Surface(1) = {1};

// posts
Plane Surface(2) = {2, 3};
Plane Surface(22) = {2, 3};

// post cap
Plane Surface(3) = {2};
Plane Surface(33) = {2};

// gussets
Plane Surface(5) = {5, 6};
Plane Surface(6) = {5, 6};
Plane Surface(7) = {5, 6};
Plane Surface(8) = {5, 6};
Plane Surface(9) = {5, 6};
Plane Surface(10) = {5, 6};

/////////// volumes //////////////

// beam
beam_surfaces[] = Extrude{{0, 0, 1}, {0, 0, 0}, 2*Pi} {Surface{1};};

// posts
r_mid = (r_in+r_out)/2;
vert_overlap_tol = 0.05 * inches;

post1[] = Extrude{0, 0, -post_height} {Surface{2}; };
postcap[] = Extrude{0, 0, -post_thickness} {Surface{3}; };
postfull[] = BooleanUnion {Volume{postcap[1]}; Delete;}{Volume{post1[1]}; Delete;};
Rotate{{0, 0, 1}, {0, 0, 0}, theta} {
    Translate{0, r_mid, vert_overlap_tol} {
        Duplicata{
            Volume{postfull[0]}; 
        }
    }
}
Rotate{{0, 0, 1}, {0, 0, 0}, -theta} {
    Translate{0, r_mid, vert_overlap_tol} { Volume{postfull[0]}; }
}

post2[] = Extrude{0, 0, -post_height} {Surface{22}; };
postcap2[] = Extrude{0, 0, -post_thickness} {Surface{33}; };
postfull2[] = BooleanUnion {Volume{postcap2[1]}; Delete;}{Volume{post2[1]}; Delete;};
Rotate{{0, 0, 1}, {0, 0, 0}, 0*theta} {
    Translate{0, r_mid, vert_overlap_tol} {
        Duplicata{
            Volume{postfull2[0]}; 
        }
    }
}
Rotate{{0, 0, 1}, {0, 0, 0}, 0*theta} {
    Translate{0, r_mid, vert_overlap_tol} { Volume{postfull2[0]}; }
}

// gussets
gusset_length = Sqrt(2)*gusset_offset;
tmp_gusset_length = gusset_length + 0.0*(gusset_width);
gusset00[] = Extrude{0, 0, -tmp_gusset_length} {Surface{9}; };
gusset_rot = gusset_offset / r_mid; // scoot gusset along beam 
Rotate{{0,0,1},{0,0,0}, gusset_rot}{
    Translate{0,r_mid,0.5*gusset_width}{
        Rotate{{1,0,0},{0,0,0}, -gusset_rot/2}{
            Rotate{{0,1,0}, {0,0,0}, -Pi/4} {Volume{gusset00[1]};}
        }
    }
}
gusset0[] = Extrude{0, 0, -tmp_gusset_length} {Surface{10}; };
gusset_rot = gusset_offset / r_mid; // scoot gusset along beam 
Rotate{{0,0,1},{0,0,0}, -gusset_rot}{
    Translate{0,r_mid,0.5*gusset_width}{
        Rotate{{1,0,0},{0,0,0}, -gusset_rot/2}{
            Rotate{{0,1,0}, {0,0,0}, Pi/4} {Volume{gusset0[1]};}
        }
    }
}

gusset_length = Sqrt(2)*gusset_offset;
tmp_gusset_length = gusset_length + 0.0*(gusset_width);
gusset1[] = Extrude{0, 0, -tmp_gusset_length} {Surface{5}; };
gusset_rot = gusset_offset / r_mid; // scoot gusset along beam 
Rotate{{0,0,1},{0,0,0}, theta + gusset_rot}{
    Translate{0,r_mid,0.5*gusset_width}{
        Rotate{{1,0,0},{0,0,0}, -gusset_rot/2}{
            Rotate{{0,1,0}, {0,0,0}, -Pi/4} {Volume{gusset1[1]};}
        }
    }
}
gusset3[] = Extrude{0, 0, -tmp_gusset_length} {Surface{6}; };
gusset_rot = gusset_offset / r_mid; // scoot gusset along beam 
Rotate{{0,0,1},{0,0,0}, theta - gusset_rot}{
    Translate{0,r_mid,0.5*gusset_width}{
        Rotate{{1,0,0},{0,0,0}, -gusset_rot/2}{
            Rotate{{0,1,0}, {0,0,0}, Pi/4} {Volume{gusset3[1]};}
        }
    }
}

gusset2[] = Extrude{0, 0, -tmp_gusset_length} {Surface{7}; };
gusset_rot = -gusset_offset / r_mid; // scoot gusset along beam 
Rotate{{0,0,1},{0,0,0}, -theta + gusset_rot}{
    Translate{0,r_mid,0.5*gusset_width}{
        Rotate{{1,0,0},{0,0,0}, gusset_rot/2}{
            Rotate{{0,1,0}, {0,0,0}, Pi/4} {Volume{gusset2[1]};}
        }
    }
}
gusset4[] = Extrude{0, 0, -tmp_gusset_length} {Surface{8}; };
gusset_rot = -gusset_offset / r_mid; // scoot gusset along beam 
Rotate{{0,0,1},{0,0,0}, -theta - gusset_rot}{
    Translate{0,r_mid,0.5*gusset_width}{
        Rotate{{1,0,0},{0,0,0}, gusset_rot/2}{
            Rotate{{0,1,0}, {0,0,0}, -Pi/4} {Volume{gusset4[1]};}
        }
    }
}

////////// physical volumes/surfaces ////////////

wholemesh[] = BooleanUnion {Volume{1}; Delete;}{Volume{2}; Delete;};
wholemesh2[] = BooleanUnion {Volume{wholemesh[0]}; Delete;}{Volume{3}; Delete;};
wholemesh3[] = BooleanUnion {Volume{wholemesh2[0]}; Delete;}{Volume{4}; Delete;};
wholemesh4[] = BooleanUnion {Volume{wholemesh3[0]}; Delete;}{Volume{5}; Delete;};
wholemesh5[] = BooleanUnion {Volume{wholemesh4[0]}; Delete;}{Volume{6}; Delete;};
wholemesh6[] = BooleanUnion {Volume{wholemesh5[0]}; Delete;}{Volume{7}; Delete;};
wholemesh7[] = BooleanUnion {Volume{wholemesh6[0]}; Delete;}{Volume{8}; Delete;};
wholemesh8[] = BooleanUnion {Volume{wholemesh7[0]}; Delete;}{Volume{9}; Delete;};
wholemesh9[] = BooleanUnion {Volume{wholemesh7[0]}; Delete;}{Volume{10}; Delete;};
wholemesh10[] = BooleanUnion {Volume{wholemesh7[0]}; Delete;}{Volume{11}; Delete;};
wholemesh11[] = BooleanUnion {Volume{wholemesh7[0]}; Delete;}{Volume{12}; Delete;};
Physical Volume(5) = {1}; // whole mesh

Physical Surface(1) = {42}; // post1 bottom
Physical Surface(2) = {33}; // post1 bottom
Physical Surface(3) = {26}; // post2 bottom
Physical Surface(4) = {40}; // beam top

///////////// meshing params //////////////////
// disable point and curvature based mesh sizing
Mesh.MeshSizeFromPoints = 0;
Mesh.MeshSizeFromCurvature = 0;
Mesh.MeshSizeExtendFromBoundary = 0;

// Create a box field that just uses 1 inch element sizing inside and outside it (i.e. everywhere)
Field[1] = Box;
Field[1].VIn = .3 * inches;
Field[1].VOut = .3 * inches;

// use that field for the base mesh element sizing
Background Field = 1;

