@tool
extends BTAction


# Task parameters.
@export var walk_anim_tree_state: StringName
@export var point_reach_distance: float

var patrol_points = []

var current_point_index: int = 0

func _setup() -> void:
	blackboard.set_var(&"patrol_point_idx", 0)

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "GoToNextPatrolPoint"

func _enter() -> void:
	patrol_points = blackboard.get_var(&"patrol_points", [])
	current_point_index = blackboard.get_var(&"patrol_point_idx", 0)
	agent.animation_tree["parameters/Transition/transition_request"] = walk_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if patrol_points.is_empty():
		return FAILURE
		
	var target_pos = patrol_points[current_point_index].global_position
	if agent.global_position.distance_to(target_pos) <= point_reach_distance:
		current_point_index = (current_point_index + 1) % patrol_points.size()
		blackboard.set_var(&"patrol_point_idx", current_point_index)
		return SUCCESS
		
	agent.move_towards(delta, patrol_points[current_point_index].global_position, false, false)
	return RUNNING
