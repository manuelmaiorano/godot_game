extends Control
class_name ShopItem


@onready var amount: Label = %Amount
@onready var price: Label = %Price
@onready var texture_rect: TextureRect = %TextureRect
@onready var item_button: Button = %ItemButton

@export var inventory: Node

var current_item = null

func _ready() -> void:
	set_item(null)
	SignalBus.MoneyChanged.connect(on_money_changed)

func on_money_changed(value):
	if current_item == null:
		return
		
	if not inventory.is_shop:
		return
		
	if value < current_item.price:
		price.theme_type_variation = &"LabelRed"
	else:
		price.theme_type_variation = &"Label"

func set_item(item: Item):
	if item == null:
		texture_rect.texture = null
		price.text = ""
		amount.text = ""
		item_button.disabled = true
		current_item = null
		return
	current_item = item
	item_button.disabled = false
	texture_rect.texture = item.icon
	price.text = str(item.price)
	

func set_amount(value):
	amount.text = str(value)
	if value == 0:
		amount.theme_type_variation = &"LabelRed"
	else:
		amount.theme_type_variation = &"Label"


func set_button_group(group):
	item_button.button_group = group


func _on_item_button_pressed() -> void:
	if current_item == null:
		return
	SignalBus.ShopItemSelected.emit(current_item,  inventory)
