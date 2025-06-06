extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer
@export var detect_area: Area3D


func _ready() -> void:
	bt.blackboard.set_var(&"is_predator_nearby", false)
	bt.blackboard.set_var(&"current_predator", null)
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)
	
func _on_body_entered(body) -> void:
	if agent.check_if_predator(body):
		bt.blackboard.set_var(&"is_predator_nearby", true)
		bt.blackboard.set_var(&"current_predator", body)


func _on_body_exited(body) -> void:
	var current_predator = bt.blackboard.get_var(&"current_predator")
	if current_predator == body:
		bt.blackboard.set_var(&"is_predator_nearby", false)
