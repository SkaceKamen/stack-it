extends BlockSkin

@export var resetHeight = 5.0
@export var gradient: Gradient
@export var mesh: MeshInstance3D
@export var loop = true

func set_state(height: float, _count: int):
  var delta = (height / resetHeight)
  
  if loop:
    while delta > 2:
      delta -= 2
    
    if delta > 1:
      delta = 2 - delta
  else:
    while delta > 1:
      delta -= 1

  var color = gradient.sample(delta)
  mesh.mesh.material.albedo_color = color
