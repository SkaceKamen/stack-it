using Godot;
using System;

namespace Stacking;

public partial class UIManager : CanvasLayer
{
  [Export]
  Label ScoreLabel;

  [Export]
  AnimationPlayer AnimationPlayer;

  [Export]
  Control GameEndScreen;

  [Export]
  Button RestartButton;

  public override void _Ready()
  {
    ScoreLabel.Text = "0";
    RestartButton.Pressed += () =>
    {
      GetTree().ReloadCurrentScene();
    };
  }

  public void ShowGameOver()
  {
    GameEndScreen.Visible = true;
  }

  public void UpdateScore(int score, bool highlight)
  {
    ScoreLabel.Text = score.ToString();
    AnimationPlayer.Stop();
    AnimationPlayer.Play(highlight ? "ScorePerfect" : "Score");

    GD.Print(highlight ? "ScorePerfect" : "Score");
  }
}
