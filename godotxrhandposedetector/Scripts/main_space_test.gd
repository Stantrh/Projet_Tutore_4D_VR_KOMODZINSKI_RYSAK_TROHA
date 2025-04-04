extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	WorldInfo.camera = $CharacterView/Camera3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
