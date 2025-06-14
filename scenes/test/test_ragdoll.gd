extends Node3D
@onready var physical_bone_simulator_3d: PhysicalBoneSimulator3D = %PhysicalBoneSimulator3D
@onready var camera_3d: Camera3D = $Camera3D


func  _ready() -> void:
	physical_bone_simulator_3d.active = true
	physical_bone_simulator_3d.physical_bones_start_simulation()
	camera_3d.make_current()
