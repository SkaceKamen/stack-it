extends Node3D
class_name PerfectEffect

@export var mesh: MeshInstance3D

func set_size(size: Vector3):
  var material = mesh.mesh.material as StandardMaterial3D
  var new_mesh = PlaneMesh.new()
  new_mesh.size = Vector2(size.x, size.z)
  new_mesh.material = material
  mesh.mesh = new_mesh