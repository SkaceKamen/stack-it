extends Control
class_name MenuScreen

signal start_requested
signal shop_requested

@export var start_button: Button
@export var high_score_label: Label
@export var shop_button: Button

func _ready():
  start_button.pressed.connect(func(): start_requested.emit())
  shop_button.pressed.connect(func(): shop_requested.emit())
  visibility_changed.connect(_on_visibility_changed)

  _on_visibility_changed()

  start_button.grab_focus()

func _on_visibility_changed():
  if is_visible_in_tree():
    var data = DataStore.user_data

    if data.high_score != null:
      high_score_label.text = str(data.high_score)

func _update_data():
  var high_score = DataStore.user_data.high_score

  if high_score != null:
    high_score_label.text = str(high_score)
