@tool
extends BTAction


# Task parameters.
@export var min_distance: float
@export var move_anim_tree_state: StringName
@export var run_away: bool = false
@export var use_root_motion: bool = false

var target = null

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "GoToTarget"

func _enter() -> void:
	target = blackboard.get_var("target")
	agent.animation_tree["parameters/Transition/transition_request"] = move_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if target == null or target.is_dead:
		return FAILURE
	
	var distance_to_target = agent.global_position.distance_to(target.global_position)
	if distance_to_target < min_distance:
		blackboard.set_var("distance_to_target", distance_to_target)
		return SUCCESS
	
	if run_away:
		agent.rotate_away_from_target(delta, target)
	else:
		agent.rotate_towards_target(delta, target)
	if use_root_motion:
		agent.apply_root_motion_to_velocity(delta)
	else:
		agent.apply_lateral_velocity(agent.entity_stats.run_speed)
	
	agent.apply_gravity(delta)
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()
	return RUNNING
