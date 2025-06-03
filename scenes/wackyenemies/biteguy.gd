extends BaseAgent

@export var target_to_attach_victim: Node3D

func blend_bite(amount):
	animation_tree["parameters/blendbite/add_amount"] = amount

func jump():
	velocity.y = entity_stats.jump_speed
