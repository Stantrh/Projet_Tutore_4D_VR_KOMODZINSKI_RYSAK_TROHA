extends Node3D

var ui1: bool = false
var ui2: bool = false
var ui3 : bool = false
var interface : XRInterface
@onready var UI = $XROrigin3D/LeftTrackedHand/Area3D/CanvasLayerViewport4/Viewport/UI_arm
@onready var target_area = $XROrigin3D/LeftTrackedHand/Area3D # Area3D cible
@onready var raycast =  $XROrigin3D/XRCamera3D/RayCast3D    # RayCast3D

var is_inside_area = false  # Suivi de l'état d'entrée/sortie

# Called when the node enters the scene tree for the first time.
func _ready():
	WorldInfo.camera = $XROrigin3D/XRCamera3D
	raycast.enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if raycast.is_colliding():
		print(raycast.get_collider())
		var collider = raycast.get_collider()		
		# Vérifie si le RayCast3D est entré dans l'Area3D cible
		if collider == target_area and not is_inside_area:
			is_inside_area = true
			on_ray_enter()

	# Vérifie si le RayCast3D a cessé de détecter l'Area3D
	elif is_inside_area:
		is_inside_area = false
		on_ray_exit()

func on_ray_enter():
	print("Enter")
	UI.show_interface()
	$XROrigin3D/LeftTrackedHand/Area3D/CanvasLayerViewport4.show()
func on_ray_exit():
	print("Exit")
	UI.hide_interface()
	$XROrigin3D/LeftTrackedHand/Area3D/CanvasLayerViewport4.hide()
func _on_area_3d_body_entered(body):
	if body.is_in_group("player_body"):
		UI.open_interface($HypercubeSS.child_instantied)

func _on_hypercube_os_area_body_entered(body):
	if body.is_in_group("player_body"):
		UI.open_interface($HypercubeOS.child_instantied)


func _on_hypercube_pf_area_body_entered(body):
	if body.is_in_group("player_body"):
		UI.open_interface($HypercubePF.child_instantied)


func _on_area_3d_body_exited(body):
	if body.is_in_group("player_body"):
		UI.close()


func _on_hypercube_os_area_body_exited(body):
	if body.is_in_group("player_body"):
		UI.close()



func _on_hypercube_pf_area_body_exited(body):
	if body.is_in_group("player_body"):
		UI.close()
