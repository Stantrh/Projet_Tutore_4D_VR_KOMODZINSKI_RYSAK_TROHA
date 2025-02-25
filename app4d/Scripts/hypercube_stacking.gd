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

func _process(delta: float) -> void:
	if not child_instantiated and WorldInfo.camera : 
		update_hypercubes()
		child_instantiated = false
	if is_translate or is_rotate or is_double_rotate:
		update_hypercubes()  # Recalcule et recrée tout quand on applique une transformation
	if is_rotate:
		rotation_angle += delta
		# La même chose si on a une double rotation
		if is_double_rotate:
			rotation_angle2 += delta

func update_hypercubes():
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

						# Appliquer translation
						if is_translate : 
							real_vect_translate += vect_translate
							is_translate = false
						print(real_vect_translate)
						print(vect_translate)
						new_vertex += real_vect_translate

						# Appliquer rotation si nécessaire
						if is_rotate:
							new_vertex = rotate_4d(new_vertex,rotation_angle,axe_a,axe_b,rotation_angle2,axe2_a,axe2_b)

						hypercube_vertices.append(new_vertex)

					all_hypercubes.append(hypercube_vertices)

	return all_hypercubes

func generate_small_hypercube_vertices() -> Array:
	var vertices = []
	for a in [-1, 1]:
		for b in [-1, 1]:
			for c in [-1, 1]:
				for d in [-1, 1]:
					vertices.append(Vector4(a, b, c, d))
	return vertices

func rotate_point(v: Vector4, a: int, b: int, angle: float) -> Vector4:
	var rad = deg_to_rad(angle)
	var cos_theta = cos(rad)
	var sin_theta = sin(rad)
	
	var rotated = Vector4(v.x, v.y, v.z, v.w)
	rotated[a] = v[a] * cos_theta - v[b] * sin_theta
	rotated[b] = v[a] * sin_theta + v[b] * cos_theta
	
	return rotated
func rotate_4d(point: Vector4, angle1: float, axis1_a: int, axis1_b: int, angle2: float, axis2_a: int, axis2_b: int) -> Vector4:
	var center = Vector4(0,0,0,0)
	var local_point = point - center
	
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
		
