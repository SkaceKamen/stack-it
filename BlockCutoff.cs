using Godot;
using System;

namespace Stacking;

public partial class BlockCutoff : MeshInstance3D
{
  float Velocity = 0;

  public override void _Process(double delta)
  {
    Velocity += (float)delta * 0.1f;
    Position = new Vector3(Position.X, Position.Y - Velocity, Position.Z);

    if (Position.Y < -10)
    {
      QueueFree();
    }
  }
}
