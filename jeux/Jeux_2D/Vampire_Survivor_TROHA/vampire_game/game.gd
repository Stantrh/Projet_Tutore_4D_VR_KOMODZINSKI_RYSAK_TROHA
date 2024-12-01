extends Node2D



# on va faire en sorte que les mobs spawn aléatoirement en utilisant
# le path2D qu'on a créé ainsi que le pathfollow, qui permet de suivre ce path2D

func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	# maintenant, on génère une position random sur le path
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	# puis on ajoute à la scène les mobs
	add_child(new_mob)
	


func _on_timer_timeout() -> void:
	spawn_mob()


func _on_player_health_depleted() -> void:
	# on affiche le game over quand le joueur est mort
	%GameOver.visible = true
	get_tree().paused = true
