extends Node3D

signal state_changed(me)

@export var locked = false
@export var opened = false

enum ACTION {OPEN, CLOSE, LOCK, UNLOCK}

func get_possible_actions():
	if opened:
		return [ACTION.CLOSE]
	if locked:
		return [ACTION.UNLOCK]
	return [ACTION.LOCK, ACTION.OPEN]
	
func get_player_action(action: ACTION):
	match action:
		ACTION.OPEN: return GLOBAL_DEFINITIONS.CHARACTER_ACTION.OPEN
		ACTION.CLOSE: return GLOBAL_DEFINITIONS.CHARACTER_ACTION.NONE
		ACTION.LOCK: return GLOBAL_DEFINITIONS.CHARACTER_ACTION.NONE
		ACTION.UNLOCK: return GLOBAL_DEFINITIONS.CHARACTER_ACTION.NONE
		
func get_action_description(action: ACTION):
	match action:
		ACTION.OPEN: return "Open the door"
		ACTION.CLOSE: return "Close the door"
		ACTION.LOCK: return "Lock the door"
		ACTION.UNLOCK: return "Unlock the door"

func open():
	if opened or locked:
		return
	$"Sketchfab_model/Model/RootNode/SM Office Door/AnimationPlayer".play("open")
	opened = true

func close():
	if not opened:
		return
	$"Sketchfab_model/Model/RootNode/SM Office Door/AnimationPlayer".play_backwards("open")
	opened = false

func lock():
	if opened or locked: return
	locked = true
	
func unlock():
	if opened or not locked: return
	locked = false

func act(action: ACTION):
	match action:
		ACTION.OPEN: open()
		ACTION.CLOSE: close()
		ACTION.LOCK: lock()
		ACTION.UNLOCK: unlock()
	state_changed.emit(self)
		
func _on_area_3d_body_entered(body):
	pass
	
