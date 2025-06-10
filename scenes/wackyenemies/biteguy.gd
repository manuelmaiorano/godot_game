extends BaseAgent
@onready var bite_area: Area3D = %BiteArea

@export var target_to_attach_victim: Node3D

func blend_bite(amount):
	animation_tree["parameters/blendbite/add_amount"] = amount
	
func activate_attach_to_area():
	bite_area.active = true


func deactivate_attach_to_area():
	bite_area.active = false

func jump():
	velocity.y = entity_stats.jump_speed
