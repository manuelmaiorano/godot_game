extends Node3D

@export var dart_scene: PackedScene
@onready var dart_attachment: Marker3D = %DartAttachment

func _ready() -> void:
	
	schedule_firing()
	
func schedule_firing():
	while true:
		await get_tree().create_timer(1).timeout 
		fire()
		
func fire():
	var instance = dart_scene.instantiate()
	add_child(instance)
	instance.global_position = dart_attachment.global_position
	instance.velocity = - dart_attachment.global_basis.z * 100
