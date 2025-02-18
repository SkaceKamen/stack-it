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
    var user_data = DataStore.user_data

    for child in skin_items_container.get_children():
        child.queue_free()

    for skin_data in game_data.skins:
        var skin_item = skin_item_prefab.instantiate() as SkinShopItem
        skin_item.set_data(skin_data, user_data.owned_skins.has(skin_data.id), user_data.current_skin == skin_data.id)
        skin_items_container.add_child(skin_item)
        skin_item.skin_pressed.connect(buy_skin)

func buy_skin(skin_data: SkinData):
    var user_data = DataStore.user_data

    if user_data.owned_skins.has(skin_data.id):
        user_data.current_skin = skin_data.id

        refresh_items()

        return

    if user_data.money >= skin_data.cost:
        user_data.money -= skin_data.cost
        user_data.owned_skins.append(skin_data.id)
        user_data.current_skin = skin_data.id

        DataStore.save_user_data()

        refresh_items()
