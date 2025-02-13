using Godot;

namespace Stacking;

public partial class GameEndScreen : Control
{
  [Signal]
  public delegate void RestartRequestedEventHandler();

  [Signal]
  public delegate void MenuRequestedEventHandler();

  [Export]
  AnimationPlayer AnimationPlayer;

  [Export]
  Button RestartButton;

  [Export]
  Button MenuButton;

  [Export]
  Label NormalScoreLabel;

  [Export]
  Label HighScoreLabel;

  [Export]
  Label ScoreValueLabel;

  public override void _Ready()
  {
    base._Ready();

    RestartButton.Pressed += () =>
    {
      EmitSignal(SignalName.RestartRequested);
    };

    MenuButton.Pressed += () =>
    {
      EmitSignal(SignalName.MenuRequested);
    };
  }

  public void Show(int score, bool isNewHighScore)
  {
    if (isNewHighScore)
    {
      NormalScoreLabel.Visible = false;
      HighScoreLabel.Visible = true;
    }
    else
    {
      NormalScoreLabel.Visible = true;
      HighScoreLabel.Visible = false;
    }

    ScoreValueLabel.Text = score.ToString();

    AnimationPlayer.Stop();
    AnimationPlayer.Play("Show");
    Visible = true;
  }
}
