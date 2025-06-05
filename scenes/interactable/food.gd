extends Node3D

@export var amount = 1
@export var consume_speed = 8

func consume(_amount):
	amount -= _amount * consume_speed
	if amount < 0:
		queue_free()
	
