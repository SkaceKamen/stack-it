extends RigidBody3D
class_name BlockCutoff

@export() var mesh: MeshInstance3D
@export() var collision_shape: CollisionShape3D

func _process(_delta: float) -> void:
  if position.y < -10:
    queue_free()

func set_size(size: Vector2) -> void:
  mesh.scale = Vector3(size.x, 1, size.y)
  collision_shape.scale = Vector3(size.x, 1, size.y)
