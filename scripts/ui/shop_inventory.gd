extends Control

@export var who: Node
@onready var inventory: GridContainer = %Inventory


func set_items(items: Dictionary[Item, int]):
	var idx = 0
	for item in items.keys():
		var amount = items[item]
		var shop_item = inventory.get_child(idx) as ShopItem
		shop_item.set_item(item)
		shop_item.set_amount(amount)
		idx += 1

func get_selected():
	pass
