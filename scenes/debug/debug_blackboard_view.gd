extends Node3D

@export var agent: BaseAgent
@export var bt: BTPlayer

func _ready() -> void:
	pass
	

func _process(delta: float) -> void:
	#DebugDraw3D.draw_text(global_position, "hunger: %.3f; is_hungry: %s" % [stat_component.hunger, bt.blackboard.get_var(&"is_hungry")] , 64, Color.RED)
	DebugDraw2D.set_text(agent.name, get_info(), 64)
	
func get_info():
	return "hunger: %.3f; is_hungry: %s; food_target: %s; npc_target: %s; attacker: %s" % \
	[
		bt.blackboard.get_var(&"hunger_level", 0.0, false),
		bt.blackboard.get_var(&"is_hungry", null, false),
		bt.blackboard.get_var(&"food_target", null, false),
		bt.blackboard.get_var(&"target", null, false),
		bt.blackboard.get_var(&"attacker", null, false),
	]
