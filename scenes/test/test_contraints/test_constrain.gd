extends Node3D
@onready var main_body: RigidBody3D = $Main
@export var move_speed = 50

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "backward", "forward")
	var direction3d = Vector3(direction.x, 0, direction.y)
	main_body.linear_velocity = direction3d * move_speed * delta
	
	
	
	
