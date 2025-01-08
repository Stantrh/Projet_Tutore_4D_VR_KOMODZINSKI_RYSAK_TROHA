extends Camera3D

# Variables pour configurer la rotation
@export var rotation_speed : float = 1.0  # Vitesse de rotation en degrés par seconde
@export var radius : float = 10.0         # Distance au centre (0, 0, 0)
@export var height : float = 2.0          # Hauteur de la caméra par rapport au centre

# Variable interne pour suivre l'angle actuel (en radians)
var angle : float = 0.0

func _ready():
	# Position initiale de la caméra
	update_camera_position()

func _process(delta):
	# Augmente l'angle en fonction du temps écoulé et de la vitesse
	angle += deg_to_rad(rotation_speed) * delta
	# Limite l'angle pour éviter qu'il ne devienne trop grand
	angle = wrapf(angle, 0, TAU)
	# Met à jour la position de la caméra
	update_camera_position()

func update_camera_position():
	# Calcule les nouvelles coordonnées en fonction de l'angle
	var x = radius * cos(angle)
	var z = radius * sin(angle)
	# Met à jour la position de la caméra
	global_transform.origin = Vector3(x, height, z)
	# Oriente la caméra vers le centre (0, 0, 0)
	look_at(Vector3(0, 0, 0), Vector3.UP)
