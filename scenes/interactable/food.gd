extends Node3D

@export var amount = 3
@export var consume_speed = 8
@export var time_to_grow = 20

@onready var model: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	model.scale =Vector3.ONE * max(0.1, amount)
	
func _physics_process(delta: float) -> void:
	amount += delta * 1/time_to_grow
	model.scale = Vector3.ONE * clamp(amount, 0.1, 5)

func consume(_amount):
	amount -= _amount * consume_speed
	if amount < 0:
		amount = 0
		
	model.scale =Vector3.ONE * max(0.1, amount)
