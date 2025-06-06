@tool
extends BTAction


var target = null
var sense_component = null

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "TryFindNearbyFood"
	
func _setup() -> void:
	sense_component = agent.find_child("SenseFoodComponent")


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if sense_component.try_set_nearby_food():
		return SUCCESS
	else:
		return FAILURE
	return RUNNING
