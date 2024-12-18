extends Node3D

# Sensibilité de la souris
var mouse_sensitivity: Vector2 = Vector2(0.2, 0.2)
# Vitesse de déplacement
var move_speed: float = 5.0
# Limite de rotation verticale
var vertical_limit: float = 89.0

# Variables pour stocker l'angle de rotation
var yaw: float = 0.0  # Rotation horizontale (gauche/droite)
var pitch: float = 0.0  # Rotation verticale (haut/bas)

func _ready():
	# Verrouille la souris pour une meilleure interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Gestion des mouvements de la souris
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity.x
		pitch -= event.relative.y * mouse_sensitivity.y
		pitch = clamp(pitch, -vertical_limit, vertical_limit)
		rotation_degrees = Vector3(pitch, yaw, 0)

func _process(delta):
	# Gestion des déplacements avec les touches
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	# Normaliser la direction et appliquer le mouvement
	direction = direction.normalized()
	position += direction * move_speed * delta
