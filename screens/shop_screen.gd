extends Control
class_name ShopScreen

signal menu_requested

@export var game_data: GameData
@export var money_label: Label
@export var skin_items_container: Container
@export var skin_item_prefab: PackedScene
@export var back_button: Button
@export var purchase_confirm_container: Control
@export var purchase_confirm: Button
@export var purchase_cancel: Button
@export var purchase_confirm_label: Label

var current_purchase: SkinData

func _ready():
    refresh()

    back_button.pressed.connect(func(): menu_requested.emit())
    visibility_changed.connect(func(): refresh())

    purchase_confirm.pressed.connect(confirm_purchase)
    purchase_cancel.pressed.connect(func(): purchase_confirm_container.hide())

func refresh():
    var user_data = DataStore.user_data

    money_label.text = str(user_data.money)

    for child in skin_items_container.get_children():
        child.queue_free()

    for skin_data in game_data.skins:
        var skin_item = skin_item_prefab.instantiate() as SkinShopItem

        var is_selected = user_data.current_skin == skin_data.id
        var is_owned = user_data.owned_skins.has(skin_data.id)
        var is_affordable = user_data.money >= skin_data.cost

        skin_item.set_data(skin_data, is_owned, is_selected, is_affordable)
        skin_items_container.add_child(skin_item)
        skin_item.skin_pressed.connect(buy_skin)

func buy_skin(skin_data: SkinData):
    var user_data = DataStore.user_data

    if user_data.owned_skins.has(skin_data.id):
        user_data.current_skin = skin_data.id

        refresh()

        return

    if user_data.money >= skin_data.cost:
        purchase_confirm_label.text = "Do you want to buy " + skin_data.name + " skin for " + str(skin_data.cost) + " coins?"
        purchase_confirm_container.show()
        current_purchase = skin_data

func confirm_purchase():
    if not current_purchase:
        return

    var user_data = DataStore.user_data

    user_data.money -= current_purchase.cost
    user_data.owned_skins.append(current_purchase.id)
    user_data.current_skin = current_purchase.id

    DataStore.save_user_data()

    refresh()

    purchase_confirm_container.hide()