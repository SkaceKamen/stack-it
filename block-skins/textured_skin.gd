extends BlockSkin
class_name TexturedSkin

@export var uv_scale = 1.0
@export var mesh: MeshInstance3D

func set_state(height: float, _count: int, size: Vector3, offset: Vector3):
  mesh.mesh.material.uv1_offset = Vector3(- offset.x, height, - offset.y) * uv_scale
  mesh.mesh.material.uv1_scale = size * uv_scale
