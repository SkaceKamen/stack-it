using Godot;
using System;

namespace Stacking;

public partial class MenuScreen : Control
{
  [Export]
  Button StartButton;

  [Export]
  Label HighScoreLabel;

  [Signal]
  public delegate void StartRequestedEventHandler();

  public override void _Ready()
  {
    base._Ready();

    StartButton.Pressed += () =>
    {
      EmitSignal(SignalName.StartRequested);
    };

    VisibilityChanged += () =>
    {
      if (Visible)
      {
        UpdateData();
      }
    };

    UpdateData();
  }

  void UpdateData()
  {
    var highScore = DataStore.Data.HighScore;

    if (highScore.HasValue)
    {
      HighScoreLabel.Text = highScore.ToString();
    }
  }
}
