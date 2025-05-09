extends CanvasLayer

const INVENTORY: ButtonGroup = preload("res://resources/buttons/inventory.tres")
var item_list: Array

var current_idx = 0
@onready var inventory: PanelContainer = %Inventory
@onready var shop_inventory: PanelContainer = %ShopInventory

@onready var cross_hair: CenterContainer = %CrossHair
@export var shop_item_amounts: Dictionary[Item, int]


func _ready() -> void:
	item_list = %ItemList.get_children()
	cross_hair.hide()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	SignalBus.InventoryItemSelected.emit(item_list[current_idx].item)
	SignalBus.ItemsChanged.connect(on_items_changed)
	shop_inventory.set_items(shop_item_amounts)

func on_items_changed(items: Dictionary[Item, int]):
	for item in items.keys():
		var amount = items[item]
		for item_icon in item_list:
			if item_icon.item.name == item.name:
				item_icon.set_amount(amount)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	var scroll_action = Input.get_axis("scroll_left", "scroll_right")
	if is_zero_approx(scroll_action):
		return
	current_idx += int(scroll_action)
	current_idx %= item_list.size()
	
	item_list[current_idx].press()
	SignalBus.InventoryItemSelected.emit(item_list[current_idx].item)
