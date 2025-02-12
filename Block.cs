using Godot;
using System;

namespace Stacking;

public partial class Block : MeshInstance3D
{
  public enum CutResult
  {
    Perfect,
    Missed,
    Partial,
  }

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

  public Vector2 Size = new(1, 1);

  public override void _Ready()
  {
  }

  public override void _Process(double delta)
  {
    if (Moving)
    {
      // Move the block
      Position += MoveDirection * MoveSpeed * (float)delta;

      if ((MoveAxis == 0 && Math.Abs(Position.Z) > 1) || (MoveAxis == 1 && Math.Abs(Position.X) > 1))
      {
        GD.Print("Switching direction " + MoveSign + " to " + -MoveSign + " from " + Position);

        MoveSign *= -1;
      }
    }
  }

  public CutResult CutAccordingTo(Block block)
  {
    var myPosition = MoveAxis == 0 ? Position.Z : Position.X;
    var otherPosition = MoveAxis == 0 ? block.Position.Z : block.Position.X;

    var sign = (myPosition - otherPosition) < 0 ? -1 : 1;

    var mySize = MoveAxis == 0 ? Size.Y : Size.X;
    var myPoint = myPosition + sign * mySize / 2;

    var otherSize = MoveAxis == 0 ? block.Size.Y : block.Size.X;
    var otherPoint = otherPosition + sign * otherSize / 2;

    var diff = myPoint - otherPoint;

    GD.Print("myPosition: " + myPosition);
    GD.Print("mySize: " + mySize);
    GD.Print("otherPosition: " + otherPosition);
    GD.Print("otherSize: " + otherSize);
    GD.Print("myPoint: " + myPoint);
    GD.Print("otherPoint: " + otherPoint);
    GD.Print("diff: " + diff + "\n");

    if (Math.Abs(diff) < 0.02f)
    {
      Position = new Vector3(
        block.Position.X,
        Position.Y,
        block.Position.Z
      );
      Size = block.Size;

      return CutResult.Perfect;
    }

    var cutoff = BlockCutoffPrefab.Instantiate<BlockCutoff>();
    GetParent().GetParent().AddChild(cutoff);

    if (mySize - Math.Abs(diff) <= 0)
    {
      cutoff.SetSize(Size);
      cutoff.Position = new Vector3(Position.X, Position.Y, Position.Z);

      QueueFree();

      return CutResult.Missed;
    }

    var previousSize = Size;

    if (MoveAxis == 0)
    {
      Size.Y -= Math.Abs(diff);
      Scale = new Vector3(Scale.X, Scale.Y, Size.Y);
      Position = new Vector3(Position.X, Position.Y, Position.Z - diff / 2);

      cutoff.SetSize(new Vector2(Size.X, Math.Abs(diff)));
      cutoff.Position = new Vector3(Position.X, Position.Y, Position.Z + sign * (previousSize.Y / 2f));
    }
    else
    {
      Size.X -= Math.Abs(diff);
      Scale = new Vector3(Size.X, Scale.Y, Scale.Z);
      Position = new Vector3(Position.X - diff / 2, Position.Y, Position.Z);

      cutoff.SetSize(new Vector2(Math.Abs(diff), Size.Y));
      cutoff.Position = new Vector3(Position.X + sign * (previousSize.X / 2f), Position.Y, Position.Z);
    }

    return CutResult.Partial;
  }

  public void Stop()
  {
    if (!Moving)
    {
      return;
    }

    Moving = false;

    EmitSignal(SignalName.BlockStopped, this);
  }
}
