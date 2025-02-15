using Godot;
using System;

namespace Stacking;

public partial class BackgroundLayer : CanvasLayer
{
  [Export]
  TextureRect BackgroundTexture;

  Gradient Gradient
  {
    get
    {
      return ((GradientTexture2D)BackgroundTexture.Texture).Gradient;
    }
  }

  [Export]
  Godot.Collections.Array<Gradient> Gradients = new();

  float TargetGradient = 0;
  bool IsTransitioning = true;

  public override void _Ready()
  {
    base._Ready();
  }

  private static bool ColorsAlmostEqual(Color a, Color b, float tolerance = 0.01f)
  {
    return Mathf.Abs(a.R - b.R) < tolerance && Mathf.Abs(a.G - b.G) < tolerance && Mathf.Abs(a.B - b.B) < tolerance;
  }

  public override void _Process(double delta)
  {
    base._Process(delta);

    if (IsTransitioning)
    {
      var floorIndex = Mathf.FloorToInt(TargetGradient);
      var colorDelta = TargetGradient - floorIndex;
      var startGradient = Gradients[Mathf.FloorToInt(TargetGradient)];
      var endGradient = Gradients[Mathf.CeilToInt(TargetGradient)];
      var currentGradient = Gradient;
      var matching = 0;

      for (int i = 0; i < currentGradient.Colors.Length; i++)
      {
        var targetColor = startGradient.Colors[i].Lerp(endGradient.Colors[i], colorDelta);
        currentGradient.SetColor(i, currentGradient.Colors[i].Lerp(targetColor, 1f * (float)delta));

        if (ColorsAlmostEqual(currentGradient.Colors[i], targetColor))
        {
          matching++;
        }
      }

      if (matching == currentGradient.Colors.Length)
      {
        IsTransitioning = false;
      }

      ((GradientTexture2D)BackgroundTexture.Texture).Gradient = currentGradient;
    }
  }

  public void SetTarget(float target)
  {
    TargetGradient = target % (Gradients.Count - 1);
    IsTransitioning = true;

    GD.Print("Set target to " + TargetGradient);
  }
}
