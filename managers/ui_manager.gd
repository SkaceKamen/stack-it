extends CanvasLayer
class_name UIManager

signal restart_requested
signal start_requested

@export var score_label: Label
@export var animation_player: AnimationPlayer
@export var ingame: Control
@export var menu_screen: MenuScreen
@export var game_end_screen: GameEndScreen
@export var shop_screen: ShopScreen

func _ready():
  ingame.visible = false
  game_end_screen.visible = false
  shop_screen.visible = false
  menu_screen.visible = true

  score_label.text = "0"

  game_end_screen.restart_requested.connect(_on_restart_requested)
  game_end_screen.menu_requested.connect(_on_menu_requested)
  menu_screen.start_requested.connect(_on_start_requested)
  menu_screen.shop_requested.connect(_on_shop_requested)
  shop_screen.menu_requested.connect(_on_menu_requested)

func _on_shop_requested():
  shop_screen.visible = true
  menu_screen.visible = false

func _on_restart_requested():
  restart_requested.emit()
  ingame.visible = true
  game_end_screen.visible = false

func _on_menu_requested():
  ingame.visible = false
  game_end_screen.visible = false
  shop_screen.visible = false
  menu_screen.visible = true

func _on_start_requested():
  start_requested.emit()
  ingame.visible = true
  menu_screen.visible = false

func show_game_over(final_score: int, is_high_score: bool):
  ingame.visible = false
  game_end_screen.display(final_score, is_high_score)

func update_score(score: int, highlight: bool):
  score_label.text = str(score)
  animation_player.stop()
  animation_player.play("ScorePerfect" if highlight else "Score")
