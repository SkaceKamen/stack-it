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

# Prefabs to be preloaded when the game starts
@export var preload_prefabs: Array[PackedScene]

var height = 0
var count = 0
var blocks: Array[FallingBlock] = []

var last_block: FallingBlock
var current_block: FallingBlock

var score = 0

var base_camera_position: Vector3
var base_camera_size: float

var current_state = State.Menu

func _ready():
  base_camera_position = camera.position * 1
  base_camera_size = camera.size

  ui_manager.restart_requested.connect(reset)
  ui_manager.start_requested.connect(reset)

  spawn_initial_block()

  for preload_prefab in preload_prefabs:
    var instance = preload_prefab.instantiate() as Node3D
    instance.position = Vector3(0, -1000, 0)
    add_child(instance)
    await RenderingServer.frame_post_draw
    instance.queue_free()

  for item in game_data.skins:
    if not item.icon:
      var sub_viewport = SubViewport.new()

      sub_viewport.size = Vector2(128, 128)
      sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
      sub_viewport.transparent_bg = true

      add_child(sub_viewport)

      for i in range(5):
        var skin_instance = item.prefab.instantiate() as BlockSkin
        skin_instance.position = Vector3(0, -100 + i * 0.2, 0)
        skin_instance.set_state(i * 0.2 * 18.75, i * 5)
        sub_viewport.add_child(skin_instance)

      var local_camera = Camera3D.new()

      local_camera.projection = Camera3D.ProjectionType.PROJECTION_ORTHOGONAL
      local_camera.size = 1.6
      local_camera.near = 0.001
      local_camera.far = 5000
      local_camera.position = base_camera_position + Vector3(0, -100, 0)
      local_camera.rotation = camera.rotation

      sub_viewport.add_child(local_camera)

      await RenderingServer.frame_post_draw

      item.icon = ImageTexture.create_from_image(sub_viewport.get_texture().get_image())

      sub_viewport.free()


  # CHEAT:
  #spawn_block()
  #for i in range(30):
  #  current_block.position = Vector3(0, current_block.position.y, 0)
  #  current_block.stop()
  
func _process(delta: float) -> void:
  match current_state:
    State.Playing:
      camera.position = camera.position.lerp(Vector3(base_camera_position.x, base_camera_position.y + height, base_camera_position.z), 10 * delta)
      camera.size = lerp(camera.size, base_camera_size, 10 * delta)

      if current_block != null:
        if Input.is_action_just_pressed("ui_select"):
          current_block.stop()

    State.Menu:
      camera.position = camera.position.lerp(base_camera_position + Vector3(0, height / 2.0, 0) + camera.quaternion * Vector3(0, 0, height / 2.0), 2 * delta)
      camera.size = lerp(camera.size, base_camera_size + height, 2 * delta)

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
        return skin.prefab
  
  return default_skin_prefab

func spawn_initial_block() -> void:
  var block = block_prefab.instantiate() as FallingBlock
  blocks_container.add_child(block)

  block.position = Vector3(0, - block.height, 0)
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

  var money_earned = floor(score / 10.0)
  user_data.money += money_earned

  var is_new_high_score = false

  if user_data.high_score == null || score > user_data.high_score:
    user_data.high_score = score
    is_new_high_score = true


  ui_manager.show_game_over(score, is_new_high_score)

  current_state = State.Menu

  DataStore.save_user_data()
