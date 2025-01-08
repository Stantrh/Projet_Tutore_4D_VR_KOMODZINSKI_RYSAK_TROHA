extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_character_view_object_selected(object):
	# on déploie l'interface en initialisant l'objet
	$CanvasLayer/UI.open_interface(object)
	
	
