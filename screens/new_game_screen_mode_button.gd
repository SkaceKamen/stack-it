extends Button
class_name NewGameScreenModeButton

signal mode_picked(mode: GameMode)

@export var selected_style: StyleBox

var mode: GameMode

func _ready() -> void:
  pressed.connect(func(): mode_picked.emit(mode))

func set_mode(new_mode: GameMode) -> void:
  mode = new_mode
  text = mode.name

func set_selected(selected: bool) -> void:
  if selected:
    add_theme_stylebox_override("normal", selected_style)
    add_theme_stylebox_override("hover", selected_style)
    add_theme_stylebox_override("pressed", selected_style)
  else:
    remove_theme_stylebox_override("normal")
    remove_theme_stylebox_override("hover")
    remove_theme_stylebox_override("pressed")
