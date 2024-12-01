extends Area2D

func _physics_process(delta):
	# on va trouver toutes les entités qui sont dans la zone du gun (le cercle) 
	var ennemies_in_range = get_overlapping_bodies()
	if ennemies_in_range.size() > 0:
		# on cherche l'ennemi à target, le 1er a entrer dans la zone
		var target_ennemy = ennemies_in_range[0]
		# et maintenant on appelle une fonction qui existe dans les Area2D
		look_at(target_ennemy.global_position)

func shoot():
	# on récupère la reference du noeud bullet
	const BULLET = preload("res://bullet.tscn")
	# et en utilisant cette réféfence, on crée un objet
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_bullet)
	
	# et pour que les attaques soient automatiques, on veut utiliser un autre type de noeud, TIMER


func _on_timer_timeout() -> void:
	shoot()
