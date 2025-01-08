extends Control

@export var object_controlled : Node
@onready var translation_sliders : Array = [$ReferenceRect/ColorRect/Translation/HBoxContainer/translation_x_slider,$ReferenceRect/ColorRect/Translation/HBoxContainer2/translation_y_slider,$ReferenceRect/ColorRect/Translation/HBoxContainer3/translation_z_slider,$ReferenceRect/ColorRect/Translation/HBoxContainer4/translation_w_slider]
@onready var rotation_sliders : Array = [
	$ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer/HBoxContainer5/HBoxContainer/xy_rotation_slider,
	$ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer/HBoxContainer6/HBoxContainer2/xz_rotation_slider,
	$ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer/HBoxContainer7/HBoxContainer3/yz_rotation_slider,
	$ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer2/HBoxContainer5/HBoxContainer4/xw_rotation_slider,
	$ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer2/HBoxContainer6/HBoxContainer5/yw_rotation_slider,
	$ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer2/HBoxContainer7/HBoxContainer6/zw_rotation_slider
]

# Pour les sliders, on garde les positions des sliders précédents dans un dictionnaire qu'on actualise
var prev_translation_pos = {} # translations
var prev_rotation_pos = {} # rotations
var rotation_buttons = {} # tableau des boutons de l'interface pour modifier leur état

# boutons à toggle pour les rotations
var xy_rotation_button
var xz_rotation_button
var yz_rotation_button
var xw_rotation_button
var yw_rotation_button
var zw_rotation_button


# Called when the node enters the scene tree for the first time.
func _ready():
	# On associe aux boutons d'activation de rotation leur noeud
	xy_rotation_button = $ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer/HBoxContainer5/HBoxContainer/xy_rotation_button
	xz_rotation_button = $ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer/HBoxContainer6/HBoxContainer2/xz_rotation_button
	yz_rotation_button = $ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer/HBoxContainer7/HBoxContainer3/yz_rotation_button
	xw_rotation_button = $ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer2/HBoxContainer5/HBoxContainer4/xw_rotation_button
	yw_rotation_button = $ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer2/HBoxContainer6/HBoxContainer5/yw_rotation_button
	zw_rotation_button = $ReferenceRect/ColorRect/Rotation/HBoxContainer/VBoxContainer2/HBoxContainer7/HBoxContainer6/zw_rotation_button
	# puis on ajoute au listener pour que la méthode en charge des toggle puisse détecter quel bouton a décleché son appel
	xy_rotation_button.connect("toggled", Callable(self, "_on_check_button_toggled").bind("XY"))
	xz_rotation_button.connect("toggled", Callable(self, "_on_check_button_toggled").bind("XZ"))
	yz_rotation_button.connect("toggled", Callable(self, "_on_check_button_toggled").bind("YZ"))
	xw_rotation_button.connect("toggled", Callable(self, "_on_check_button_toggled").bind("XW"))
	yw_rotation_button.connect("toggled", Callable(self, "_on_check_button_toggled").bind("YW"))
	zw_rotation_button.connect("toggled", Callable(self, "_on_check_button_toggled").bind("ZW"))
	
	# pour avoir accès aux boutons et changer leur état
	rotation_buttons["XY"] = xy_rotation_button
	rotation_buttons["XZ"] = xz_rotation_button
	rotation_buttons["YZ"] = yz_rotation_button
	rotation_buttons["XW"] = xw_rotation_button
	rotation_buttons["YW"] = yw_rotation_button
	rotation_buttons["ZW"] = zw_rotation_button


func _on_check_button_toggled(button_pressed: bool, axis_pair: String):
	# au cas où c'est la première fois qu'on souhaite transformer la forme courante
	if not object_controlled in prev_rotation_pos:
		prev_rotation_pos[object_controlled] = {
			"XY": {"toggled": false, "disabled": false},
			"XZ": {"toggled": false, "disabled": false},
			"YZ": {"toggled": false, "disabled": false},
			"XW": {"toggled": false, "disabled": false},
			"YW": {"toggled": false, "disabled": false},
			"ZW": {"toggled": false, "disabled": false}
		}
		
	# on met à jour la valeur toggled du plan choisi
	prev_rotation_pos[object_controlled][axis_pair]["toggled"] = button_pressed
	
	# On vérifie combien de plans sont activés pour la rotation
	var active_rotations = []
	for plan in prev_rotation_pos[object_controlled]:
		if prev_rotation_pos[object_controlled][plan]["toggled"]: # si plan a true, donc actif
			active_rotations.append(plan)
			
	# si on est dans le cas d'une activation, on doit vérifier le nombre total de boutons enabled pour désactiver les autres
	if button_pressed:
		print("TAB ACTIVATION : " + str(active_rotations))
		# si on en a 2, on désactive la possibilité d'en choisir + 
		if active_rotations.size() == 2:
			for plan in prev_rotation_pos[object_controlled]:
				if plan not in active_rotations:
					rotation_buttons[plan].disabled = true
					prev_rotation_pos[object_controlled][plan]["disabled"] = true
			
			# donc si 2 rotations sont activées, alors on enable la double rotation
			object_controlled.is_double_rotate = true
			object_controlled.set_rotate_plan(axis_pair, false) # et on passe l'axe
			# et on reporte les axes concernés par la rotation
		elif active_rotations.size() == 1:
			object_controlled.is_rotate = true
			object_controlled.set_rotate_plan(axis_pair, true)
	else: # si on est sur une désactivation
		print("TAB DESACTIVATION: " + str(active_rotations))
		if active_rotations.size() <= 1:
			for plan in prev_rotation_pos[object_controlled]:
				if plan not in active_rotations:
					rotation_buttons[plan].disabled = false
					prev_rotation_pos[object_controlled][plan]["disabled"] = false
			# et si on est à 1, on vérifie que la double rotation est bien désactivée
			if active_rotations.size() == 1:
				object_controlled.is_double_rotate = false
			elif active_rotations.size() == 0:
				object_controlled.is_rotate = false
				
		
	




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_translation_x_slider_value_changed(value):
	if object_controlled != null:
		
		print("X : " + str(value))
		
		if not prev_translation_pos.has(object_controlled): # si c'est la première fois qu'on touche à cette hypercube
			prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
		# on récupère le tableau dans tous les cas, soit 0.0 si on vient de l'initialiser, soit les précédentes valeurs
		var prev_translation_pos_slider = prev_translation_pos[object_controlled]
		
		var delta_x = value - prev_translation_pos_slider[0] # le delta, pour savoir si on avance ou recule, en haut ou en bas, etc.
		prev_translation_pos_slider[0] = value 
		
		object_controlled.vect_translate = Vector4(delta_x, 0, 0, 0)
		object_controlled.is_translate = true


func _on_translation_y_slider_value_changed(value):
	if object_controlled != null:
		
		print("Y : " + str(value))
		if not prev_translation_pos.has(object_controlled): # si c'est la première fois qu'on touche à cette hypercube
			prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
		# on récupère le tableau dans tous les cas, soit 0.0 si on vient de l'initialiser, soit les précédentes valeurs
		var prev_translation_pos_slider = prev_translation_pos[object_controlled]
		
		var delta_y = value - prev_translation_pos_slider[1] # le delta, pour savoir si on avance ou recule, en haut ou en bas, etc.
		prev_translation_pos_slider[1] = value 
		
		object_controlled.vect_translate = Vector4(0, delta_y, 0, 0)
		object_controlled.is_translate = true


func _on_translation_z_slider_value_changed(value):
	if object_controlled != null:
		print("Z : " + str(value))
		if not prev_translation_pos.has(object_controlled): # si c'est la première fois qu'on touche à cette hypercube
			prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
		# on récupère le tableau dans tous les cas, soit 0.0 si on vient de l'initialiser, soit les précédentes valeurs
		var prev_translation_pos_slider = prev_translation_pos[object_controlled]
		
		var delta_z = value - prev_translation_pos_slider[2] # le delta, pour savoir si on avance ou recule, en haut ou en bas, etc.
		prev_translation_pos_slider[2] = value 
		
		object_controlled.vect_translate = Vector4(0, 0, delta_z, 0)
		object_controlled.is_translate = true

func _on_translation_w_slider_value_changed(value):
	if object_controlled != null:
		print("W : " + str(value))
		if not prev_translation_pos.has(object_controlled): # si c'est la première fois qu'on touche à cette hypercube
			prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
		# on récupère le tableau dans tous les cas, soit 0.0 si on vient de l'initialiser, soit les précédentes valeurs
		var prev_translation_pos_slider = prev_translation_pos[object_controlled]

		var delta_w = value - prev_translation_pos_slider[3] # le delta, pour savoir si on avance ou recule, en haut ou en bas, etc.
		prev_translation_pos_slider[3] = value 
		
		object_controlled.vect_translate = Vector4(0, 0, 0, delta_w)
		object_controlled.is_translate = true

	
	
func open_interface(object):
	# pour garder les emplacements des sliders selon l'hypercube
	if prev_translation_pos.has(object):
		var slider_pos_array = prev_translation_pos[object]
		var indice = 0
		for translation_slider in translation_sliders:
			translation_slider.value = slider_pos_array[indice]
			indice += 1
	else:
		#print("HEYYYY C'EST DU 0. Vide ? : " + str(prev_translation_pos.size()))
		for translation_slider in translation_sliders:
			translation_slider.value = 0
	
	if prev_rotation_pos.has(object):
		var button_pos_dict = prev_rotation_pos[object] # on récupère le dictionnaire de l'hypercube courant
		for key in rotation_buttons:
			rotation_buttons[key].button_pressed = button_pos_dict[key]["toggled"]
			rotation_buttons[key].disabled = button_pos_dict[key]["disabled"]
	else: 
		for key in rotation_buttons:
			rotation_buttons[key].button_pressed = false
			rotation_buttons[key].disabled = false
			
	
	visible = true
	object_controlled = object
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	
func _on_close_button_pressed():
	object_controlled = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
