@tool
extends BTAction


# Task parameters.
@export var fall_anim_tree_state: StringName
@export var velocity_to_take_damage: float = 15
@export var damage_taken: float = 1000
var max_velocity = 0


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Fall"

func _enter() -> void:
	if fall_anim_tree_state != "":
		agent.animation_tree["parameters/Transition/transition_request"] = fall_anim_tree_state

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if agent.is_on_floor():
		if max_velocity <= velocity_to_take_damage:
			return SUCCESS
		else:
			agent.take_damage(self, damage_taken)
			return FAILURE
	
	if abs(agent.velocity.y) > max_velocity:
		max_velocity = abs(agent.velocity.y)
	
	agent.velocity += agent.gravity * delta
	agent.move_and_slide()
	return RUNNING
