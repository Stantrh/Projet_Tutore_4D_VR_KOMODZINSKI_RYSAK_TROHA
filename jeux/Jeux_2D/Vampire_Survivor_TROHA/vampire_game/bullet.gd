extends Area2D

# on crée une variable pour que la balle se détruise au bout d'un moment 
var travelled_distance = 0

func _physics_process(delta):
	const SPEED = 1000.0
	const RANGE = 1200.0
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta # 1000 pixels par seconde

	travelled_distance += SPEED * delta
	
	# si la balle a parcouru + que 1200, alors on la supprime
	if travelled_distance > RANGE:
		queue_free()

# fct pour lorsque la balle hit un mob
func _on_body_entered(body: Node2D) -> void:
	queue_free() # déjà, on supprime la balle
	if body.has_method("take_damage"): # on vérifie que le corps qu'on hit possède une méthode pour encaisser les degats
		body.take_damage()
