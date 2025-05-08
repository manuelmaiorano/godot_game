extends CanvasLayer

const INVENTORY: ButtonGroup = preload("res://resources/buttons/inventory.tres")
var item_list: Array

var current_idx = 0
@export var scroll_speed = 0.1
@onready var cross_hair: CenterContainer = %CrossHair

func _ready() -> void:
	item_list = %ItemList.get_children()
	cross_hair.hide()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.InventoryItemSelected.emit(item_list[current_idx].item)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	var scroll_action = Input.get_axis("scroll_left", "scroll_right")
	if is_zero_approx(scroll_action):
		return
	current_idx += int(scroll_action)
	current_idx %= item_list.size()
	
	item_list[current_idx].button_pressed = true
	SignalBus.InventoryItemSelected.emit(item_list[current_idx].item)
