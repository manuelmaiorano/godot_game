extends Node

var shared_scope: Blackboard

func _ready() -> void:
	shared_scope = Blackboard.new()
	shared_scope.set_var("global_targets", [])
