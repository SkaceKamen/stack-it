extends RigidBody3D
class_name BlockCutoff

@export var collision_shape: CollisionShape3D

var skin: PackedScene = null
var skin_instance: BlockSkin = null

func _process(_delta: float) -> void:
  if position.y < -10:
    queue_free()

func set_skin(skin_prefab: PackedScene, stack_height: float, stack_count: int, size: Vector3, offset: Vector3) -> void:
  skin = skin_prefab
  skin_instance = skin.instantiate() as BlockSkin
  add_child(skin_instance)

  collision_shape.scale = Vector3(size.x, 1, size.z)
  skin_instance.scale = Vector3(size.x, 1, size.z)
  skin_instance.set_state(stack_height, stack_count, size, offset)
