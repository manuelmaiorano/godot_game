@tool
extends BTAction


# Task parameters.

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "UpdateTarget"

func _enter() -> void:
	var current_target
	
	pass

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var current_target = blackboard.get_var("target")
	if current_target == null:
		var new_target = get_new_target()
		if new_target == null:
			return FAILURE
		blackboard.set_var("target", new_target)
		return SUCCESS
	

	var target_list = agent.target_list as Dictionary[Node3D, BaseAgent.TargetInfo]
	
	if not target_list[current_target].visible:
		pass
	return RUNNING


func get_new_target():
	pass
