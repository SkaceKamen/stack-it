extends Node
class_name DataStore

static var data_file_path = "user://user_data.json"

static func load_data() -> Dictionary:
  if not FileAccess.file_exists(data_file_path):
    return {
      "scores": []
    }

  return _load_from_file(data_file_path)

static func save_data(data: Dictionary) -> void:
  _save_to_file(data_file_path, data)

static func _load_from_file(path: String) -> Dictionary:
  var data = {
  "scores": []
  }

  var file = FileAccess.open(path, FileAccess.READ)

  if file == null:
    return data

  var json = JSON.new().parse(file.get_as_text())

  if "high_score" in json:
    data["high_score"] = json["high_score"]

  for score_item in json["scores"]:
    data["scores"].append({
      "score": score_item["score"],
      "date": score_item["date"]
    })

  return data

static func _save_to_file(path: String, data: Dictionary) -> void:
  var json = {
  "scores": []
  }

  if "high_score" in data:
    json["high_score"] = data["high_score"]

  for score in data["scores"]:
    json["scores"].append({
      "score": score["score"],
      "date": score["date"]
    })

  var file = FileAccess.open(path, FileAccess.WRITE)
  file.store_string(json.to_json())
  file.close()
