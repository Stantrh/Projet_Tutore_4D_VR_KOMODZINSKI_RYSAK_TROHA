extends Node

@export var mesh_mode = 0
@export var projection_mode = 0
@export var is_rotate = false  
@export var is_double_rotate = false  
@export var rotation_angle = 90  
@export var axe_a = 0 
@export var axe_b = 3 
@export var rotation_angle2 = 90
@export var axe2_a = 1
@export var axe2_b = 3
@export var interactible : bool = true
var is_view_face = false
var is_point_of_view_fugue = false  
var is_point_of_view_point = false  
#### TRANSLATIONS
@export var is_translate = false 
@export var vect_translate = Vector4(0, 0, 0, 0)
var real_vect_translate = Vector4(0,0,0,0)
var DIMENSIONS = HypercubeConstants.DIMENSIONS
var accesible_dimensions = []
var is_up_to_date = true
var current_vertices = [] # Stocke les sommets actuels
var target_vertices = []  # Sommets de la prochaine dimension
var transitioning = false # Indique si une transition est en cours
@export var dimension_selected : int = 0 # Pour savoir quelle est la dimension actuelle 
var child_instantiated : bool = false

const HYPERCUBE_SCENE = preload("res://Scenes/hyper_cube.tscn")

func _ready():
	child_instantiated = false
	accesible_dimensions = find_accessible_dimensions(DIMENSIONS[dimension_selected],DIMENSIONS)

func _process(delta: float) -> void:
	if not child_instantiated and WorldInfo.camera : 
		update_hypercubes()
		child_instantiated = false
	if is_rotate:
		rotation_angle += delta
		# La même chose si on a une double rotation
		if is_double_rotate:
			rotation_angle2 += delta
	if is_translate or is_rotate or is_double_rotate:
		update_hypercubes()  # Recalcule et recrée tout quand on applique une transformation


func update_hypercubes():
	if not transitioning : 
		# Supprimer tous les hypercubes enfants
		for child in get_children():
			if child.is_in_group("Hyperfigure"):
				child.queue_free()

		# Récupérer les nouveaux sommets transformés
		var transformed_vertices = generate_transformed_hypercube_vertices()

		# Instancier les nouveaux hypercubes
		for vertices in transformed_vertices:
			var child = HYPERCUBE_SCENE.instantiate()
			child.interactible = false
			child.dynamic_vertices = vertices
			child.mesh_mode = mesh_mode
			child.projection_mode = projection_mode
			child.camera = WorldInfo.camera
			add_child(child)
			child.set_dimension_selected(dimension_selected)
		# Reset des flags après mise à jour
		is_translate = false

func generate_transformed_hypercube_vertices() -> Array:
	var all_hypercubes = []
	var small_vertices = generate_small_hypercube_vertices()

	for i in [-1, 1]:
		for j in [-1, 1]:
			for k in [-1, 1]:
				for l in [-1, 1]:
					var hypercube_vertices = []
					for vertex in small_vertices:
						var new_vertex = Vector4(vertex.x + i, vertex.y + j, vertex.z + k, vertex.w + l)
						if is_point_of_view_fugue :
							var axe_1 = DIMENSIONS[dimension_selected].x
							var axe_2 = DIMENSIONS[dimension_selected].w
							new_vertex =	rotate_4d(new_vertex, 44.83, axe_1, axe_2, 25, axe2_a, axe2_b)
						elif is_point_of_view_point:
						#is_double_rotate = true
							var axe_1 = DIMENSIONS[dimension_selected].x
							var axe_2 = DIMENSIONS[dimension_selected].w
							var axe2_1 = DIMENSIONS[dimension_selected].y
							var axe2_2 = DIMENSIONS[dimension_selected].w
							new_vertex =rotate_4d(new_vertex,-120,axe2_1,axe2_2,0,0,0)
							is_double_rotate = false
						# Appliquer translation
						if is_translate : 
							real_vect_translate += vect_translate
							is_translate = false
						if is_view_face :
							real_vect_translate = Vector4(0,0,0,0)
						new_vertex += real_vect_translate
			
						# Appliquer rotation si nécessaire
						if is_rotate and not is_view_face:
							new_vertex = rotate_4d(new_vertex,rotation_angle,axe_a,axe_b,rotation_angle2,axe2_a,axe2_b)
						
						hypercube_vertices.append(new_vertex)

					all_hypercubes.append(hypercube_vertices)
	is_view_face = false
	return all_hypercubes

func generate_small_hypercube_vertices() -> Array:
	var vertices = []
	for a in [-1, 1]:
		for b in [-1, 1]:
			for c in [-1, 1]:
				for d in [-1, 1]:
					vertices.append(Vector4(a, b, c, d))
	return vertices

func rotate_4d(point: Vector4, angle1: float, axis1_a: int, axis1_b: int, angle2: float, axis2_a: int, axis2_b: int) -> Vector4:
	var center = Vector4(0,0,0,0)
	var local_point = point - center
	print(is_double_rotate)
	# On calcule cos et sin de la première rotation
	var cos_theta1 = cos(angle1)
	var sin_theta1 = sin(angle1)
	# On créer des variables temporaires
	var rotated_point = local_point
	var temp_a = local_point[axis1_a]
	var temp_b = local_point[axis1_b]
	# On applique la transformation
	rotated_point[axis1_a] = temp_a * cos_theta1 - temp_b * sin_theta1
	rotated_point[axis1_b] = temp_a * sin_theta1 + temp_b * cos_theta1
	
	# On refait la même chose dans le cas d'une double rotation
	if is_double_rotate:
		var cos_theta2 = cos(angle2)
		var sin_theta2 = sin(angle2)
		temp_a = local_point[axis2_a]
		temp_b = local_point[axis2_b]
		rotated_point[axis2_a] = temp_a * cos_theta2 - temp_b * sin_theta2
		rotated_point[axis2_b] = temp_a * sin_theta2 + temp_b * cos_theta2
	return rotated_point + center
func get_global_center(vertices: Array) -> Vector4:
	var center = Vector4()
	for vertex in vertices:
		center += vertex
	return center / vertices.size()
func set_rotate_plan(plan: String, single_rotate: bool):
	match plan:
		"XY":
			if single_rotate:
				axe_a = 0
				axe_b = 1
			else:
				axe2_a = 0
				axe2_b = 1
		"XZ":
			if single_rotate:
				axe_a = 0
				axe_b = 2
			else:
				axe2_a = 0
				axe2_b = 2
		"YZ":
			if single_rotate:
				axe_a = 1
				axe_b = 2
			else:
				axe2_a = 1
				axe2_b = 2
		"XW":
			if single_rotate:
				axe_a = 0
				axe_b = 3
			else:
				axe2_a = 0
				axe2_b = 3
		"YW":
			if single_rotate:
				axe_a = 1
				axe_b = 3
			else:
				axe2_a = 1
				axe2_b = 3
		"ZW":
			if single_rotate:
				axe_a = 2
				axe_b = 3
			else:
				axe2_a = 2
				axe2_b = 3
		
func view_face():
	is_view_face = true
	is_point_of_view_fugue = false
	is_point_of_view_point = false
func fugue_view():
	is_point_of_view_fugue = true
	is_view_face = false	
	is_point_of_view_point = false
	is_double_rotate = false
	is_rotate = false
	is_translate = false
	#rotate_toward_camera()
func point_view() :
	is_double_rotate = false
	is_rotate = false
	is_translate = false
	is_point_of_view_point = true
	is_point_of_view_fugue = false
	is_view_face = false	
	#
func find_accessible_dimensions(current_dim: Dictionary, dimensions: Array) -> Array:
	var accessible = []
	
	for dim in dimensions:
		var swaps = 0
		var keys = ["x", "y", "z", "w"]
		
		for key in keys:
			if current_dim[key] != dim[key]:
				swaps += 1
		
		# Si une seule permutation ou aucune (même dimension), on considère comme accessible
		if swaps == 2:
			accessible.append(dim)
	
	return accessible
func change_dimension(new_dimension: String):
	transitioning = true
	for i in range(DIMENSIONS.size()):
		if DIMENSIONS[i].name == new_dimension:
			dimension_selected = i
			break
	accesible_dimensions = find_accessible_dimensions(DIMENSIONS[dimension_selected], DIMENSIONS)
	transitioning = false
	
