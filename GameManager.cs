using Godot;
using System;

namespace Stacking;

public partial class GameManager : Node3D
{
  [Export]
  PackedScene BlockPrefab;

  [Export]
  Node3D BlocksContainer;

  [Export]
  UIManager UIManager;

  [Export]
  Camera3D Camera;


  float Height = 0;

  Block LastBlock;

  Block CurrentBlock;

  int Score = 0;


  Vector3 BaseCameraPosition;

  public override void _Ready()
  {
    LastBlock = BlocksContainer.GetChild<Block>(0);
    BaseCameraPosition = Camera.Position * 1f;

    SpawnBlock();
  }

  public override void _Process(double delta)
  {
    // BlocksContainer.Position = new Vector3(0, Mathf.Lerp(BlocksContainer.Position.Y, -Height, 10 * (float)delta), 0);
    Camera.Position = new Vector3(Camera.Position.X, Mathf.Lerp(Camera.Position.Y, BaseCameraPosition.Y + Height, 10 * (float)delta), Camera.Position.Z);

    if (CurrentBlock != null)
    {
      if (Input.IsActionJustPressed("ui_select"))
      {
        CurrentBlock.Stop();
      }
    }
  }

  public override void _Input(InputEvent @event)
  {
    base._Input(@event);

    if (@event is InputEventScreenTouch touchEvent)
    {
      if (touchEvent.Pressed)
      {
        CurrentBlock.Stop();
      }
    }
  }

  private void SpawnBlock()
  {
    var newAxis = LastBlock.MoveAxis == 0 ? 1 : 0;

    Block block = BlockPrefab.Instantiate<Block>();
    BlocksContainer.AddChild(block);
    block.Position = newAxis == 0 ? new Vector3(LastBlock.Position.X, Height, -1) : new Vector3(-1, Height, LastBlock.Position.Z);
    block.BlockStopped += BlockStopped;
    block.MoveAxis = newAxis;
    block.Moving = true;
    block.Size = new Vector2(LastBlock.Size.X, LastBlock.Size.Y);
    block.Scale = new Vector3(LastBlock.Scale.X, LastBlock.Scale.Y, LastBlock.Scale.Z);

    CurrentBlock = block;
  }

  private void BlockStopped(Block block)
  {
    var cutResult = block.CutAccordingTo(LastBlock);

    if (cutResult == Block.CutResult.Missed)
    {
      UIManager.ShowGameOver();
      return;
    }


    LastBlock = block;
    Height += block.Height;
    Score += cutResult == Block.CutResult.Perfect ? 2 : 1;

    UIManager.UpdateScore(Score, cutResult == Block.CutResult.Perfect);

    SpawnBlock();

  }
}
