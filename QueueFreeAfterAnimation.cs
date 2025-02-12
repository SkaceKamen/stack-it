using Godot;
using System;

namespace Stacking;

public partial class QueueFreeAfterAnimation : Node
{
  [Export]
  AnimationPlayer AnimationPlayer;

  public override void _Ready()
  {
    base._Ready();

    AnimationPlayer.AnimationFinished += (StringName animName) =>
    {
      GetParent().QueueFree();
    };
  }
}
