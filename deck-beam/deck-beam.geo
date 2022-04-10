SetFactory("OpenCASCADE");


inches = 1.0 / 39.3701; // converts inches to m
feet = 12 * inches; // converts feet to m

// beam geometry
radius = 11 * feet; // 11 ft
length = 17.5 * feet; // 17.5 ft

// beam parameters
lower_flange = 2 * inches; // 2 inches
beam_height = 7 * inches; // 7 inches
thickness_out = 0.366 * inches; // thickness of the leg at its outer edge
thickness_in = 0.314 * inches; // spine thickness
stiffener_thickness = 0.375 * inches;

// post parameters
post_height = 8 * feet; // 8 ft.
post_width = 4 * inches; // 4 in.
post_thickness = 0.25 * inches;
post_theta_ratio = 1/4;

// computed params
r_in = radius;
r_out = r_in + lower_flange;
theta = Asin(length/2/r_in) * 2;
theta2 = theta/2;

/////////// points //////////////

Point(1) = {0,0,0, 1};

// beam cross section points:
r_spine_out = r_in + thickness_in; // radius at outer surface of spine
// bottom r_inner
// bottom r_outer
// bottom leg top surface outer
// bottom leg top surface inner
// top leg bottom surface inner
// top leg bottom surface outer
// top r_outer
// top r_inner
Point(2) = {-r_in*Sin(theta2), r_in*Cos(theta2), 0};
Point(3) = {-r_out*Sin(theta2), r_out*Cos(theta2), 0};
Point(4) = {-r_out*Sin(theta2), r_out*Cos(theta2), thickness_out};
Point(5) = {-r_spine_out*Sin(theta2), r_spine_out*Cos(theta2), thickness_in};
Point(6) = {-r_spine_out*Sin(theta2), r_spine_out*Cos(theta2), beam_height-thickness_in};
Point(7) = {-r_out*Sin(theta2), r_out*Cos(theta2), beam_height-thickness_out};
Point(8) = {-r_out*Sin(theta2), r_out*Cos(theta2), beam_height};
Point(9) = {-r_in*Sin(theta2), r_in*Cos(theta2), beam_height};

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

// stiffener
Line(20) = {2, 3};
Line(21) = {3, 8};
Line(22) = {8, 9};
Line(23) = {9, 2};

/////////// curves loops //////////////

// beam
Curve Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};

// posts
Curve Loop(2) = {11, 12, 13, 14};
Curve Loop(3) = {15, 16, 17, 18};

// stifener
Curve Loop(4) = {20, 21, 22, 23};

/////////// surfaces //////////////

// beam
Plane Surface(1) = {1};

// posts
Plane Surface(2) = {2, 3};

// post cap
Plane Surface(3) = {2};

// stiffener
Plane Surface(4) = {4};

/////////// volumes //////////////

// beam
beam_surfaces[] = Extrude{{0, 0, 1}, {0, 0, 0}, -theta} {Surface{1};};

// posts
r_mid = (r_in+r_out)/2;
vert_overlap_tol = 0.01;
ptheta = theta2 - post_theta_ratio*theta;

post1[] = Extrude{0, 0, -post_height} {Surface{2}; };

postcap[] = Extrude{0, 0, -post_thickness} {Surface{3}; };
postfull[] = BooleanUnion {Volume{postcap[1]}; Delete;}{Volume{post1[1]}; Delete;};
Rotate{{0, 0, 1}, {0, 0, 0}, ptheta} {
    Translate{0, r_mid, vert_overlap_tol} {
        Duplicata{
            Volume{postfull[0]}; 
        }
    }
}
Rotate{{0, 0, 1}, {0, 0, 0}, -ptheta} {
    Translate{0, r_mid, vert_overlap_tol} { Volume{postfull[0]}; }
}

// stiffener
extrude_angle = stiffener_thickness / r_mid;
dtheta = ptheta + post_width / 2 / r_mid;
stiffer[] = Extrude{{0, 0, 1}, {0, 0, 0}, -extrude_angle} {Surface{4};};
Rotate{{0, 0, 1}, {0, 0, 0}, -theta2 + dtheta} { Duplicata{Volume{stiffer[1]};} }
Rotate{{0, 0, 1}, {0, 0, 0}, -theta2 - dtheta + extrude_angle} { Volume{stiffer[1]}; }

////////// physical volumes/surfaces ////////////
Physical Surface(1) = {46}; // post1 bottom
Physical Surface(2) = {14}; // post2 bottom
Physical Surface(3) = {beam_surfaces[6]}; // beam top

wholemesh[] = BooleanUnion {Volume{1}; Delete;}{Volume{2}; Delete;};
wholemesh2[] = BooleanUnion {Volume{wholemesh[0]}; Delete;}{Volume{3}; Delete;};
wholemesh3[] = BooleanUnion {Volume{wholemesh2[0]}; Delete;}{Volume{4}; Delete;};
wholemesh4[] = BooleanUnion {Volume{wholemesh3[0]}; Delete;}{Volume{5}; Delete;};
Physical Volume(4) = {1}; // whole mesh

///////////// meshing params //////////////////
Mesh.MeshSizeFromPoints = 0;
Mesh.MeshSizeFromCurvature = 0;
Mesh.MeshSizeExtendFromBoundary = 0;

Field[1] = Box;
Field[1].VIn = .025;
Field[1].VOut = .025;

Background Field = 1;

