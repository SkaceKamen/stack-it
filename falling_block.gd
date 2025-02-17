extends Node3D
class_name FallingBlock

enum CutResult {Perfect, Missed, Partial}

signal block_stopped(block: FallingBlock)

@export() var height = 0.2
@export() var block_cutoff_prefab: PackedScene
@export() var perfect_effect_prefab: PackedScene

var moving = false
var move_sign = 1
var move_speed = 2
var move_axis = 0
var size = Vector2(1, 1)

func get_move_direction() -> Vector3:
  return Vector3(0, 0, move_sign) if move_axis == 0 else Vector3(move_sign, 0, 0)

func _process(delta):
  if moving:
    var move_direction = get_move_direction()
    position += move_direction * move_speed * delta

    if (move_axis == 0 and abs(position.z) > 1) or (move_axis == 1 and abs(position.x) > 1):

      move_sign *= -1

func cut_according_to(block: FallingBlock) -> CutResult:
  var my_position = position.z if move_axis == 0 else position.x
  var other_position = block.position.z if move_axis == 0 else block.position.x

  var my_sign = -1 if my_position - other_position < 0 else 1

  var my_size = size.y if move_axis == 0 else size.x
  var my_point = my_position + my_sign * my_size / 2

  var other_size = block.size.y if move_axis == 0 else block.size.x
  var other_point = other_position + my_sign * other_size / 2

  var diff = my_point - other_point

  print("myPosition: " + str(my_position))
  print("mySize: " + str(my_size))
  print("otherPosition: " + str(other_position))
  print("otherSize: " + str(other_size))
  print("myPoint: " + str(my_point))
  print("otherPoint: " + str(other_point))
  print("diff: " + str(diff) + "\n")

  if abs(diff) < 0.02:
    position = Vector3(block.position.x, position.y, block.position.z)
    size = block.size

    var effect = perfect_effect_prefab.instantiate()
    get_parent().add_child(effect)

    effect.scale = Vector3(size.x, 1, size.y)
    effect.position = Vector3(position.x, position.y - height / 2, position.z)

    return CutResult.Perfect

  var cutoff = block_cutoff_prefab.instantiate()
  get_parent().add_child(cutoff)

  if my_size - abs(diff) <= 0:
    cutoff.set_size(size)
    cutoff.position = Vector3(position.x, position.y, position.z)

    queue_free()

    return CutResult.Missed

  var previous_size = size * 1

  if move_axis == 0:
    size.y -= abs(diff)
    scale = Vector3(scale.x, scale.y, size.y)
    position = Vector3(position.x, position.y, position.z - diff / 2)

    cutoff.set_size(Vector2(size.x, abs(diff)))
    cutoff.position = Vector3(position.x, position.y, position.z + my_sign * (previous_size.y / 2))
  else:
    size.x -= abs(diff)
    scale = Vector3(size.x, scale.y, scale.z)
    position = Vector3(position.x - diff / 2, position.y, position.z)

    cutoff.set_size(Vector2(abs(diff), size.y))
    cutoff.position = Vector3(position.x + my_sign * (previous_size.x / 2), position.y, position.z)

  return CutResult.Partial;
  

func stop():
  if !moving:
    return

  moving = false

  block_stopped.emit(self)
