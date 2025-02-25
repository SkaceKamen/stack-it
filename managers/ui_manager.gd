extends CanvasLayer
class_name UIManager

signal restart_requested
signal start_requested
signal mode_changed(mode: GameMode)

@export var score_label: Label
@export var animation_player: AnimationPlayer
@export var ingame: Control
@export var menu_screen: MenuScreen
@export var game_end_screen: GameEndScreen
@export var shop_screen: ShopScreen
@export var new_game_screen: NewGameScreen

var screens: Array[Control] = []

func _ready():
  screens = [ingame, menu_screen, game_end_screen, shop_screen, new_game_screen]

  for screen in screens:
    if screen != menu_screen:
      screen.visible = false

  menu_screen.visible = true

  score_label.text = "0"

  game_end_screen.restart_requested.connect(_on_restart_requested)
  game_end_screen.menu_requested.connect(_on_menu_requested)
  menu_screen.start_requested.connect(_on_new_game_requested)
  menu_screen.shop_requested.connect(_on_shop_requested)
  shop_screen.menu_requested.connect(_on_menu_requested)
  new_game_screen.game_mode_changed.connect(func(mode: GameMode): mode_changed.emit(mode))
  new_game_screen.game_start_requested.connect(_on_start_requested)
  new_game_screen.back_requested.connect(_on_menu_requested)

func switch_to_screen(target: Control):
  for screen in screens:
    if screen.visible and screen != target:
      var tween = get_tree().create_tween()
      tween.tween_property(screen, "modulate:a", 0, 0.2)
      tween.finished.connect(func(): screen.visible = false)
  
  var target_tween = get_tree().create_tween()
  target_tween.tween_property(target, "modulate:a", 1, 0.2)
  target.visible = true

func _on_shop_requested():
  switch_to_screen(shop_screen)

func _on_restart_requested():
  restart_requested.emit()
  switch_to_screen(ingame)

func _on_menu_requested():
  switch_to_screen(menu_screen)

func _on_start_requested():
  start_requested.emit()
  switch_to_screen(ingame)

func _on_new_game_requested():
  # For the first time we just start the standard game mode to not confuse the player
  if DataStore.user_data.scores.size() == 0:
    _on_start_requested()
    return

  switch_to_screen(new_game_screen)

func show_game_over(final_score: int, is_high_score: bool):
  switch_to_screen(game_end_screen)
  game_end_screen.display(final_score, is_high_score)

func update_score(score: int, highlight: bool):
  score_label.text = str(score)
  animation_player.stop()
  animation_player.play("ScorePerfect" if highlight else "Score")
