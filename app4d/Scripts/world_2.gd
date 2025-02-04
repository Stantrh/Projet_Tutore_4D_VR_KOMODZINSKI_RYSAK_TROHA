extends Node3D


@onready var markers : Array[Marker3D] = [
	$markers/Marker3D,
	$markers/Marker3D2,
	$markers/Marker3D4,
	$markers/Marker3D3,
	$markers/Marker3D5,
	$markers/Marker3D6
]
var shapes : Array 
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(shapes.size()):
		add_child(shapes[i])
		shapes[i].global_position = markers[i].global_position
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $CanvasLayer/UI.visible == false :
		$CanvasLayer/TextureRect.visible = true


func _on_character_view_object_selected(object):
	$CanvasLayer/UI.open_interface(object)
