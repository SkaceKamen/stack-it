extends BlockSkin

@export() var resetHeight = 5.0
@export() var gradient: Gradient
@export() var mesh: MeshInstance3D

func set_state(height: float, _count: int):
  var delta = (height / resetHeight)
  
  while delta > 1:
    delta -= 1

  var color = gradient.sample(delta)
  mesh.mesh.material.albedo_color = color
