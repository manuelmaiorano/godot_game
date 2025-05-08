extends Node


signal InventoryItemSelected(item: Item)
signal ItemsChanged(itemList: Dictionary[Item, int])
signal ShopEntered
signal ShopExit
signal ItemPurchased
signal ItemSold
