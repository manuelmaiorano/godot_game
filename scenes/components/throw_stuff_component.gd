extends Node

@export var agent: CharacterBody3D
@export var projectile_scene: PackedScene
@export var starting_point: Node3D

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") 
		
func throw(target):
	var instance = projectile_scene.instantiate()
	
	agent.get_parent().add_child(instance)
	instance.shooter = agent
	instance.global_position = starting_point.global_position
	
	var initial_velocity = sqrt(gravity * agent.global_position.distance_to(target.global_position))
	instance.apply_impulse(starting_point.global_basis.z * initial_velocity)
