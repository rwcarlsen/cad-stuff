SetFactory("OpenCASCADE");


// beam geometry
radius = 3.352; // 11 ft
length = 5.334; // 17.5 ft

// beam parameters
lower_flange = .0508; // 2 inches
beam_height = .1778; // 7 inches
thickness_out = 0.005334; // thickness of the leg at its outer edge
thickness_in = 0.005334; // thickness of the leg at the spine

// post parameters
post_height = 2.4384; // 8 ft.
post_width = .1016; // 4 in.
post_thickness = .009525;
post_theta_ratio = 1/4;

// computed params
r_in = radius;
r_out = r_in + lower_flange;
theta = Asin(length/2/r_in) * 2;
theta2 = theta/2;

/////////// points //////////////

Point(1) = {0,0,0, 1};

// beam bottom r_inner
Point(2) = {-r_in*Sin(theta2), r_in*Cos(theta2), 0, 1};
// beam bottom r_outer
Point(3) = {-r_out*Sin(theta2), r_out*Cos(theta2), 0, 1};
// bottom leg top surface outer
Point(4) = {-r_out*Sin(theta2), r_out*Cos(theta2), thickness_out, 1};
// bottom leg top surface inner
r_spine_out = r_in + thickness_in; // radius at outer surface of spine
Point(5) = {-r_spine_out*Sin(theta2), r_spine_out*Cos(theta2), thickness_in, 1};
// top leg bottom surface inner
Point(6) = {-r_spine_out*Sin(theta2), r_spine_out*Cos(theta2), beam_height-thickness_in, 1};
// top leg bottom surface outer
Point(7) = {-r_out*Sin(theta2), r_out*Cos(theta2), beam_height-thickness_out, 1};
// beam top r_outer
Point(8) = {-r_out*Sin(theta2), r_out*Cos(theta2), beam_height, 1};
// beam top r_inner
Point(9) = {-r_in*Sin(theta2), r_in*Cos(theta2), beam_height, 1};

// posts
pw2 = post_width/2;
Point(11) = {-pw2, -pw2, 0, 1};
Point(12) = {-pw2, pw2, 0, 1};
Point(13) = {pw2, pw2, 0, 1};
Point(14) = {pw2, -pw2, 0, 1};
pw2i = pw2 - post_thickness;
Point(15) = {-pw2i, -pw2i, 0, 1};
Point(16) = {-pw2i, pw2i, 0, 1};
Point(17) = {pw2i, pw2i, 0, 1};
Point(18) = {pw2i, -pw2i, 0, 1};

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

/////////// curves loops //////////////

// beam
Curve Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};

// posts
Curve Loop(2) = {11, 12, 13, 14};
Curve Loop(3) = {15, 16, 17, 18};

/////////// surfaces //////////////

// beam
Plane Surface(1) = {1};

// posts
Plane Surface(2) = {2, 3};

// post cap
Plane Surface(3) = {2};

/////////// volumes //////////////

// beam
Extrude{{0, 0, 1}, {0, 0, 0}, -theta} {Surface{1};}

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

wholemesh[] = BooleanUnion {Volume{1}; Delete;}{Volume{2}; Delete;};
wholemesh2[] = BooleanUnion {Volume{wholemesh[0]}; Delete;}{Volume{3}; Delete;};

Physical Surface(1) = {15}; // post1 bottom
Physical Surface(2) = {33}; // post2 bottom
Physical Surface(3) = {10}; // beam top
Physical Volume(3) = {1}; // whole mesh

//Mesh.CharacteristicLengthFromCurvature = 1;
//Mesh.MinimumElementsPerTwoPi = 50;
Mesh.MeshSizeFromPoints = 0;
Mesh.MeshSizeFromCurvature = 0;
Mesh.MeshSizeExtendFromBoundary = 0;

Field[1] = Box;
Field[1].VIn = .025;
Field[1].VOut = .025;

Background Field = 1;

