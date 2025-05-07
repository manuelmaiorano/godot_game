extends Node

@export var skeleton_modifier: SkeletonModifier3D
@export var target_node: Node3D
@export var animation_tree: AnimationTree
@export var attack_animation_name: StringName
@export var target_component: Node



func _ready() -> void:
	skeleton_modifier.active = false
	animation_tree.animation_started.connect(_on_animation_started)


func _on_animation_started(anim_name):
	if anim_name == attack_animation_name and target_component.target:
		target_node.global_position = target_component.target.global_position
		skeleton_modifier.active = true
	else:
		skeleton_modifier.active = false
