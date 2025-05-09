extends Control

@onready var inventory: GridContainer = %Inventory
@export var button_group: ButtonGroup
@export var is_shop: bool = true

func _ready() -> void:
	for slots in inventory.get_children():
		slots.set_item(null)
		slots.set_button_group(button_group)
		slots.inventory = self
	
func set_items(items: Dictionary[Item, int]):
	for slots in inventory.get_children():
		slots.set_item(null)
	var idx = 0
	for item in items.keys():
		var amount = items[item]
		var shop_item = inventory.get_child(idx) as ShopItem
		shop_item.set_item(item)
		shop_item.set_amount(amount)
		idx += 1

func get_selected():
	pass
