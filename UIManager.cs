using Godot;
using System;

namespace Stacking;

public partial class UIManager : CanvasLayer
{
  [Signal]
  public delegate void RestartRequestedEventHandler();

  [Export]
  Label ScoreLabel;

  [Export]
  AnimationPlayer AnimationPlayer;

  [Export]
  Control Ingame;

  [Export]
  Control MenuScreen;

  [Export]
  GameEndScreen GameEndScreen;

  [Export]
  Button StartButton;

  public override void _Ready()
  {
    ScoreLabel.Text = "0";

    GameEndScreen.RestartRequested += () =>
    {
      EmitSignal(SignalName.RestartRequested);
      Ingame.Visible = true;
      GameEndScreen.Visible = false;
    };

    GameEndScreen.MenuRequested += () =>
    {
      Ingame.Visible = false;
      GameEndScreen.Visible = false;
      MenuScreen.Visible = true;
    };

    StartButton.Pressed += () =>
    {
      Ingame.Visible = true;
      MenuScreen.Visible = false;
    };

  }

  public void ShowGameOver(int finalScore, bool isHighScore)
  {
    Ingame.Visible = false;
    GameEndScreen.Show(finalScore, isHighScore);
  }

  public void UpdateScore(int score, bool highlight)
  {
    ScoreLabel.Text = score.ToString();
    AnimationPlayer.Stop();
    AnimationPlayer.Play(highlight ? "ScorePerfect" : "Score");

    GD.Print(highlight ? "ScorePerfect" : "Score");
  }
}
