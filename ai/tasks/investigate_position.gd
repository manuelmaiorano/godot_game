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
		return SUCCESS
	
	agent.rotate_towards_point(delta, position)
	agent.apply_root_motion_to_velocity(delta)
	agent.velocity += agent.gravity * delta
	
	agent.move_and_slide()
	agent.apply_orientation_to_model()
	return RUNNING
