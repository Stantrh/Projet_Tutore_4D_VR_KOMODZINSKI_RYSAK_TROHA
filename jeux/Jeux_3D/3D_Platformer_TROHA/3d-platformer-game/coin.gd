extends Area3D

const ROT_SPEED = 2 # degrés le coin va rotate par frame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROT_SPEED))
	
	# on va vérifier si le joueur touche la pièce, si c'est le cas, on la supprime
	# on utilise un signal plutot que overlapping_bodies pour éviter le délai
	#if has_overlapping_bodies():
		#queue_free()


func _on_body_entered(body: Node3D) -> void:
	# on incrémente le compteur de coins de 1
	Global.coins += 1
	# on change de scène si on atteint le nb max de pièces à collecter
	if Global.coins >= Global.MAX_COINS:
		get_tree().change_scene_to_file("res://level_1.tscn")
		
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	$AnimationPlayer.play("bounce")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
