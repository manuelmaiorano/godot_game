extends Node
@export var agent: BaseAgent
@export var bt: BTPlayer

@export var initial_hunger: float = 0

@export var time_to_get_hungry_seconds: int = 200
@export var time_to_eat_seconds: int = 10

var hunger = 0

func _ready() -> void:
	hunger = initial_hunger
	bt.blackboard.set_var(&"is_hungry", false)
	bt.blackboard.set_var(&"hunger_level", hunger)
	
func _physics_process(delta: float) -> void:
	hunger += delta * 1.0/time_to_get_hungry_seconds
	bt.blackboard.set_var(&"hunger_level", hunger)
	if hunger > 0.5:
		bt.blackboard.set_var(&"is_hungry", true)
	if hunger > 1:
		hunger = 1
		return
		agent.die()
	
	
func eat(delta):
	if hunger <= 0:
		return
	var amount = min(hunger, delta * 1.0/time_to_eat_seconds)
	hunger -= amount
	if hunger <= 0.3:
		bt.blackboard.set_var(&"is_hungry", false)
		
	return amount
