extends Node3D

@export var agent: BaseAgent
@export var stat_component: Node
@export var bt: BTPlayer

func _process(delta: float) -> void:
	DebugDraw3D.draw_text(global_position, "hunger: %.3f; is_hungry: %s" % [stat_component.hunger, bt.blackboard.get_var(&"is_hungry")] , 64, Color.RED)
