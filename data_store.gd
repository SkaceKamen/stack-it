extends Node
class_name DataStore

static var data_file_path = "user://data.json"

static func _get_default_data():
  return {
    "scores": [],
    "high_score": null,
    "money": 0,
  }

static func load_data() -> Dictionary:
  if not FileAccess.file_exists(data_file_path):
    return _get_default_data()

  return _load_from_file(data_file_path)

static func save_data(data: Dictionary) -> void:
  _save_to_file(data_file_path, data)

static func _load_from_file(path: String) -> Dictionary:
  var data = {
    "scores": [],
    "high_score": null,
    "money": 0,
  }

  var file = FileAccess.open(path, FileAccess.READ)

  if file == null:
    return data

  var file_data = JSON.parse_string(file.get_as_text())

  if file_data.has("high_score"):
    data["high_score"] = file_data["high_score"]

  if file_data.has("money"):
    data["money"] = file_data["money"]

  for score_item in file_data["scores"]:
    data["scores"].append({
      "score": score_item["score"],
      "date": score_item["date"]
    })

  return file_data

static func _save_to_file(path: String, data: Dictionary) -> void:
  var jsonData = _get_default_data()

  if data.has("money"):
    jsonData["money"] = data["money"]

  if data.has("high_score"):
    jsonData["high_score"] = data["high_score"]

  for score in data["scores"]:
    jsonData["scores"].append({
      "score": score["score"],
      "date": score["date"]
    })

  var file = FileAccess.open(path, FileAccess.WRITE)
  file.store_string(JSON.stringify(jsonData))
  file.close()
