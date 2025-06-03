extends Control
@export var item: Item
@onready var label: Label = %Label
@onready var button: Button = %Button

func _ready() -> void:
	label.text = "0"
	button.icon = item.icon
	
func set_amount(value):
	label.text = str(value)

func press():
	button.button_pressed = true
	
