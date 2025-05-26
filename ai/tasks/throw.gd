@tool
extends BTAction


# Task parameters.

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Throw"
	
var component = null
func _setup() -> void:
	if agent.has_node("ThrowStuffComponent"):
		component = agent.get_node("ThrowStuffComponent")
		return 

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if not component:
		return FAILURE
	var target = blackboard.get_var("target", null)
	if target == null:
		return FAILURE
	component.throw(target)
	return SUCCESS
