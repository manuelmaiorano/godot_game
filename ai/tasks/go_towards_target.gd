@tool
extends BTAction


# Task parameters.
@export var min_distance: float
@export var run_away: bool = false

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "GoToTarget"


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if agent.global_position.distance_to(agent.target.global_position) < min_distance:
		return SUCCESS
	
	if run_away:
		agent.rotate_away_from_target(delta, agent.target)
	else:
		agent.rotate_towards_target(delta, agent.target)
	agent.apply_root_motion_to_velocity(delta)
	agent.velocity += agent.gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()
	return RUNNING
