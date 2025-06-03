extends Control

@export var character: CharacterBody3D
@onready var label: Label = %Label

func _physics_process(delta: float) -> void:
	label.text = "name: %s, vel_x: %.3f, vel_z: %.3f, |v|:  %.3f" % [character.name, character.velocity.x, character.velocity.z, character.velocity.length()]
