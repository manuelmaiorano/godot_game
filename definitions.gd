extends Node

class_name GLOBAL_DEFINITIONS
enum CHARACTER_ACTION {NONE, SIT, STAND, THROW, OPEN, PICK, ENTER_CAR, EXIT_CAR}

class AgentInput:
	var motion: Vector2
	var jumping: bool
	var running: bool
	var shooting: bool
	var aiming: bool
	var punching: bool
	var kicking: bool
	var talking: bool
	var action_id: int
	
	
class AgentPerceptions:
	var actions: Array
