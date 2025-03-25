extends Control

@export var object_controlled : Node
@onready var translation_sliders : Array[HSlider] = [$ReferenceRect/ColorRect/Translation/HBoxContainer/HBoxContainer/translation_x_slider,
$ReferenceRect/ColorRect/Translation/HBoxContainer2/HBoxContainer/translation_y_slider,
$ReferenceRect/ColorRect/Translation/HBoxContainer3/HBoxContainer/translation_z_slider,
$ReferenceRect/ColorRect/Translation/HBoxContainer4/HBoxContainer/translation_w_slider]
@onready var sliders_label : Array[Label] = [
	$ReferenceRect/ColorRect/Translation/HBoxContainer/HBoxContainer/Panel/Label,
	$ReferenceRect/ColorRect/Translation/HBoxContainer2/HBoxContainer/Panel/Label,
	$ReferenceRect/ColorRect/Translation/HBoxContainer3/HBoxContainer/Panel/Label,
	$ReferenceRect/ColorRect/Translation/HBoxContainer4/HBoxContainer/Panel/Label
]
@onready var dimension_check_box : OptionButton = $ReferenceRect/ColorRect/Fez/OptionButton
# Pour les sliders, on garde les positions des sliders précédents dans un dictionnaire qu'on actualise
var prev_translation_pos = {} # translations
var prev_rotation_pos = {} # rotations
var rotation_buttons = {} # tableau des boutons de l'interface pour modifier leur état

var dimensions = [
]



# boutons à toggle pour les rotations
var xy_rotation_button
var xz_rotation_button
var yz_rotation_button
var xw_rotation_button
var yw_rotation_button
var zw_rotation_button

var x_translation_reset_button : TextureButton
var y_translation_reset_button : TextureButton
var z_translation_reset_button : TextureButton
var w_translation_reset_button : TextureButton
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
	
	# On associe aux boutons de réinitialisation de la translation leurs noeuds 
	x_translation_reset_button = $ReferenceRect/ColorRect/Translation/HBoxContainer/HBoxContainer/x_translation_reset
	y_translation_reset_button = $ReferenceRect/ColorRect/Translation/HBoxContainer2/HBoxContainer/y_translation_reset
	z_translation_reset_button = $ReferenceRect/ColorRect/Translation/HBoxContainer3/HBoxContainer/z_translation_reset
	w_translation_reset_button = $ReferenceRect/ColorRect/Translation/HBoxContainer4/HBoxContainer/w_translation_reset
	
	x_translation_reset_button.connect("pressed", Callable(self,"_on_translation_reset_button_pressed").bind(0))
	y_translation_reset_button.connect("pressed", Callable(self,"_on_translation_reset_button_pressed").bind(1))
	z_translation_reset_button.connect("pressed", Callable(self,"_on_translation_reset_button_pressed").bind(2))
	w_translation_reset_button.connect("pressed", Callable(self,"_on_translation_reset_button_pressed").bind(3))
	#dimensions = object_controlled.accesible_dimensions
	for i in range(dimensions.size()):
		dimension_check_box.add_item(dimensions[i],i)
	dimension_check_box.selected = 0
func _on_check_button_toggled(button_pressed: bool, axis_pair: String):
	if object_controlled:
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
			# si on en a 2, on désactive la possibilité d'en choisir + 
			if active_rotations.size() == 2:
				for plan in prev_rotation_pos[object_controlled]:
					if plan not in active_rotations:
						rotation_buttons[plan].disabled = true
						prev_rotation_pos[object_controlled][plan]["disabled"] = true
				
				# donc si 2 rotations sont activées, alors on enable la double rotation
				object_controlled.is_double_rotate = true
				object_controlled.set_rotate_plan(axis_pair, false) # et on passe l'axe
				var axe_a = object_controlled.axe_a
				var axe_b = object_controlled.axe_b
				var axe2_a = object_controlled.axe2_a
				var axe2_b = object_controlled.axe2_b
				#print("axe_a : " + str(axe_a))
				#print("axe_b : " + str(axe_b))
				#print("axe2_a : " + str(axe2_a))
				#print("axe2_b : " + str(axe2_b))
				# et on reporte les axes concernés par la rotation
			elif active_rotations.size() == 1:
				object_controlled.is_rotate = true
				object_controlled.set_rotate_plan(axis_pair, true)
		else: # si on est sur une désactivation
			if active_rotations.size() <= 1:
				for plan in prev_rotation_pos[object_controlled]:
					if plan not in active_rotations:
						rotation_buttons[plan].disabled = false
						prev_rotation_pos[object_controlled][plan]["disabled"] = false
				# et si on est à 1, on vérifie que la double rotation est bien désactivée
				if active_rotations.size() == 1:
					object_controlled.is_double_rotate = false
					# et on reporte le plan de rotation actif sur le premier plan de rotation 
					object_controlled.set_rotate_plan(active_rotations[0], true)

					
					var axe_a = object_controlled.axe_a
					var axe_b = object_controlled.axe_b
					var axe2_a = object_controlled.axe2_a
					var axe2_b = object_controlled.axe2_b
					print("POUR : " + str(axis_pair))
					print("axe_a : " + str(axe_a))
					print("axe_b : " + str(axe_b))
					print("axe2_a : " + str(axe2_a))
					print("axe2_b : " + str(axe2_b))
				elif active_rotations.size() == 0:
					object_controlled.stop_rotation()
				
	




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_translation_x_slider_value_changed(value):
	if object_controlled != null:
		
		if not prev_translation_pos.has(object_controlled): # si c'est la première fois qu'on touche à cette hypercube
			prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
		# on récupère le tableau dans tous les cas, soit 0.0 si on vient de l'initialiser, soit les précédentes valeurs
		var prev_translation_pos_slider = prev_translation_pos[object_controlled]
		
		var delta_x = value - prev_translation_pos_slider[0] # le delta, pour savoir si on avance ou recule, en haut ou en bas, etc.
		prev_translation_pos_slider[0] = value 
		object_controlled.is_up_to_date = false
		object_controlled.vect_translate = Vector4(delta_x, 0, 0, 0)
		object_controlled.is_translate = true
		object_controlled.is_up_to_date = true
		sliders_label[0].text = str(value)


func _on_translation_y_slider_value_changed(value):
	if object_controlled != null:
		
		print("Y : " + str(value))
		if not prev_translation_pos.has(object_controlled): # si c'est la première fois qu'on touche à cette hypercube
			prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
		# on récupère le tableau dans tous les cas, soit 0.0 si on vient de l'initialiser, soit les précédentes valeurs
		var prev_translation_pos_slider = prev_translation_pos[object_controlled]
		
		var delta_y = value - prev_translation_pos_slider[1] # le delta, pour savoir si on avance ou recule, en haut ou en bas, etc.
		prev_translation_pos_slider[1] = value 
		object_controlled.is_up_to_date = false
		object_controlled.vect_translate = Vector4(0, delta_y, 0, 0)
		object_controlled.is_translate = true
		object_controlled.is_up_to_date = true
		sliders_label[1].text = str(value)

func _on_translation_z_slider_value_changed(value):
	if object_controlled != null:
		print("Z : " + str(value))
		if not prev_translation_pos.has(object_controlled): # si c'est la première fois qu'on touche à cette hypercube
			prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
		# on récupère le tableau dans tous les cas, soit 0.0 si on vient de l'initialiser, soit les précédentes valeurs
		var prev_translation_pos_slider = prev_translation_pos[object_controlled]
		
		var delta_z = value - prev_translation_pos_slider[2] # le delta, pour savoir si on avance ou recule, en haut ou en bas, etc.
		prev_translation_pos_slider[2] = value 
		object_controlled.is_up_to_date = false
		object_controlled.vect_translate = Vector4(0, 0, delta_z, 0)
		object_controlled.is_translate = true
		object_controlled.is_up_to_date = true
		sliders_label[2].text = str(value)
func _on_translation_w_slider_value_changed(value):
	if object_controlled != null:
		print("W : " + str(value))
		if not prev_translation_pos.has(object_controlled): # si c'est la première fois qu'on touche à cette hypercube
			prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
		# on récupère le tableau dans tous les cas, soit 0.0 si on vient de l'initialiser, soit les précédentes valeurs
		var prev_translation_pos_slider = prev_translation_pos[object_controlled]

		var delta_w = value - prev_translation_pos_slider[3] # le delta, pour savoir si on avance ou recule, en haut ou en bas, etc.
		prev_translation_pos_slider[3] = value 
		object_controlled.is_up_to_date = false
		object_controlled.vect_translate = Vector4(0, 0, 0, delta_w)
		object_controlled.is_translate = true
		object_controlled.is_up_to_date = true
		sliders_label[3].text = str(value)
	
	
func open_interface(object):
	print("SUIIIII")
	# pour garder les emplacements des sliders selon l'hypercube
	if prev_translation_pos.has(object):
		var slider_pos_array = prev_translation_pos[object]
		var indice = 0
		for translation_slider in translation_sliders:
			translation_slider.value = slider_pos_array[indice]
			sliders_label[indice].text = str(slider_pos_array[indice])
			indice += 1
	else:
		#print("HEYYYY C'EST DU 0. Vide ? : " + str(prev_translation_pos.size()))
		for translation_slider in translation_sliders:
			translation_slider.value = 0
		for slider_label in sliders_label :
			slider_label.text = "0"
	
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
	dimensions = []
	dimensions.append(object_controlled.DIMENSIONS[object_controlled.dimension_selected].name)
	for dimension in object_controlled.accesible_dimensions :
		dimensions.append(dimension.name)
	dimension_check_box.clear()
	for i in range(dimensions.size()):
		dimension_check_box.add_item(dimensions[i],i)
	dimension_check_box.selected =  0
	
func _on_close_button_pressed():
	object_controlled = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false


func _on_translation_reset_button_pressed(i : int):
	translation_sliders[i].value = 0


func _on_option_button_item_selected(index):
	object_controlled.change_dimension(dimensions[index])
	
	dimensions = []
	dimensions.append(object_controlled.DIMENSIONS[object_controlled.dimension_selected].name)
	for dimension in object_controlled.accesible_dimensions :
		dimensions.append(dimension.name)
	dimension_check_box.clear()
	for i in range(dimensions.size()):
		dimension_check_box.add_item(dimensions[i],i)
	dimension_check_box.selected =  0


func _on_face_view_button_pressed():
	prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
	var slider_pos_array = prev_translation_pos[object_controlled]
	var indice = 0
	for translation_slider in translation_sliders:
		translation_slider.value = slider_pos_array[indice]
		sliders_label[indice].text = str(slider_pos_array[indice])
		indice += 1
	object_controlled.view_face()


func _on_fugue_vie_button_pressed():
	prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
	var slider_pos_array = prev_translation_pos[object_controlled]
	var indice = 0
	for translation_slider in translation_sliders:
		translation_slider.value = slider_pos_array[indice]
		sliders_label[indice].text = str(slider_pos_array[indice])
		indice += 1
	object_controlled.fugue_view()
	prev_rotation_pos[object_controlled] = {
				"XY": {"toggled": false, "disabled": false},
				"XZ": {"toggled": false, "disabled": false},
				"YZ": {"toggled": false, "disabled": false},
				"XW": {"toggled": false, "disabled": false},
				"YW": {"toggled": false, "disabled": false},
				"ZW": {"toggled": false, "disabled": false}
			}
	xy_rotation_button.button_pressed = false
	xz_rotation_button.button_pressed = false
	yz_rotation_button.button_pressed = false
	xw_rotation_button.button_pressed = false
	yw_rotation_button.button_pressed = false
	zw_rotation_button.button_pressed = false
	xy_rotation_button.disabled = false
	xz_rotation_button.disabled = false
	yz_rotation_button.disabled = false
	xw_rotation_button.disabled = false
	yw_rotation_button.disabled = false
	zw_rotation_button.disabled = false
	


func _on_point_view_button_pressed():
	prev_translation_pos[object_controlled] = [0.0, 0.0, 0.0, 0.0]
	var slider_pos_array = prev_translation_pos[object_controlled]
	var indice = 0
	for translation_slider in translation_sliders:
		translation_slider.value = slider_pos_array[indice]
		sliders_label[indice].text = str(slider_pos_array[indice])
		indice += 1
	object_controlled.point_view()
	prev_rotation_pos[object_controlled] = {
				"XY": {"toggled": false, "disabled": false},
				"XZ": {"toggled": false, "disabled": false},
				"YZ": {"toggled": false, "disabled": false},
				"XW": {"toggled": false, "disabled": false},
				"YW": {"toggled": false, "disabled": false},
				"ZW": {"toggled": false, "disabled": false}
			}
	xy_rotation_button.button_pressed = false
	xz_rotation_button.button_pressed = false
	yz_rotation_button.button_pressed = false
	xw_rotation_button.button_pressed = false
	yw_rotation_button.button_pressed = false
	zw_rotation_button.button_pressed = false
	xy_rotation_button.disabled = false
	xz_rotation_button.disabled = false
	yz_rotation_button.disabled = false
	xw_rotation_button.disabled = false
	yw_rotation_button.disabled = false
	zw_rotation_button.disabled = false
