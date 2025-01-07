extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_character_view_object_selected(object):
	$CanvasLayer/UI.visible = true
	$CanvasLayer/UI.object_controlled = object
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
