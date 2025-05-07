extends Node

@export var attaker: Node3D
@export var damage_area: Area3D
@export var animation_tree: AnimationTree
@export var attack_animation_name: StringName

@export var active: bool = false

func _ready() -> void:
	damage_area.body_entered.connect(_on_body_entered)
	animation_tree.animation_started.connect(_on_animation_started)

func _on_body_entered(body):
	if not active:
		return
	if body.has_method("take_damage"):
		body.take_damage(attaker, attaker.entity_stats.damage)

func _on_animation_started(anim_name):
	if anim_name == attack_animation_name:
		active = true
	else:
		active = false
