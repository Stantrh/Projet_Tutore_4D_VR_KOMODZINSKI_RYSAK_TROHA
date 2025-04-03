extends Control

var regex : RegEx
var selected_figures : Array
var selected_figure : int # 0 pour hypercube, 1 pour hypersphere, 2 pour empiler ect
var current_figure : int = 0
var number_objects : int = 0
enum available_figures {
	HYPERCUBE,
	HYPERSPHERE,
	TRITRIDUOPRISME,
	EMPILER,
	#TODO rajouter els autres figures quand elle seront faite
}
# Called when the node enters the scene tree for the first time.
func _ready():
	$start.visible = true
	$choix_figure.visible = false
	$choix_projection.visible = false
	$choix_maillage.visible = false
	regex = RegEx.new()
	regex.compile("^[1-6]$")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	$start.visible = false 
	$choix_figure.visible = false
	$choix_projection.visible = false
	$start/Popup.popup_centered()
	$start/Popup.show()

func _on_exit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	$start.visible = true
	$choix_figure.visible = false


func _on_hyper_cube_pressed():
	#$choix_figure/Popup.popup_centered()
	#$choix_figure/Popup.show()
	selected_figure = 0 
	$choix_figure.hide()
	$choix_projection.show()
	var figure = preload("res://Scenes/zone_affichage.tscn").instantiate()
	figure.object_selected = figure.Object4D.Tesseract
	figure.ply_object_path = "res://Objects/hypercube.txt"
	selected_figures.append(figure)
	update_label($choix_projection/VBoxContainer/Label_figure)


func _on_text_edit_text_changed():
	
		if regex.search($start/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/TextEdit.text):
			$start/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/HBoxContainer/Confirm_button.disabled = false
		else : 
			$start/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/HBoxContainer/Confirm_button.disabled = true
			$start/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/TextEdit.text = ""


func _on_retour_button_pressed():
	$start/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/TextEdit.text = "1" 
	$start/Popup.hide()


func _on_confirm_button_pressed():
	number_objects = int($start/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/TextEdit.text)
	#for i in range(int($choix_figure/Popup/ReferenceRect/ColorRect/VBoxContainer/VBoxContainer/TextEdit.text)):
		#var figure = preload("res://Scenes/zone_affichage.tscn").instantiate()
		#match selected_figure : 
			#available_figures.HYPERCUBE :
				#figure.object_selected = figure.Object4D.Tesseract
				#figure.ply_object_path = "res://Objects/hypercube.txt"
			#available_figures.HYPERSPHERE :
				#figure.ply_object_path = "res://Objects/hypersphere.txt"
			#_:
				#figure.object_selected = figure.Object4D.Tesseract
		#selected_figures.append(figure)
	$choix_figure/VBoxContainer/Label.text = "Figure n°"+str(current_figure+1)
	$start/Popup.hide()
	$choix_figure.show()
	$choix_projection.hide()

func _on_retour_button_down():
	selected_figures.clear()
	$choix_projection.hide()
	$choix_figure.show()



func _on_orthogonale_pressed():
	selected_figures[current_figure].projection_mode = 2
	$choix_projection.hide()
	$choix_maillage.show()
	update_label($choix_maillage/VBoxContainer/Label_figure)
	
func load_world():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var main_world = preload("res://Scenes/world_main.tscn").instantiate()
	main_world.shapes = selected_figures
	get_tree().root.add_child(main_world)
	$"../../".queue_free()


func _on_perspective_pressed():
	selected_figures[current_figure].projection_mode = 0
	$choix_projection.hide()
	$choix_maillage.show()
	update_label($choix_maillage/VBoxContainer/Label_figure)


func _on_stéréographique_pressed():
	selected_figures[current_figure].projection_mode = 1
	$choix_projection.hide()
	$choix_maillage.show()
	update_label($choix_maillage/VBoxContainer/Label_figure)

func update_label(label : Label):
	match selected_figure :
		available_figures.HYPERCUBE:
			label.text = "Objet n°" + str(current_figure +1)
		_ :
			label.text = "Objet n°" + str(current_figure +1)


func _on_wireframe_pressed():
	selected_figures[current_figure].mesh_mode = 0
	current_figure+=1
	if current_figure >= number_objects:
		current_figure = 0
		load_world()
	else :
		$choix_maillage.hide()
		$choix_figure.show()
		update_label($choix_figure/VBoxContainer/Label)


func _on_full_pressed():
	selected_figures[current_figure].mesh_mode = 1
	current_figure+=1
	if current_figure >= number_objects:
		current_figure = 0
		load_world()
	else :
		$choix_maillage.hide()
		$choix_figure.show()
		update_label($choix_figure/VBoxContainer/Label)

func _on_stylish_pressed():
	selected_figures[current_figure].mesh_mode = 2
	current_figure+=1
	if current_figure >= number_objects:
		current_figure = 0
		load_world()
	else :
		$choix_maillage.hide()
		$choix_figure.show()
		update_label($choix_figure/VBoxContainer/Label)


func _on_retour_style_pressed():
	current_figure = 0 
	$choix_maillage.hide()
	$choix_projection.show()


func _on_hyper_sphère_pressed():
	$choix_figure.hide()
	$choix_projection.show()
	selected_figure = 1
	var figure = preload("res://Scenes/zone_affichage.tscn").instantiate()
	figure.object_selected = figure.Object4D.Tesseract
	figure.ply_object_path = "res://Objects/hypersphere.txt"
	selected_figures.append(figure)
	update_label($choix_projection/VBoxContainer/Label_figure)


func _on_duoprisme_33_pressed():
	$choix_figure.hide()
	$choix_projection.show()
	selected_figure = 2
	var figure = preload("res://Scenes/zone_affichage.tscn").instantiate()
	figure.object_selected = figure.Object4D.Tesseract
	figure.ply_object_path = "res://Objects/tritriduoprisme.txt"
	selected_figures.append(figure)
	update_label($choix_projection/VBoxContainer/Label_figure)
