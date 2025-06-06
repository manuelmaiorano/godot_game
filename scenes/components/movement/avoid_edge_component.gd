extends Node
@export var agent: BaseAgent
@export var check_edge_raycast_l: RayCast3D
@export var check_edge_raycast_r: RayCast3D
@export var time_to_turn_on_edge: float = 1

func update_direction(delta, direction):
	if not check_edge_raycast_l.is_colliding() and not check_edge_raycast_l.is_colliding():
		direction *= -1
	else:
		if not check_edge_raycast_l.is_colliding():
			direction = direction.rotated(Vector3.UP, -delta * 1/time_to_turn_on_edge)
		if not check_edge_raycast_r.is_colliding():
			direction = direction.rotated(Vector3.UP, delta * 1/time_to_turn_on_edge)
	return direction
