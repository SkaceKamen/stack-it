using Godot;
using System;

namespace Stacking;

public partial class GameManager : Node3D
{
  public enum State
  {
    Playing,
    Menu
  }

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

  State CurrentState = State.Menu;

  public override void _Ready()
  {
    LastBlock = BlocksContainer.GetChild<Block>(0);
    BaseCameraPosition = Camera.Position * 1f;

    UIManager.RestartRequested += () =>
    {
      Reset();
    };
    UIManager.StartRequested += () =>
    {
      Reset();
    };
  }

  public override void _Process(double delta)
  {
    // BlocksContainer.Position = new Vector3(0, Mathf.Lerp(BlocksContainer.Position.Y, -Height, 10 * (float)delta), 0);
    Camera.Position = new Vector3(Camera.Position.X, Mathf.Lerp(Camera.Position.Y, BaseCameraPosition.Y + Height, 10 * (float)delta), Camera.Position.Z);

    if (CurrentState == State.Playing && CurrentBlock != null)
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

    if (CurrentState != State.Playing)
    {
      return;
    }

    if (@event is InputEventScreenTouch touchEvent)
    {
      if (touchEvent.Pressed)
      {
        CurrentBlock.Stop();
      }
    }
  }

  public void Reset()
  {
    Score = 0;
    Height = 0;
    LastBlock = null;
    CurrentBlock = null;

    for (int i = 0; i < BlocksContainer.GetChildCount(); i++)
    {
      BlocksContainer.GetChild<Node>(i).QueueFree();
    }

    SpawnInitialBlock();
    SpawnBlock();

    CurrentState = State.Playing;
  }

  private void SpawnInitialBlock()
  {
    Block block = BlockPrefab.Instantiate<Block>();
    BlocksContainer.AddChild(block);

    block.Position = new Vector3(0, -block.Height, 0);

    CurrentBlock = block;
    LastBlock = block;
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
      GameOver();
      return;
    }

    LastBlock = block;
    Height += block.Height;
    Score += cutResult == Block.CutResult.Perfect ? 2 : 1;

    UIManager.UpdateScore(Score, cutResult == Block.CutResult.Perfect);

    SpawnBlock();
  }

  private void GameOver()
  {
    var userData = DataStore.Data;
    userData.Scores.Add(new DataStore.UserData.ScoreItem
    {
      Score = Score,
      Date = DateTime.Now
    });

    var isNewHighScore = false;

    if (!userData.HighScore.HasValue || Score > userData.HighScore)
    {
      userData.HighScore = Score;
      isNewHighScore = true;
    }

    UIManager.ShowGameOver(Score, isNewHighScore);

    CurrentState = State.Menu;

    DataStore.Data = userData;
  }
}
