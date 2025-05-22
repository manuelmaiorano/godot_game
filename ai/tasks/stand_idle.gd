@tool
extends BTAction


# Task parameters.
@export var idle_anim_tree_state: StringName

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "StandIdle"

func _enter() -> void:
	agent.animation_tree["parameters/Transition/transition_request"] = idle_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	agent.velocity.x = 0
	agent.velocity.z = 0
	agent.velocity += agent.gravity * delta
	
	agent.move_and_slide()
	return RUNNING
