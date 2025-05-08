extends Control
class_name ShopItem


@onready var amount: Label = %Amount
@onready var price: Label = %Price
@onready var texture_rect: TextureRect = %TextureRect
@onready var item_button: Button = %ItemButton

func _ready() -> void:
	set_item(null)

func set_item(item: Item):
	if item == null:
		texture_rect.texture = null
		price.text = ""
		amount.text = ""
		item_button.disabled = true
		return
	
	item_button.disabled = false
	texture_rect.texture = item.icon
	price.text = str(item.price)
	

func set_amount(value):
	amount.text = str(value)
