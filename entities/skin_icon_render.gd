extends Node

@export var game_data: GameData
@export var base_camera: Camera3D

func _ready():
  var base_camera_position = base_camera.position * 1
  var base_camera_rotation = base_camera.rotation * 1

  for item in game_data.skins:
    if not item.icon:
      var sub_viewport = SubViewport.new()

      sub_viewport.size = Vector2(128, 128)
      sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
      sub_viewport.transparent_bg = true

      add_child(sub_viewport)

      for i in range(5):
        var skin_instance = item.prefab.instantiate() as BlockSkin
        skin_instance.position = Vector3(0, -100 + i * 0.2, 0)
        skin_instance.set_state(i * 0.2 * 18.75, i * 5, Vector3(1, 1, 1), Vector3(0, 0, 0))
        sub_viewport.add_child(skin_instance)

      var local_camera = Camera3D.new()

      local_camera.projection = Camera3D.ProjectionType.PROJECTION_ORTHOGONAL
      local_camera.size = 1.6
      local_camera.near = 0.001
      local_camera.far = 5000
      local_camera.position = base_camera_position + Vector3(0, -100, 0)
      local_camera.rotation = base_camera_rotation

      sub_viewport.add_child(local_camera)

      await RenderingServer.frame_post_draw

      item.icon = ImageTexture.create_from_image(sub_viewport.get_texture().get_image())

      sub_viewport.free()
  
  queue_free()