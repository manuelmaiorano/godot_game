@tool
extends BTAction


# Task parameters.
@export var walk_anim_tree_state: StringName
var patrol_points: Array[Node3D] = []
var point_reach_distance: float

var current_point_index: int = 0


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	patrol_points = blackboard.get_var("patrol_points", null)
	current_point_index = blackboard.get_var("patrol_point_idx", null)
	return "Patrol"

func _enter() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = walk_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var target_pos = patrol_points[current_point_index]
	if agent.global_position.distance_to(target_pos) <= point_reach_distance:
		current_point_index = (current_point_index + 1) % patrol_points.size()
		blackboard.set_var("patrol_point_idx", current_point_index)
		return SUCCESS
		
	agent.rotate_towards_target(delta, agent.target)
	agent.apply_root_motion_to_velocity(delta, true)
	agent.move_and_slide()
	agent.apply_orientation_to_model()
	return RUNNING
