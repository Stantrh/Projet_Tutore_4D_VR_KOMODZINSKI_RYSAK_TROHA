extends CharacterBody2D

var health: float = 100

# signal qu'on envoie si le perso a 0hp
signal health_depleted

# fonction qui est appelée quand le jeu a besoin de calculer n'importe quelle physique
func _physics_process(delta):
	# on calcule les directions de mouvements
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# l'attribut velocity permet de donner à la fois la vitesse du joueur et sa direction sous forme de Vecteur2
	velocity = direction * 600
	# pour faire se déplacer le perso, 
	move_and_slide()
	
	# maintenant on doit afficher l'animation du personnage
	# donc on récupère le noeud enfant
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()
	
	
	# on récupère les mobs qui sont dans la zone de la hurtbox du personnage 
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	const DAMAGE_RATE = 5.0
	if overlapping_mobs.size() > 0:
		health -= overlapping_mobs.size() * DAMAGE_RATE * delta
		%ProgressBar.value = health
		if health <= 0.0:
			# si le perso est mort, on emet un signal pour dire qu'il est mort
			health_depleted.emit()
