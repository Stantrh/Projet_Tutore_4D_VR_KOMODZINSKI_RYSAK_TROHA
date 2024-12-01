extends Area3D



func _on_body_entered(body):
	if body.is_in_group("player"):
		Game.shopping = true
		get_tree().paused = true
		get_node("../GUI/shop").show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func _on_animation_player_animation_finished(anim_name):
	$Mage/AnimationPlayer.play("Idle")