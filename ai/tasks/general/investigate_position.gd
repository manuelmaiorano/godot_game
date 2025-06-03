@tool
extends BTAction


# Task parameters.
@export var min_distance: float
@export var move_anim_tree_state: StringName

var position = null

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "InvestigatePosition"

func _enter() -> void:
	position = blackboard.get_var("last_known_target_position")
	agent.animation_tree["parameters/Transition/transition_request"] = move_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if position == null:
		return FAILURE
	
	var distance_to_target = agent.global_position.distance_to(position)
	if distance_to_target < min_distance:
		blackboard.set_var("last_known_target_position", null)
		return SUCCESS
	
	agent.move_towards(delta, position)
	return RUNNING
