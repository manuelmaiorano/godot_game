extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer


func _ready() -> void:
	bt.blackboard.set_var("food_target", null)
	


func _on_area_3d_area_entered(area: Area3D) -> void:
	bt.blackboard.set_var("food_target", area)
