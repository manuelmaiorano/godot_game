extends Control
@onready var amount: Label = %Amount
@onready var price: Label = %Price
@onready var texture_rect: TextureRect = %TextureRect

func _ready() -> void:
	set_amount(0)

func set_item(item: Item):
	if item == null:
		texture_rect.texture = null
		price.text = ""
		amount.text = ""
		return
	texture_rect.texture = item.icon
	price.text = str(item.price)
	

func set_amount(value):
	amount.text = str(value)
