extends Node


signal InventoryItemSelected(item: Item)
signal ItemsChanged(itemList: Dictionary[Item, int])

signal CloseToInteractable
signal FarFromInteractable
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
signal ItemRetrieved
signal CloseToShip
signal MissionStatusChanged(status_info: String)
signal MissionCompleted
signal RestartGame

signal BallistaModeEnter(which: Node3D)
signal BallistaModeExit

signal PauseGameDebug


signal WorldEvent
