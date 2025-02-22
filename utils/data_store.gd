extends Node
class_name DataStore

class UserDataScore:
  var score: int
  var date: String

  func _init(set_score: int, set_date: String):
    score = set_score
    date = set_date

  func to_dict() -> Dictionary:
    return {
      "score": score,
      "date": date
    }

  static func from_dict(data: Dictionary) -> UserDataScore:
    return UserDataScore.new(data["score"], data["date"])

class UserData:
  var scores: Array[UserDataScore] = []
  var high_score: int
  var money = 0
  var owned_skins: Array = []
  var current_skin: String

  func to_dict() -> Dictionary:
    var data = {
      "scores": [],
      "high_score": high_score,
      "money": money,
      "owned_skins": owned_skins,
      "current_skin": current_skin
    }

    for score in scores:
      data["scores"].append(score.to_dict())

    return data

  static func from_dict(data: Dictionary) -> UserData:
    var user_data = UserData.new()
    user_data.high_score = data["high_score"] if data.has("high_score") else null
    user_data.money = data["money"] if data.has("money") else 0
    user_data.owned_skins = (data["owned_skins"] if data.has("owned_skins") else []) as Array[String]
    user_data.current_skin = data["current_skin"] if data.has("current_skin") else ''

    for score in data["scores"]:
      user_data.scores.append(UserDataScore.from_dict(score))

    return user_data

static var data_file_path = "user://data.json"

static var _user_data: UserData

static var user_data: UserData:
  get:
    if _user_data:
      return _user_data

    _user_data = _load_data()
    return _user_data
  set(value):
    _user_data = value
    _save_data(value)


static func _load_data() -> UserData:
  if not FileAccess.file_exists(data_file_path):
    return UserData.new()

  return _load_from_file(data_file_path)

static func _save_data(data: UserData) -> void:
  _save_to_file(data_file_path, data)

static func _load_from_file(path: String) -> UserData:
  var file = FileAccess.open(path, FileAccess.READ)

  if file == null:
    return UserData.new()

  var file_data = JSON.parse_string(file.get_as_text())

  return UserData.from_dict(file_data)

static func _save_to_file(path: String, data: UserData) -> void:
  var file = FileAccess.open(path, FileAccess.WRITE)
  file.store_string(JSON.stringify(data.to_dict()))
  file.close()

static func save_user_data():
  _save_data(_user_data)
