extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 12

var xform: Transform3D


func _physics_process(delta: float) -> void:
	
	# pour rotate la cam à droite et gauche avec a et d
	if Input.is_action_just_pressed("cam_left"):
		$Camera_Controller.rotate_y(deg_to_rad(-30))
	elif Input.is_action_just_pressed("cam_right"):
		$Camera_Controller.rotate_y(deg_to_rad(30))
		
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# new Vector3 direction, taking into account the user arrow input as well as the camera rotation
	var direction = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# et on doit aussi rotate la face du perso, donc le mechinstance3D appelé "face", pour qu'il soit toujours devant
	if input_dir != Vector2(0, 0): # donc si ça presse quelque chose, car 0,0 veut dire qu'il bouge pas
		$MeshInstance3D.rotation_degrees.y = $Camera_Controller.rotation_degrees.y - rad_to_deg(input_dir.angle()) - 90
		
	# ici on gère l'alignement entre le perso et le sol, pour les pentes
	if is_on_floor():
		align_with_floor($RayCast3D.get_collision_normal())
		# pour éviter que quand on fait la transformation par rapport au sol
		# cela soit fluide, pas que ce soit d'un coup et que ça se voit
		global_transform = global_transform.interpolate_with(xform, 0.2)
	elif not is_on_floor():
		align_with_floor(Vector3.UP)
		global_transform = global_transform.interpolate_with(xform, 0.3)
		
		
	# met à jour la velocité et déplace le caractère en z et x (cotés et avant arrière)	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# On fait en sorte que la caméra suive la position du personnage
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.12)
	
# on aligne le personnage au sol en utilisant raycast3D	
func align_with_floor(floor_normal):
	xform = global_transform
	# on fait en sorte que la direction y du joueur soit la meme que celle du sol
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	# SAUF QUE, ça va décaler l'axe y, mais il faut qu'on orthonormalise, pour toujours faire en sorte
	# que les 3 axes restent perpendiculaires entre eux, sinon le perso est bizarre
	xform.basis = xform.basis.orthonormalized()

	


func _on_fall_zone_body_entered(body: Node3D) -> void:
	# lorsqu'il saute de la map et tombe dans le vide, pour le reset sur la map
	# c'est à dire un changement de scène en fin de compte
	# get_tree() retourne l'arbre du projet entier, à partir de Level1
	get_tree().change_scene_to_file("res://level_1.tscn")
	
