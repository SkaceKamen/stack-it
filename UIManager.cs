using Godot;
using System;

namespace Stacking;

public partial class UIManager : CanvasLayer
{
  [Export]
  Label ScoreLabel;

  [Export]
  AnimationPlayer AnimationPlayer;

  public override void _Ready()
  {
    ScoreLabel.Text = "0";
  }

  public void UpdateScore(int score)
  {
    ScoreLabel.Text = score.ToString();
    AnimationPlayer.Stop();
    AnimationPlayer.Play("Score");
  }
}
