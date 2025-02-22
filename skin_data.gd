extends Resource
class_name SkinData

@export var id: String = ""
@export var name: String = ""
@export var cost: int = 0
@export var icon: Texture2D
@export_file("*.tscn") var prefab_path: String

var _prefab

var prefab: PackedScene:
  get:
    if _prefab == null:
      _prefab = load(prefab_path)
    
    return _prefab