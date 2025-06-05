extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer

@export var time_to_get_hungry_seconds: int = 200
@export var time_to_eat_seconds: int = 10

var hunger = 0

func _ready() -> void:
	bt.blackboard.set_var("is_hungry", false)
	
func _physics_process(delta: float) -> void:
	hunger += delta * 1.0/time_to_get_hungry_seconds
	if hunger > 0.5:
		bt.blackboard.set_var("is_hungry", true)
	if hunger > 1:
		agent.die()
	
	
func eat(delta):
	hunger -= delta * 1.0/time_to_eat_seconds
	if hunger <= 0.1:
		bt.blackboard.set_var("is_hungry", false)
