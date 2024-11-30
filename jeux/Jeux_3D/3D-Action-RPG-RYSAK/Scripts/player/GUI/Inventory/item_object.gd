extends Area3D

var rng : int

func _ready():
	var tween = create_tween()
	var rng_position = Vector3(randi_range(-1,1),1,randi_range(-1,1))
	tween.tween_property(self,"position",position+rng_position,0.5)
	rng = randi_range(0,2)
	$"1H_Sword".hide()
	$Knight_Body.hide()
	$mug_full.hide()
	match rng :
		0: $"1H_Sword".show()
		1: $mug_full.show()
		2: $Knight_Body.show()
		

func _on_body_entered(body):
	if body.is_in_group("player"):
		match rng:
			0: get_node("../../GUI/container/inventory").add_item("long sword")
			1: get_node("../../GUI/container/inventory").add_item("small potion")
			2: get_node("../../GUI/container/inventory").add_item("iron body")
		self.hide()
		$pickup.play()


func _on_pickup_finished():
	self.queue_free()
