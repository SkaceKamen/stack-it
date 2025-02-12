using Godot;
using System;

namespace Stacking;

public partial class Block : MeshInstance3D
{
  [Signal]
  public delegate void BlockStoppedEventHandler(Block block);

  [Export]
  public float Height = 0.2f;

  [Export]
  PackedScene BlockCutoffPrefab;

  public bool Moving = false;
  public int MoveSign = 1;
  public float MoveSpeed = 2;
  public int MoveAxis = 0;

  Vector3 MoveDirection => MoveAxis == 0 ? new Vector3(0, 0, MoveSign) : new Vector3(MoveSign, 0, 0);

  public Vector2 Size = new Vector2(1, 1);

  public override void _Ready()
  {
  }

  public override void _Process(double delta)
  {
    if (Moving)
    {
      // Move the block
      Position += MoveDirection * MoveSpeed * (float)delta;

      if (Math.Abs(Position.Z) >= 1 || Math.Abs(Position.X) >= 1)
      {
        MoveSign *= -1;
      }

      if (Input.IsActionJustPressed("ui_select"))
      {
        Stop();
      }
    }
  }

  public bool CutAccordingTo(Block block)
  {
    var myPosition = MoveAxis == 0 ? Position.Z : Position.X;
    var mySize = MoveAxis == 0 ? Size.Y : Size.X;
    var myPoint = (myPosition + (myPosition < 0 ? -1 : 1) * mySize);

    var otherPosition = MoveAxis == 0 ? block.Position.Z : block.Position.X;
    var otherSize = MoveAxis == 0 ? block.Size.Y : block.Size.X;
    var otherPoint = (otherPosition + (myPosition < 0 ? -1 : 1) * otherSize);

    var diff = myPoint - otherPoint;

    GD.Print("myPosition: " + myPosition);
    GD.Print("mySize: " + mySize);
    GD.Print("otherPosition: " + otherPosition);
    GD.Print("otherSize: " + otherSize);
    GD.Print("myPoint: " + myPoint);
    GD.Print("otherPoint: " + otherPoint);
    GD.Print("diff: " + diff + "\n");

    var cutoff = BlockCutoffPrefab.Instantiate<BlockCutoff>();
    GetParent().AddChild(cutoff);

    if (mySize - Math.Abs(diff) <= 0)
    {
      cutoff.Scale = new Vector3(Scale.X, Scale.Y, Scale.Z);
      cutoff.Position = new Vector3(Position.X, Position.Y, Position.Z);

      QueueFree();

      return false;
    }

    if (MoveAxis == 0)
    {
      Size.Y -= Math.Abs(diff);
      Scale = new Vector3(Scale.X, Scale.Y, Size.Y);
      Position = new Vector3(Position.X, Position.Y, Position.Z - diff / 2);

      cutoff.Scale = new Vector3(Scale.X, Scale.Y, Math.Abs(diff));
      cutoff.Position = new Vector3(Position.X, Position.Y, Position.Z + diff - diff / 2);
    }
    else
    {
      Size.X -= Math.Abs(diff);
      Scale = new Vector3(Size.X, Scale.Y, Scale.Z);
      Position = new Vector3(Position.X - diff / 2, Position.Y, Position.Z);

      cutoff.Scale = new Vector3(Math.Abs(diff), Scale.Y, Scale.Z);
      cutoff.Position = new Vector3(Position.X + diff - diff / 2, Position.Y, Position.Z);
    }

    return true;
  }

  private void Stop()
  {
    if (!Moving)
    {
      return;
    }

    Moving = false;

    EmitSignal(SignalName.BlockStopped, this);
  }
}
