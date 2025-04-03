extends Node3D

var ui1: bool = false
var ui2: bool = false
var ui3 : bool = false
var interface : XRInterface
@onready var UI = null
#@onready var target_area = $XROrigin3D/LeftTrackedHand/Area3D # Area3D cible
#@onready var raycast =  $XROrigin3D/XRCamera3D/RayCast3D    # RayCast3D

var is_inside_area = false  # Suivi de l'état d'entrée/sortie

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	WorldInfo.camera = $CharacterView/Camera3D
	#raycast.enabled = true
	$hypersphere_ile/HypersphereSS.desactive()
	$hypersphere_ile/HypersphereOS.desactive()
	$hypersphere_ile/HyperspherePF.desactive()
	$duoprism_ile/DuoprismSS.desactive()
	$duoprism_ile/DuoprismOS.desactive()
	$duoprism_ile/DuoprismPF.desactive()

func teleport_to_hypercube():
	$XROrigin3D.global_position = $hypercube_ile.global_position
	activate_hypercubes()
	desactive_duoprism()
	desactive_hypersphere()
func teleport_to_hypersphere():
	$XROrigin3D.global_position = $hypersphere_ile/hypersphere_ile.global_position
	desactive_duoprism()
	deactivate_hypercubes()
	activate_hypersphere()
func teleport_to_duoprism():
	$XROrigin3D.global_position = $duoprism_ile/duoprism_ile.global_position
	activate_duoprism()
	desactive_hypersphere()
	deactivate_hypercubes()	

func activate_hypercubes():
	$HypercubeSS.activate()
	$HypercubeOS.activate()
	$HypercubePF.activate()
func deactivate_hypercubes():
	$HypercubeSS.desactive()
	$HypercubeOS.desactive()
	$HypercubePF.desactive()	
func desactive_hypersphere():
	$hypersphere_ile/HypersphereSS.desactive()
	$hypersphere_ile/HypersphereOS.desactive()
	$hypersphere_ile/HyperspherePF.desactive()
func desactive_duoprism():
	$duoprism_ile/DuoprismSS.desactive()
	$duoprism_ile/DuoprismOS.desactive()
	$duoprism_ile/DuoprismPF.desactive()
func activate_hypersphere():
	$hypersphere_ile/HypersphereSS.activate()
	$hypersphere_ile/HypersphereOS.activate()
	$hypersphere_ile/HyperspherePF.activate()	
func activate_duoprism():
	$duoprism_ile/DuoprismSS.activate()
	$duoprism_ile/DuoprismOS.activate()
	$duoprism_ile/DuoprismPF.activate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if raycast.is_colliding():
		#print(raycast.get_collider())
		#var collider = raycast.get_collider()		
		## Vérifie si le RayCast3D est entré dans l'Area3D cible
		#if collider == target_area and not is_inside_area:
			#is_inside_area = true
			#on_ray_enter()
#
	## Vérifie si le RayCast3D a cessé de détecter l'Area3D
	#elif is_inside_area:
		#is_inside_area = false
		#on_ray_exit()

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


func _on_hypersphere_ss_body_entered(body):
	if body.is_in_group("player_body"):
		UI.open_interface($hypersphere_ile/HypersphereSS.child_instantied)


func _on_hypersphere_os_area_body_entered(body):
	if body.is_in_group("player_body"):
		UI.open_interface($hypersphere_ile/HypersphereOS.child_instantied)


func _on_hypersphere_pf_area_body_entered(body):
	if body.is_in_group("player_body"):
		UI.open_interface($hypersphere_ile/HyperspherePF.child_instantied)


func _on_hypersphere_pf_area_body_exited(body):
	if body.is_in_group("player_body"):
		UI.close()

func _on_hypersphere_os_area_body_exited(body):
	if body.is_in_group("player_body"):
		UI.close()

func _on_hypersphere_ss_body_exited(body):
	if body.is_in_group("player_body"):
		UI.close()




func _on_duoprism_os_area_body_entered(body):
	if body.is_in_group("player_body"):
		UI.open_interface($duoprism_ile/DuoprismOS.child_instantied)



func _on_duoprism_os_area_body_exited(body):
	if body.is_in_group("player_body"):
		UI.close()

func _on_duoprism_ss_area_body_entered(body):
	if body.is_in_group("player_body"):
		UI.open_interface($duoprism_ile/DuoprismSS.child_instantied)



func _on_duoprism_pf_area_body_entered(body):
	if body.is_in_group("player_body"):
		UI.open_interface($duoprism_ile/DuoprismPF.child_instantied)



func _on_duoprism_pf_area_body_exited(body):
	if body.is_in_group("player_body"):
		UI.close()


func _on_duoprism_ss_area_body_exited(body):
	if body.is_in_group("player_body"):
		UI.close()


func _on_button_panel_hypercube_pressed():
	teleport_to_hypercube()
func _on_button_panel_hyphersphere_pressed():
	teleport_to_hypersphere()
func _on_button_panel_triduoprism_pressed():
	teleport_to_duoprism()
