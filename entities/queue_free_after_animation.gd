extends Node
class_name QueueFreeAfterAnimation

@export var animation_player: AnimationPlayer

func _ready():
  animation_player.animation_finished.connect(func(_anim: String): get_parent().queue_free())
