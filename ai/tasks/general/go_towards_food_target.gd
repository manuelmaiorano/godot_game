@tool
extends BTAction


# Task parameters.
@export var min_distance: float
@export var move_anim_tree_state: StringName

var target = null

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "GoToFoodTarget"

func _enter() -> void:
	target = blackboard.get_var("food_target")
	agent.animation_tree["parameters/Transition/transition_request"] = move_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if target == null or target.is_dead:
		return FAILURE
	
	var distance_to_target = agent.global_position.distance_to(target.global_position)
	if distance_to_target < min_distance:
		return SUCCESS
		
	agent.move_towards(delta, target.global_position)
	return RUNNING
