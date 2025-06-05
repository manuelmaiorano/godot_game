extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer



func _ready() -> void:
	agent.hit.connect(on_hit)
	bt.blackboard.set_var("attacker", null)
	bt.blackboard.set_var("time_since_attacked", null)
	
func on_hit(who):
	bt.blackboard.set_var("attacker", null)
	bt.blackboard.set_var("time_since_attacked", Time.get_ticks_msec())
