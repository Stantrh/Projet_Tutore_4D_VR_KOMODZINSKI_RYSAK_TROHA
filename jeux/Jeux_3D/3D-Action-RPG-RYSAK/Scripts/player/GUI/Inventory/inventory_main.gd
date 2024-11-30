extends Node


@export var inventory_size := 24
@onready var grid : GridContainer = $GridContainer

func _ready():
	for i in range(inventory_size):
		var slot = InventorySlot.new()
		slot.init(ItemData.Type.MAIN, Vector2(32,32))
		grid.add_child(slot)
	add_item("long sword")
	add_item("small potion")
	add_item("iron body")

func add_item(item_name : String)-> void :
	var item = InventoryItem.new()
	item.init(Game.items[item_name])
	if item.data.stackable : 
		var find : bool = false
		for i in inventory_size : 
			if grid.get_child(i).get_child_count() > 0:
				if grid.get_child(i).get_child(0).data == item.data:
					#update the counter
					grid.get_child(i).get_child(0).data.count += 1 
					#update the label counter
					grid.get_child(i).get_child(0).get_child(0).text = str(grid.get_child(i).get_child(0).data.count)
					find = true
					break
		if !find : 
			for i in inventory_size : 
				if grid.get_child(i).get_child_count()==0:
					grid.get_child(i).add_child(item)
					break;
	else : 			
		for i in inventory_size : 
			if grid.get_child(i).get_child_count()==0:
				grid.get_child(i).add_child(item)
				break;
