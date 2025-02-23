extends Button
class_name SkinShopItem

signal skin_pressed(skin_data: SkinData)

@export var name_label: Label
@export var cost_label: Label
@export var icon_texture: TextureRect
@export var selected_style: StyleBox
@export var owned_style: StyleBox
@export var unaffordable_style: StyleBox
@export var affordable_style: StyleBox
@export var affordable_color: Color
@export var unaffordable_color: Color

var skin_data: SkinData

func _ready():
    pressed.connect(func(): skin_pressed.emit(skin_data))

func set_data(data: SkinData, owned: bool, selected: bool, affordable: bool):
    skin_data = data
    icon_texture.texture = data.icon
    name_label.text = data.name
    cost_label.text = str(data.cost) if !owned else ""

    if selected:
        add_theme_stylebox_override("normal", selected_style)
        add_theme_stylebox_override("hover", selected_style)
    elif owned:
        add_theme_stylebox_override("normal", owned_style)
        add_theme_stylebox_override("hover", owned_style)
    elif affordable:
        add_theme_stylebox_override("normal", affordable_style)
        add_theme_stylebox_override("hover", affordable_style)
        cost_label.add_theme_color_override("font_color", affordable_color)
        cost_label.visible = true
    else:
        add_theme_stylebox_override("normal", unaffordable_style)
        add_theme_stylebox_override("hover", unaffordable_style)
        cost_label.add_theme_color_override("font_color", unaffordable_color)
        cost_label.visible = true
