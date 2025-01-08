extends Control

var regex : RegEx
var selected_figures : Array
var selected_figure : int # 0 pour hypercube, 1 pour hypersphere, 2 pour empiler ect
var current_figure : int = 0

enum available_figures {
	HYPERCUBE,
	HYPERSPHERE,
	EMPILER,
	#TODO rajouter els autres figures quand elle seront faite
}
# Called when the node enters the scene tree for the first time.
func _ready():
	$start.visible = true
	$choix_figure.visible = false
	$choix_projection.visible = false
	regex = RegEx.new()
	regex.compile("^[1-6]$")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	$start.visible = false 
	$choix_figure.visible = true
	$choix_projection.visible = false

func _on_exit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	$start.visible = true
	$choix_figure.visible = false


func _on_hyper_cube_pressed():
	$choix_figure/Popup.popup_centered()
	$choix_figure/Popup.show()
	selected_figure = 0 


func _on_text_edit_text_changed():
	
		if regex.search($choix_figure/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/TextEdit.text):
			$choix_figure/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/HBoxContainer/Confirm_button.disabled = false
		else : 
			$choix_figure/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/HBoxContainer/Confirm_button.disabled = true
			$choix_figure/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/TextEdit.text = ""


func _on_retour_button_pressed():
	$choix_figure/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/TextEdit.text = 1 
	$choix_figure/Popup.hide()


func _on_confirm_button_pressed():
	for i in range(int($choix_figure/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/TextEdit.text)):
		match selected_figure : 
			available_figures.HYPERCUBE :
				selected_figures.append(preload("res://Scenes/hyper_cube.tscn").instantiate())
			_:
				selected_figures.append(preload("res://Scenes/hyper_cube.tscn").instantiate())
	$choix_figure/Popup.hide()
	$choix_figure.hide()
	$choix_projection.show()

func _on_retour_button_down():
	selected_figures.clear()
	$choix_projection.hide()
	$choix_figure.show()


func _on_orthogonale_pressed():
	selected_figures[current_figure].projection_mode = 2
	current_figure+=1
	if current_figure >= selected_figures.size():
		load_world()
	else :
		update_label()
	
func load_world():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var main_world = preload("res://Scenes/world_2.tscn").instantiate()
	main_world.shapes = selected_figures
	get_tree().root.add_child(main_world)
	$"../../".queue_free()


func _on_perspective_pressed():
	selected_figures[current_figure].projection_mode = 0
	current_figure+=1
	if current_figure >= selected_figures.size():
		load_world()
	else :
		update_label()


func _on_stéréographique_pressed():
	selected_figures[current_figure].projection_mode = 1
	current_figure+=1
	if current_figure >= selected_figures.size():
		load_world()
	else :
		update_label()

func update_label():
	var label : Label = $choix_projection/VBoxContainer/Label_figure
	match selected_figure :
		available_figures.HYPERCUBE:
			label.text = "Hypercube n°" + str(current_figure +1)
		_ :
			label.text = "Hypercube n°" + str(current_figure +1)
