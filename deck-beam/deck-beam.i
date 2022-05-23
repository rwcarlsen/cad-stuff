[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [generated]
    type = FileMeshGenerator
    file = 'deck-beam.msh'
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    add_variables = true
    generate_output = 'vonmises_stress'
  []
[]

#
# Added boundary/loading conditions
# https://mooseframework.inl.gov/modules/tensor_mechanics/tutorials/introduction/step02.html
#
[BCs]
  [post1_bottom_x]
    type = DirichletBC
    variable = disp_x
    boundary = 1
    value = 0
  []
  [post1_bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = 1
    value = 0
  []
  [post1_bottom_z]
    type = DirichletBC
    variable = disp_z
    boundary = 1
    value = 0
  []
  [post2_bottom_x]
    type = DirichletBC
    variable = disp_x
    boundary = 2
    value = 0
  []
  [post2_bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = 2
    value = 0
  []
  [post2_bottom_z]
    type = DirichletBC
    variable = disp_z
    boundary = 2
    value = 0
  []
  [Pressure]
    [beam_top]
      boundary = 3
      function = 70000
    []
  []
[]

[Materials]
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 2e11
    poissons_ratio = 0.3
  []
  [stress]
    type = ComputeLinearElasticStress
  []
[]

# consider all off-diagonal Jacobians for preconditioning
[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  # we chose a direct solver here
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  dt = .001
  num_steps = 1
  automatic_scaling = true
[]

[Outputs]
  exodus = true
[]
