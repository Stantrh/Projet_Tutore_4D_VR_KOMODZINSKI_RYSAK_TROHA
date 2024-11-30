extends CanvasLayer



@onready var shop_item_scene : PackedScene = preload("res://Scenes/Player/GUI/shop_item.tscn")
var current_item: ItemData


func _ready():
	for i in Game.items:
		var shop_item_temp = shop_item_scene.instantiate()
		shop_item_temp.item_info = Game.items[i]
		shop_item_temp.get_node("image").texture = Game.items[i].item_texture
		get_node("shop_items").add_child(shop_item_temp)
	$item_info.hide()


func _on_close_button_pressed():
	get_tree().paused = false
	Game.shopping = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.hide()


func _on_buy_button_pressed():
	get_node("../container/inventory").add_item(str(current_item.item_name))
