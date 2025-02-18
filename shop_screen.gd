extends Control
class_name ShopScreen

signal menu_requested

@export var game_data: GameData
@export var skin_items_container: Container
@export var skin_item_prefab: PackedScene
@export var back_button: Button

func _ready():
    refresh_items()

    back_button.pressed.connect(func(): menu_requested.emit())

func refresh_items():
     # Remove all children from the container
    for child in skin_items_container.get_children():
        child.queue_free()

    # Add skins
    for skin_data in game_data.skins:
        var skin_item = skin_item_prefab.instantiate()
        skin_item.set_data(skin_data)
        skin_items_container.add_child(skin_item)
