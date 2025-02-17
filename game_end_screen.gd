extends Control
class_name GameEndScreen

signal restart_requested
signal menu_requested

@export() var animation_player: AnimationPlayer
@export() var restart_button: Button
@export() var menu_button: Button
@export() var normal_score_label: Label
@export() var high_score_label: Label
@export() var score_value_label: Label

func _ready():
  restart_button.connect("pressed", func(): restart_requested.emit())
  menu_button.connect("pressed", func(): menu_requested.emit())

func display(score: int, is_new_high_score: bool):
  if is_new_high_score:
    normal_score_label.visible = false
    high_score_label.visible = true
  else:
    normal_score_label.visible = true
    high_score_label.visible = false

  score_value_label.text = str(score)

  animation_player.stop()
  animation_player.play("Show")
  visible = true
