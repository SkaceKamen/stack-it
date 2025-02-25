extends Control
class_name NewGameScreen

signal game_start_requested
signal back_requested
signal game_mode_changed(mode: GameMode)

@export var game_data: GameData
@export var current_mode: GameMode

@export var modes_container: GridContainer
@export var start_button: Button
@export var back_button: Button
@export var info_label: Label

@export var mode_button_prefab: PackedScene

@export var animation_player: AnimationPlayer

var buttons: Array[NewGameScreenModeButton] = []

func _ready() -> void:
  animation_player.animation_finished.connect(func (anim_name: String):
    if anim_name == "Hide":
      visible = false
  )
  
  start_button.pressed.connect(func(): game_start_requested.emit())
  back_button.pressed.connect(func(): back_requested.emit())
  
  if current_mode == null:
    current_mode = game_data.modes[0]

  # Clear container
  for child in modes_container.get_children():
    child.queue_free()

  for mode in game_data.modes:
    var button = mode_button_prefab.instantiate() as NewGameScreenModeButton
    button.set_mode(mode)
    button.mode_picked.connect(_on_mode_picked)
    modes_container.add_child(button)

    if mode == current_mode:
      button.set_selected(true)

    buttons.push_back(button)

func _on_mode_picked(mode: GameMode) -> void:
  current_mode = mode
  info_label.text = mode.description
  
  for button in buttons:
    button.set_selected(button.mode == mode)

  game_mode_changed.emit(mode)


func show_animated():
  if visible:
    return
  
  animation_player.stop()
  animation_player.play("Show")
  visible = true
  
func hide_animated():
  if not visible:
    return
  
  animation_player.stop()
  animation_player.play("Hide")
