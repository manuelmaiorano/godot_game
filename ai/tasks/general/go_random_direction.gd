@tool
extends BTAction


# Task parameters.
@export var move_anim_tree_state: StringName

var direction = null

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "GoRandomDirection"

func _enter() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = move_anim_tree_state
	direction = MathUtils.pick_random_xz_vector()

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:

	agent.move_along_direction(delta, direction)
	return RUNNING
