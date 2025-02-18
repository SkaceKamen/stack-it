extends Control
class_name SkinShopItem

@export var name_label: Label
@export var cost_label: Label
@export var icon_texture: TextureRect

func set_data(data: SkinData):
    icon_texture.texture = data.icon
    name_label.text = data.name
    cost_label.text = str(data.cost)
