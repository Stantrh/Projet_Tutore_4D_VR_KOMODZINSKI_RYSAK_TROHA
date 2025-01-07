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
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_translation_w_slider_value_changed(value):
	pass # Replace with function body.


func _on_translation_z_slider_value_changed(value):
	pass # Replace with function body.


func _on_translation_y_slider_value_changed(value):
	pass # Replace with function body.


func _on_translation_x_slider_value_changed(value):
	pass # Replace with function body.


func _on_close_button_pressed():
	object_controlled = null 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	for translation_slider in translation_sliders :
		translation_slider.value = 0
	for rotation_slider in rotation_sliders :
		rotation_slider.value = 0
