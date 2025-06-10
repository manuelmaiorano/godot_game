@tool
extends BTCondition


# Task parameters.

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "CheckWorldEvent"
	

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:

	if blackboard.top().get_var("world_event") != null:
		return SUCCESS
	else:
		return FAILURE
