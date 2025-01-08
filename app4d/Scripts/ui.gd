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

# Pour les sliders, on garde les positions des sliders précédents dans un tableau qu'on actualise
var prev_translation_pos_slider = [0.0, 0.0, 0.0, 0.0] 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_translation_x_slider_value_changed(value):
	# on utilise node_controlled pour accéder au node3D représentant l'hypercube
	# à partir de la propriété value du slider, on crée un vecteur de translation
	var delta_x = value - prev_translation_pos_slider[0] # le delta, pour savoir si on avance ou recule
	prev_translation_pos_slider[0] = value
	if object_controlled != null:
		object_controlled.vect_translate = Vector4(delta_x, 0, 0, 0)
		object_controlled.is_translate = true

func _on_translation_y_slider_value_changed(value):
	# on utilise node_controlled pour accéder au node3D représentant l'hypercube
	# à partir de la propriété value du slider, on crée un vecteur de translation
	var delta_y = value - prev_translation_pos_slider[1]
	prev_translation_pos_slider[1] = value
		
	if object_controlled != null:
		object_controlled.vect_translate = Vector4(0, delta_y, 0, 0)
		object_controlled.is_translate = true

func _on_translation_z_slider_value_changed(value):
	# on utilise node_controlled pour accéder au node3D représentant l'hypercube
	# à partir de la propriété value du slider, on crée un vecteur de translation
	var delta_z = value - prev_translation_pos_slider[2]
	prev_translation_pos_slider[2] = value
	
	if object_controlled != null:
		object_controlled.vect_translate = Vector4(0, 0, delta_z, 0)
		object_controlled.is_translate = true

func _on_translation_w_slider_value_changed(value):
	# on utilise node_controlled pour accéder au node3D représentant l'hypercube
	# à partir de la propriété value du slider, on crée un vecteur de translation
	var delta_w = value - prev_translation_pos_slider[3]
	prev_translation_pos_slider[3] = value
	
	if object_controlled != null:
		object_controlled.vect_translate = Vector4(0, 0, 0, delta_w)
		object_controlled.is_translate = true
	
func _on_close_button_pressed():
	object_controlled = null 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	for translation_slider in translation_sliders :
		translation_slider.value = 0
	for rotation_slider in rotation_sliders :
		rotation_slider.value = 0
