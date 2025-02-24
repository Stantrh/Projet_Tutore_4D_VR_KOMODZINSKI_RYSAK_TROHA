extends Node

signal _on_camera_changed(value)

var _camera : Camera3D
var camera: Camera3D:
	get:
		return _camera
	set(value):
		_camera = value
		_on_camera_changed.emit(value)
