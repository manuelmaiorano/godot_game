extends Area3D

@export var agent: BaseAgent
@export var active = false

func _on_body_entered(body: Node3D) -> void:
	if not active:
		return
	if body == agent:
		return
	body.die()
	body.attach_to(self)
