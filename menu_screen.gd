extends Control
class_name MenuScreen

signal start_requested

@export var start_button: Button
@export var high_score_label: Label

func _ready():
  start_button.pressed.connect(func(): start_requested.emit())
  visibility_changed.connect(_on_visibility_changed)

  _on_visibility_changed()

func _on_visibility_changed():
  if is_visible_in_tree():
    var data = DataStore.load_data()
    high_score_label.text = str(data.high_score)

func _update_data():
  var high_score = DataStore.load_data().high_score

  if high_score:
    high_score_label.text = str(high_score)
