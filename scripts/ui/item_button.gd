extends Button
@export var item: Item

func _ready() -> void:
	text = "0"
	icon = item.icon
	
func set_amount(value):
	text = str(value)
