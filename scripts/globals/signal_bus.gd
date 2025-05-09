extends Node


signal InventoryItemSelected(item: Item)
signal ItemsChanged(itemList: Dictionary[Item, int])

signal CloseToShop
signal FarFromShop
signal ShopEntered(shop_item_amounts: Dictionary[Item, int])
signal ShopExited

signal ShopItemSelected(item: Item, inventory: Node)
signal ShopItemChanged(shop_item_amounts: Dictionary[Item, int])

signal TryBuy(item: Item)
signal ItemBought(item: Item)
signal TrySell(item: Item)
signal ItemSold(item: Item)

signal MoneyChanged(value: int)
signal PlayerHealthChanged(value: int)

signal EnemyKilled(points: int)
signal PlayerDead
