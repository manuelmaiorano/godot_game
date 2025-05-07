extends Node

@export var weapon: Node3D
@export var animation_tree: AnimationTree
@export var attack_animation_name: StringName


func _ready() -> void:
	animation_tree.animation_started.connect(_on_animation_started)

func _on_animation_started(anim_name):
	if anim_name == attack_animation_name:
		weapon.active = true
	else:
		weapon.active = false
