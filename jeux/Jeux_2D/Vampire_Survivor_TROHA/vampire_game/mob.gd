extends CharacterBody2D

var health = 3

# on crée déjà une variable pour stocker la position du joueur afin de le suivre
@onready var player = get_node("/root/Game/Player")


func _ready() -> void:
	%Slime.play_walk()


func _physics_process(delta):
	# on calcule donc la direction de mouvement que le mob doit emprunter pour aller vers le joueur
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 200.0 # on met une valeur inférieure à celle du joueur
	move_and_slide()

func take_damage():
	health -= 1
	%Slime.play_hurt()
	if(health == 0):
		queue_free()
		
		const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_SCENE.instantiate()
		# maintenant, pour afficher l'explosion, on doit l'ajouter à la scène
		# on peut pas l'ajouter au mob, car le noeud mob est détruit puisqu'il meurt
		# donc on l'ajoute au parent du mob
		get_parent().add_child(smoke)
		smoke.global_position = global_position
