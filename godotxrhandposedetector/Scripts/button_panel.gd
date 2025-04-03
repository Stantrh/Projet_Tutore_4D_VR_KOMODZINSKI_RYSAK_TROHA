extends StaticBody3D

signal hypercube_pressed
signal hyphersphere_pressed
signal triduoprism_pressed
# Called when the node enters the scene tree for the first time.
func _ready():
	$Viewport2Din3D/Viewport/button_teleport/HBoxContainer/hypercube.connect("pressed",_on_hypercube_pressed)
	$Viewport2Din3D/Viewport/button_teleport/HBoxContainer/hypersphere.connect("pressed",_on_hypersphere_pressed)
	$Viewport2Din3D/Viewport/button_teleport/HBoxContainer/triduoprism.connect("pressed",_on_triduoprism_pressed)
func _on_hypercube_pressed():
	hypercube_pressed.emit()
func _on_hypersphere_pressed():
	hyphersphere_pressed.emit()
func _on_triduoprism_pressed():
	triduoprism_pressed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
