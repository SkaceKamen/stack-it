extends Node3D
class_name GameManager

enum State {Playing, Menu}

@export var game_data: GameData
@export var block_prefab: PackedScene
@export var default_skin_prefab: PackedScene
@export var blocks_container: Node3D
@export var ui_manager: UIManager
@export var camera: Camera3D
@export var background_layer: BackgroundLayer

var height = 0
var count = 0
var blocks: Array[FallingBlock] = []

var last_block: FallingBlock
var current_block: FallingBlock

var score = 0

var base_camera_position: Vector3

var current_state = State.Menu

func _ready():
  base_camera_position = camera.position * 1

  ui_manager.restart_requested.connect(reset)
  ui_manager.start_requested.connect(reset)

  spawn_initial_block()
  
func _process(delta: float) -> void:
  camera.position = Vector3(camera.position.x, lerp(camera.position.y, base_camera_position.y + height, 10 * delta), camera.position.z)
  if current_state == State.Playing and current_block != null:
    if Input.is_action_just_pressed("ui_select"):
      current_block.stop()

func _input(event: InputEvent) -> void:
  if current_state != State.Playing:
    return

  if event is InputEventScreenTouch and event.pressed:
    current_block.stop()

func reset() -> void:
  blocks.clear()

  count = 0
  score = 0
  height = 0
  last_block = null
  current_block = null

  for i in range(blocks_container.get_child_count()):
    blocks_container.get_child(i).queue_free()

  spawn_initial_block()
  spawn_block()

  current_state = State.Playing

func get_current_skin() -> PackedScene:
  if DataStore.user_data.current_skin != '':
    for skin in game_data.skins:
      if skin.id == DataStore.user_data.current_skin:
        return load(skin.prefab_path)
  
  return default_skin_prefab

func spawn_initial_block() -> void:
  var block = block_prefab.instantiate() as FallingBlock
  blocks_container.add_child(block)

  block.position = Vector3(0, -block.height, 0)
  block.set_skin(get_current_skin(), height, count)

  current_block = block
  last_block = block

  blocks.append(block)

func get_movement_speed() -> float:
  return 1.5 + round(count / 10.0) / 10.0

func spawn_block() -> void:
  var new_axis = 1 if last_block.move_axis == 0 else 0

  var block = block_prefab.instantiate() as FallingBlock
  blocks_container.add_child(block)

  block.position = Vector3(last_block.position.x, height, -1) if new_axis == 0 else Vector3(-1, height, last_block.position.z)
  block.block_stopped.connect(block_stopped)
  block.move_axis = new_axis
  block.moving = true
  block.size = Vector2(last_block.size.x, last_block.size.y)
  block.scale = Vector3(last_block.scale.x, last_block.scale.y, last_block.scale.z)
  block.move_speed = get_movement_speed()
  block.set_skin(get_current_skin(), height, count)

  current_block = block

  blocks.append(block)

  if blocks.size() > 15:
    blocks.pop_front().queue_free()

func block_stopped(block: FallingBlock) -> void:
  var cut_result = block.cut_according_to(last_block, height, count)

  if cut_result == FallingBlock.CutResult.Missed:
    game_over()
    return

  last_block = block
  height += block.height
  score += 2 if cut_result == FallingBlock.CutResult.Perfect else 1
  count += 1

  background_layer.set_target(count / 30.0)
  ui_manager.update_score(score, cut_result == FallingBlock.CutResult.Perfect)

  spawn_block()

func game_over() -> void:
  var user_data = DataStore.user_data

  user_data.scores.append(
    DataStore.UserDataScore.new(
      score,
      Time.get_datetime_string_from_system()
    )
  )

  var is_new_high_score = false

  if user_data.high_score == null || score > user_data.high_score:
    user_data.high_score = score
    is_new_high_score = true

  ui_manager.show_game_over(score, is_new_high_score)

  current_state = State.Menu

  DataStore.user_data = user_data
