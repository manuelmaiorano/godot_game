extends Area3D

@export var attaker: BaseAgent


func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body == attaker:
		return
	if body.has_method("take_damage"):
		body.take_damage(attaker, attaker.entity_stats.damage)
