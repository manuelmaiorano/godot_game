extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer



func _ready() -> void:
	agent.hit.connect(on_hit)
	bt.blackboard.set_var(&"attacker", null)
	
func on_hit(who):
	bt.blackboard.set_var(&"attacker", who)
	bt.blackboard.set_var(&"last_known_target_position", who.global_position)
	schedule_clear_attacker()

func schedule_clear_attacker():
	await get_tree().create_timer(5).timeout
	if bt.blackboard.get_var(&"attacker") != null:
		bt.blackboard.set_var(&"attacker", null)
