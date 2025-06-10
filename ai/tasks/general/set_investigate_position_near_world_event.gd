@tool
extends BTAction


# Task parameters.

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "SetInvPositionNearWorldEvent"
	

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:

	var world_event_pos = blackboard.top().get_var(&"world_event")
	blackboard.set_var(&"last_known_target_position", world_event_pos + MathUtils.pick_random_xz_vector(5, 15))
	return SUCCESS
