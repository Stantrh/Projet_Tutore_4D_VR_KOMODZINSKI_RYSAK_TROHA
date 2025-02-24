extends Node

signal _on_camera_changed(value)
var camera: Camera3D:
	get:
		return camera
	set(value):
		camera = value
		_on_camera_changed.emit(value)
