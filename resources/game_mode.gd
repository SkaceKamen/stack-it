extends Resource
class_name GameMode

@export var name: String = ""
@export_multiline var description: String = ""
@export var block_bounces: bool = true
@export var base_speed: float = 1.5
@export var acceleration: float = 0.1
@export var acceleration_blocks: int = 10
@export var score: int = 1
@export var score_perfect_multiplier: int = 2

func get_speed(current_count: int, _current_height: float) -> float:
    return base_speed + acceleration * floor(float(current_count) / acceleration_blocks)
