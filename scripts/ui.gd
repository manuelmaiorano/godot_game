extends CanvasLayer

const INVENTORY: ButtonGroup = preload("res://resources/buttons/inventory.tres")
var item_list: Array

var current_idx = 0
@onready var inventory: PanelContainer = %Inventory
@onready var shop_inventory: PanelContainer = %ShopInventory
@onready var shop_menu: Control = %ShopMenu
@onready var info_label: Label = %InfoLabel
@onready var money: Label = %Money
@onready var playerhealth: ProgressBar = %Playerhealth
@onready var cross_hair: CenterContainer = %CrossHair
@onready var end_screen: VBoxContainer = %EndScreen
@onready var end_screen_label: Label = %EndScreenLabel
@onready var mission_status: Label = %Mission_status


var current_shop_item_selected: Item = null
var is_shop_item = false

func _enter_tree() -> void:
	SignalBus.ItemsChanged.connect(on_items_changed)
	SignalBus.ShopEntered.connect(func(x): shop_menu.show(); info_label.hide();  shop_inventory.set_items(x))
	SignalBus.ShopItemChanged.connect(func(x): shop_inventory.set_items(x))
	SignalBus.CloseToInteractable.connect(func(): info_label.show())
	SignalBus.FarFromInteractable.connect(func(): info_label.hide())
	SignalBus.ShopItemSelected.connect(on_shop_item_selected)
	SignalBus.MoneyChanged.connect(func(x): money.text = str(x))
	SignalBus.PlayerHealthChanged.connect(func(x): playerhealth.value = x * 100)
	SignalBus.PlayerDead.connect(func(): end_screen.show(); end_screen_label.text = "GameOver")
	SignalBus.MissionCompleted.connect(func(): end_screen.show(); end_screen_label.text = "Mission Passed")
	SignalBus.MissionStatusChanged.connect(func(x): mission_status.text = x)
	

func _ready() -> void:
	item_list = %ItemList.get_children()
	cross_hair.hide()
	shop_menu.hide()
	info_label.hide()
	end_screen.hide()
	
	item_list[current_idx].press()
	SignalBus.InventoryItemSelected.emit(item_list[current_idx].item)
	

func on_shop_item_selected(item, inventory):
	if inventory == shop_inventory:
		is_shop_item = true
	else:
		is_shop_item = false
		
	current_shop_item_selected = item
	
func on_items_changed(items: Dictionary[Item, int]):
	for item in items.keys():
		var amount = items[item]
		for item_icon in item_list:
			if item_icon.item.name == item.name:
				item_icon.set_amount(amount)
	
	inventory.set_items(items)
	
	
func _unhandled_input(event: InputEvent) -> void:
		
	var scroll_action = Input.get_axis("scroll_left", "scroll_right")
	if is_zero_approx(scroll_action):
		return
	current_idx += int(scroll_action)
	current_idx %= item_list.size()
	
	item_list[current_idx].press()
	SignalBus.InventoryItemSelected.emit(item_list[current_idx].item)


func _on_buy_button_up() -> void:
	if current_shop_item_selected == null:
		return
	if is_shop_item:
		if get_tree().get_first_node_in_group("player").money < current_shop_item_selected.price:
			return
		SignalBus.TryBuy.emit(current_shop_item_selected)


func _on_sell_button_up() -> void:
	if current_shop_item_selected == null:
		return
	if not is_shop_item:
		SignalBus.TrySell.emit(current_shop_item_selected)


func _on_close_button_up() -> void:
	SignalBus.ShopExited.emit()
	shop_menu.hide()


func _on_restart_button_up() -> void:
	SignalBus.RestartGame.emit()
