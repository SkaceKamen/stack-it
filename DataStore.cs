using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Stacking;

public static class DataStore
{
  private static readonly string dataFilePath = "user://user_data.json";

  public class UserData
  {
    public class ScoreItem
    {
      public int Score { get; set; }
      public DateTime Date { get; set; }
    }

    public int? HighScore { get; set; }
    public List<ScoreItem> Scores { get; set; }
  }

  private static UserData _data;

  public static UserData Data
  {
    get
    {
      _data ??= LoadFromFile(dataFilePath);

      return _data;
    }

    set
    {
      _data = value;
      SaveToFile(dataFilePath, _data);
    }
  }

  private static UserData LoadFromFile(string path)
  {
    var data = new UserData
    {
      Scores = new List<UserData.ScoreItem>()
    };

    var file = FileAccess.Open(path, FileAccess.ModeFlags.Read);

    if (file == null)
    {
      return data;
    }

    var json = (Dictionary)Json.ParseString(file.GetAsText());

    if (json.ContainsKey("HighScore"))
    {
      data.HighScore = (int)json["HighScore"];
    }

    var scoresArray = (Godot.Collections.Array)json["Scores"];

    foreach (Dictionary scoreItem in scoresArray.Select(v => (Dictionary)v))
    {
      var score = new UserData.ScoreItem
      {
        Score = (int)scoreItem["Score"],
        Date = DateTime.Parse((string)scoreItem["Date"])
      };

      data.Scores.Add(score);
    }

    return data;
  }

  private static void SaveToFile(string path, UserData data)
  {
    var json = new Dictionary
    {
      { "Scores", new Godot.Collections.Array() }
    };

    if (data.HighScore.HasValue)
    {
      json["HighScore"] = data.HighScore.Value;
    }

    foreach (var score in data.Scores)
    {
      ((Godot.Collections.Array)json["Scores"]).Add(new Dictionary
      {
        { "Score", score.Score },
        { "Date", score.Date.ToUniversalTime().ToString("o") }
      });
    }

    var file = FileAccess.Open(path, FileAccess.ModeFlags.Write);
    file.StoreString(json.ToString());
    file.Close();
  }

  public static void Save()
  {
    SaveToFile(dataFilePath, _data);
  }
}
