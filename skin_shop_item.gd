extends Button
class_name SkinShopItem

signal skin_pressed(skin_data: SkinData)

@export var name_label: Label
@export var cost_label: Label
@export var icon_texture: TextureRect
@export var selected_style: StyleBox

var skin_data: SkinData

func _ready():
    pressed.connect(func(): skin_pressed.emit(skin_data))

func set_data(data: SkinData, owned: bool, _selected: bool):
    skin_data = data
    icon_texture.texture = data.icon
    name_label.text = data.name
    cost_label.text = str(data.cost) if !owned else "Owned"

    if _selected:
        add_theme_stylebox_override("normal", selected_style)
        add_theme_stylebox_override("hover", selected_style)
    else:
        remove_theme_stylebox_override("normal")
        remove_theme_stylebox_override("hover")
