extends Node3D

@export var amount = 1
@export var consume_speed = 8

@onready var model: MeshInstance3D = $MeshInstance3D

func consume(_amount):
	amount -= _amount * consume_speed
	if amount < 0:
		queue_free()
		
	model.scale =Vector3.ONE * max(0.1, amount)
