@tool
extends BTAction


# Task parameters.
@export var anim_tree_state: StringName
@export var final_anim_name: StringName

var last_animation_played = false

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "PerformAnimation"

func _enter() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = anim_tree_state
	agent.animation_tree.animation_finished.connect(func(name): if name == final_anim_name: last_animation_played = true)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if last_animation_played:
		return SUCCESS
	
	agent.apply_root_motion_to_velocity(delta, true)	
	agent.move_and_slide()
	agent.apply_orientation_to_model()
	return RUNNING
