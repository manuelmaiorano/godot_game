extends Node

var shared_scope: Blackboard

func _ready() -> void:
	shared_scope = Blackboard.new()
