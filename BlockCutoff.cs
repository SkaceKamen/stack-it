using Godot;
using System;

namespace Stacking;

public partial class BlockCutoff : RigidBody3D
{
  [Export]
  MeshInstance3D Mesh;

  [Export]
  CollisionShape3D CollisionShape;

  public override void _Process(double delta)
  {
    base._Process(delta);

    if (Position.Y < -10)
    {
      QueueFree();
    }
  }

  public void SetSize(Vector2 size)
  {
    Mesh.Scale = new Vector3(size.X, 1, size.Y);
    CollisionShape.Scale = new Vector3(size.X, 1, size.Y);
  }
}
