extends BlockSkin
class_name TexturedSkin

@export var uv_scale = 1.0
@export var mesh: MeshInstance3D

func set_size(size: Vector3):
  mesh.mesh.material.uv1_scale = size * uv_scale

func set_state(height: float, _count: int):
  mesh.mesh.material.uv1_offset = Vector3(0, height * uv_scale, 0)
