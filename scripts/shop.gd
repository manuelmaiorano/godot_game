extends Node3D

var is_close = false
var active = false
@export var shop_item_amounts: Dictionary[Item, int]

func _ready() -> void:
	SignalBus.TryBuy.connect(on_item_bought)
	SignalBus.ItemSold.connect(on_item_sold)
	SignalBus.ShopExited.connect(func (): if active: active=false)

func on_item_bought(item):
	if not active:
		return
	
	if shop_item_amounts[item] == 0:
		return
	shop_item_amounts[item] -= 1
	SignalBus.ItemBought.emit(item)
	SignalBus.ShopItemChanged.emit(shop_item_amounts)

func on_item_sold(item):
	if not active:
		return
	
	if shop_item_amounts.has(item):
		shop_item_amounts[item] += 1
	else:
		shop_item_amounts[item] = 1
	SignalBus.ShopItemChanged.emit(shop_item_amounts)
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	SignalBus.CloseToInteractable.emit()
	is_close = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	SignalBus.FarFromInteractable.emit()
	is_close = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_close:
		return
		
	if Input.is_action_just_pressed("interact"):
		SignalBus.ShopEntered.emit(shop_item_amounts)
		active = true
		
