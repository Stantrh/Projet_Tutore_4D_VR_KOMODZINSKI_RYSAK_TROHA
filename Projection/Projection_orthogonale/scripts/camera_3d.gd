extends Camera3D

@export var speed : float = 10.0  # Vitesse de déplacement
@export var mouse_sensitivity : float = 0.1  # Sensibilité de la souris

var rotation_x : float = 0
var rotation_y : float = 0

func _ready():
	# Désactiver le curseur de la souris pour qu'il puisse se déplacer librement
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Déplacement de la caméra
	var move_direction = Vector3.ZERO

	# Utiliser les touches pour déplacer la caméra
	if Input.is_action_pressed("ui_up"):
		move_direction.z -= 1
	elif Input.is_action_pressed("ui_down"):
		move_direction.z += 1
	if Input.is_action_pressed("ui_left"):
		move_direction.x -= 1
	elif Input.is_action_pressed("ui_right"):
		move_direction.x += 1
	
	# Appliquer la vitesse de déplacement
	move_direction = move_direction.normalized() * speed * delta
	
	# Déplacer la caméra
	translate(move_direction)
