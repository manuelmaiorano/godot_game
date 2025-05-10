extends Node

@export var agent: CharacterBody3D
@export var projectile_scene: PackedScene
@export var starting_point: Node3D
@export var animation_tree: AnimationTree
@export var attack_animation_name: StringName
@export var targeting_component: Node

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") 
func _ready() -> void:
	animation_tree.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == attack_animation_name:
		throw()
		
		
func throw():
	var instance = projectile_scene.instantiate()
	
	agent.get_parent().add_child(instance)
	instance.shooter = agent
	instance.global_position = starting_point.global_position
	
	var initial_velocity = sqrt(gravity * agent.global_position.distance_to(targeting_component.target.global_position))
	instance.apply_impulse(starting_point.global_basis.z * initial_velocity)
