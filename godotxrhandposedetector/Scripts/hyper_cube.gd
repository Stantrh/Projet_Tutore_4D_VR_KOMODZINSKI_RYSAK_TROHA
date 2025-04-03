extends Node3D

### POUR LE PARSER
# on récupère le parser
var parser = preload("res://Scripts/Utils/parser.gd")

# On a le chemin d'un fichier qu'on met en export
@export var ply_object_path: String = "res://Objects/hypercube.txt"

#A CHANGER POUR LE PARSER
# Les coordonnées des sommets de l'hypercube, en 4D
#Object dans lequel on va chercher
var object = HypercubeConstants
var dynamic_vertices = []
var dynamic_edges = []
var rotation_speed_factor = 0.0000001
var speed
var inactive : bool = false
# on charge les 8 cubes qui constituent l'hypercube
var CUBES = object.CUBES
# on charge les différentes faces de l'hypercube, les 4 points des carrés représentant les faces
var CUBE_FACES = object.CUBE_FACES
# on charge les couleurs des faces
const FACE_COLORS = HypercubeConstants.FACE_COLORS

# on charge l'enum des différents modes de projection
var ProjectionMode = HypercubeModes.ProjectionMode
# on charge aussi les différents modes de style
var MeshMode = HypercubeModes.MeshMode
# et les dimensions pour Fez
var DIMENSIONS = HypercubeConstants.DIMENSIONS
# Un tableau qui détermine quelles dimensions sont accessibles à l'hypercube par rapport à celle dans laquelle il se situe
var accesible_dimensions = []
var current_vertices = [] # Stocke les sommets actuels
var target_vertices = []  # Sommets de la prochaine dimension
var transitioning = false # Indique si une transition est en cours
@export var dimension_selected : int = 0 # Pour savoir quelle est la dimension actuelle 

#### ROTATIONS #### 
@export var is_rotate = false  # Détermine si la rotation est active
@export var is_double_rotate = false  # Détermine si la double rotation est active
@export var rotation_angle = 90  # Angle de rotation
@export var axe_a = 0 # x, y, z, w = 0, 1, 2, 3
@export var axe_b = 3 # x, y, z, w = 0, 1, 2, 3
@export var rotation_angle2 = 90
@export var axe2_a = 1
@export var axe2_b = 3
@export var interactible : bool = true
var initialized = false
var reload = false
#### TRANSLATIONS
@export var is_translate = false # Détermine si la translation est active
@export var vect_translate = Vector4(0, 0, 0, 0) # Vecteur de translation à appliquer sur l'hypercube 4D
@onready var collision_shape : CollisionShape3D = $Area3D/CollisionShape3D 
#### Valeurs d'enum par rapport à la visualisation de l'hypercube
@export var mesh_mode: int = 0  # Graphisme de l'hypercube | 0: Plein, 1: stylisé, 2: Filaire
@export var projection_mode: int = 0  # Projection de l'hypercube | 0: Perspective, 1: Stéréographique, 2: Orthogonale
var mesh_instance: MeshInstance3D # Mesh de l'hypercube
var hypercube_changed : bool = false
# --- Variables pour le mode STYLISH
var stylish_container: Node3D = null # Contient les cylindres et sphères
var stylish_spheres = [] # Tableaux des MeshInstance3D pour les sommets
var stylish_cylinders = [] # Tableaux des MeshInstance3D pour les arêtes
var stylish_edges = [] # Liste des arêtes (indices [i, j]) qui relient les sommets
var intialized : bool = false
var DEFAULT_VERTICES = []
#### Pour les points de vue (Vue de face, vue de fuite, vue par la pointe)
@onready var marker : Marker3D = $Marker3D
var is_point_of_view_fugue = false # COMMENTAIRES A FAIRE
var is_point_of_view_point = false # COMMENTAIRES A FAIRE
var change_view = false # COMMENTAIRES A FAIRE
var is_up_to_date = true # COMMENTAIRES A FAIRE

# COMMENTAIRES A FAIRE	
@onready var camera : Camera3D = WorldInfo.camera  # $"../CharacterView/Camera3D"
@export var area : Node3D = null # La variable de la zone

func _ready():
	load_data()
	#print("Vertices From Constants : " + str(dynamic_vertices) + "\n")
	#print("Vertices From Parser : " + str(hypercube_data["vertices"]) + "\n")
	#print("Edges From Constants : " + str(dynamic_edges) + "\n")
	#print("Edges From Parser : " + str(hypercube_data["edges"]) + "\n")
	
	if !interactible :
		$Area3D.monitoring = false
		$Area3D.monitorable = false
		$Area3D/CollisionShape3D.disabled = true
	WorldInfo.connect("_on_camera_changed",_on_camera_changed)
	# Création du Mesh pour les modes FULL / WIREFRAME
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	accesible_dimensions = find_accessible_dimensions(DIMENSIONS[dimension_selected],DIMENSIONS)
	# Selon le mode, on construit l'hypercube une seule fois pour le mode stylish (performances)
	if mesh_mode == MeshMode.STYLISH:
		create_stylish_hypercube()
	else:
		update_hypercube()
func update():
	if mesh_mode == MeshMode.STYLISH:
		create_stylish_hypercube()
	else:
		update_hypercube()
func load_data():
# On charge les constantes depuis le fichier PLY
	var hypercube_data = parser.load_hypercube_constants(ply_object_path)
	# Puis on assigne aux sommets et aux arêtes ce qu'on a parsé depuis le fichier
	dynamic_vertices = hypercube_data["vertices"]
	dynamic_edges = hypercube_data["edges"]
	DEFAULT_VERTICES = dynamic_vertices
	#print("Vertices From Parser : " + str(hypercube_data["vertices"]) + "\n")
	#print("Edges From Parser : " + str(hypercube_data["edges"]) + "\n")	
func stop_rotation():
	is_rotate = false
	var new_vertices = []
	for vertice in dynamic_vertices :
		new_vertices.append(rotate_4d(vertice, rotation_angle, axe_a, axe_b, rotation_angle2, axe2_a, axe2_b))
	dynamic_vertices = new_vertices
	if mesh_mode == MeshMode.STYLISH :
		update_stylish_hypercube_Vector3(dynamic_vertices)
	else : 
		update_hypercube()
func get_projected_vertices(vertices : Array):
	var projected_vertices = []
	for vertice in vertices:
		projected_vertices.append( apply_projection(vertice))
	return projected_vertices
func _process(delta):
	if inactive and initialized :
		return
	if !is_up_to_date and initialized:
		return
	initialized = true
	# On incrémente l'angle de rotation pour avoir une figure qui tourne en continu
	if is_rotate:
		rotation_angle += delta
		# La même chose si on a une double rotation
		if is_double_rotate:
			rotation_angle2 +=  delta
	# On appel en continu la méthode update_hypercube pour que la rotation prenne effet et aussi pour la projection perspective
	# Pour le mode STYLISH, on met à jour la position des nodes existants
	#if mesh_mode == MeshMode.STYLISH:
		#update_stylish_hypercube()
	#else:
		#update_hypercube()
	if not camera and WorldInfo.camera : 
		camera = WorldInfo.camera
	if  is_rotate or is_translate or hypercube_changed or projection_mode ==0:
		hypercube_changed = false 
		if mesh_mode == MeshMode.STYLISH:
			update_stylish_hypercube_Vector3(dynamic_vertices)
			return
		else:
			update_hypercube()
			return
	if mesh_mode == MeshMode.STYLISH and not initialized :
		initialized = true 
		update_stylish_hypercube_Vector3(dynamic_vertices)
func create_stylish_hypercube():
	# Crée un conteneur pour l'hypercube en mode STYLISH
	stylish_container = Node3D.new()
	add_child(stylish_container)
	
	# Création des sphères pour les sommets
	for i in range(dynamic_vertices.size()):
		var sphere_instance = MeshInstance3D.new()
		sphere_instance.mesh = SphereMesh.new()
		sphere_instance.scale = Vector3(0.2, 0.2, 0.2)
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.BLUE
		material.roughness = 0.1
		material.metallic = 0.9
		sphere_instance.mesh.material = material
		stylish_container.add_child(sphere_instance)
		stylish_spheres.append(sphere_instance)
	
	# Calcul des arêtes de l'hypercube (elles ne changent pas)
	stylish_edges = dynamic_edges
	
	# Création des cylindres pour les arêtes
	for edge in stylish_edges:
		var cylinder_instance = MeshInstance3D.new()
		cylinder_instance.mesh = CylinderMesh.new()
		# Paramétrage de base du cylindre (les valeurs de hauteur seront mises à jour)
		(cylinder_instance.mesh as CylinderMesh).bottom_radius = 0.05
		(cylinder_instance.mesh as CylinderMesh).top_radius = 0.05
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.WHITE
		material.roughness = 0.1
		material.metallic = 0.9
		cylinder_instance.mesh.material = material
		stylish_container.add_child(cylinder_instance)
		stylish_cylinders.append(cylinder_instance)
func update_stylish_hypercube_Vector3(new_vertices = []):
	if is_point_of_view_fugue :
		new_vertices = []
		var axe_1 = DIMENSIONS[dimension_selected].x
		var axe_2 = DIMENSIONS[dimension_selected].w
		for vertex in dynamic_vertices :
			new_vertices.append(rotate_4d(vertex, 44.83, axe_1, axe_2, 25, axe2_a, axe2_b))
		is_point_of_view_fugue = false
		dynamic_vertices = new_vertices
		marker.transform.origin = apply_projection(get_global_center(dynamic_vertices))
	elif is_point_of_view_point:
		#is_double_rotate = true
		new_vertices = []
		var axe_1 = DIMENSIONS[dimension_selected].x
		var axe_2 = DIMENSIONS[dimension_selected].w
		var axe2_1 = DIMENSIONS[dimension_selected].y
		var axe2_2 = DIMENSIONS[dimension_selected].w
		for vertex in dynamic_vertices :
			new_vertices.append(rotate_4d(vertex,-120,axe2_1,axe2_2,0,0,0))
		is_point_of_view_point = false
		dynamic_vertices = new_vertices
		marker.transform.origin = apply_projection(get_global_center(dynamic_vertices))
		is_double_rotate = false
	else:
		# Calcul des nouvelles positions 4D en fonction des rotations / translations
		if is_translate:
			new_vertices = []
			for vertex in dynamic_vertices:
				new_vertices.append( translate_4d(vertex, vect_translate) )
			# Mise à jour du vecteur de base et application de la translation sur le node concerné
			dynamic_vertices = new_vertices	
			apply_translation(vect_translate)
			is_translate = false
			marker.transform.origin = apply_projection(get_global_center(dynamic_vertices))
		elif is_rotate:
			new_vertices = []
			for vertex in dynamic_vertices:
				new_vertices.append( rotate_4d(vertex, rotation_angle, axe_a, axe_b, rotation_angle2, axe2_a, axe2_b) )
				marker.transform.origin = apply_projection(get_global_center(new_vertices))
	
	# Vérifier si au moins un sommet est dans la zone d'affichage
	var visible = false
	for vertex in new_vertices:
		var projected_point = vertex
		if projected_point is Vector4 : 
			projected_point = apply_projection(vertex)
		if area == null :
			visible = true 
			break
		if area.is_point_in_area(projected_point):
			visible = true
			break
	stylish_container.visible = visible
	if not visible:
		return
	
	# --- Mise à jour des positions des sphères (sommets)
	for i in range(new_vertices.size()):
		var projected = new_vertices[i]
		if projected is Vector4:
			projected = apply_projection(new_vertices[i])
		stylish_spheres[i].transform.origin = projected
	
	# --- Mise à jour des cylindres (arêtes)
	# La liste stylish_edges contient des paires [i, j] indiquant les indices des sommets à relier
	for index in range(stylish_edges.size()):
		var edge = stylish_edges[index]
		var p1 =new_vertices[ edge[0] ]
		var p2 = new_vertices[ edge[1] ]
		if p1 is Vector4:
			p1 = apply_projection(new_vertices[ edge[0] ])
			p2 = apply_projection(new_vertices[ edge[1] ])
		# Calcul du milieu et de la direction
		var mid_point = (p1 + p2) / 2.0
		var direction = (p2 - p1).normalized()
		var height = (p2 - p1).length()
		
		# Mise à jour du cylindre : sa hauteur et sa transformation
		var cylinder_mesh = stylish_cylinders[index].mesh as CylinderMesh
		cylinder_mesh.height = height
		
		# Calcul de la rotation nécessaire pour aligner le cylindre sur l'arête
		var axis = Vector3.UP.cross(direction).normalized()
		if axis.length() == 0:
			axis = Vector3(1, 0, 0)
		var angle = acos( Vector3.UP.dot(direction) )
		
		var cylinder_transform = Transform3D()
		cylinder_transform.origin = mid_point
		cylinder_transform.basis = Basis(axis, angle)
		stylish_cylinders[index].transform = cylinder_transform
# --- Pour les autres modes (FULL, WIREFRAME), on garde la méthode existante
func update_hypercube():
	print("yes")
	var projected_vertices = []
	var new_vertices = []
	var apply_change = false
	# Gestion des transformations
	if is_point_of_view_fugue or is_point_of_view_point:
		var axe_1 = DIMENSIONS[dimension_selected].x
		var axe_2 = DIMENSIONS[dimension_selected].w
		if is_point_of_view_fugue:
			for vertex in dynamic_vertices:
				new_vertices.append(rotate_4d(vertex, 45, axe_1, axe_2, 25, axe2_a, axe2_b))
			is_point_of_view_fugue = false
		else: # is_point_of_view_point
			var axe2_1 = DIMENSIONS[dimension_selected].y
			var axe2_2 = DIMENSIONS[dimension_selected].w
			for vertex in dynamic_vertices:
				new_vertices.append(rotate_4d(vertex, -120, axe2_1, axe2_2, 0, 0, 0))
			is_point_of_view_point = false
			is_double_rotate = false

		dynamic_vertices = new_vertices
		apply_change = true

	elif is_translate or is_rotate:
		for vertex in dynamic_vertices:
			if is_translate:
				new_vertices.append(translate_4d(vertex, vect_translate))
			elif is_rotate: # is_rotate
				new_vertices.append(rotate_4d(vertex, rotation_angle , axe_a, axe_b, rotation_angle2, axe2_a, axe2_b))

		if is_translate:
			apply_translation(vect_translate)
			is_translate = false
			dynamic_vertices = new_vertices
		apply_change = true

	# Vérification de visibilité
	if not is_hypercube_visible(dynamic_vertices):
		mesh_instance.visible = false
		return
	mesh_instance.visible = true

	# Construction du mesh (optimisation : évite la duplication de code)
	marker.transform.origin = apply_projection(get_global_center(dynamic_vertices))
	projected_vertices = get_projected_vertices(dynamic_vertices)
	#Pour eviter des rotations instables
	if is_rotate:
		projected_vertices = get_projected_vertices(new_vertices)
	var mesh = apply_build(projected_vertices)
	if mesh_mode == MeshMode.STYLISH:
		mesh_instance.add_child(mesh)
	else:
		mesh_instance.mesh = mesh

			
# Cette méthode return true si au moins une partie de l'hypercube est dans la zone
# Elle utilise une méthode qui est dans zone_affichage
func is_hypercube_visible(vertices: Array) -> bool:
	for vertex in vertices:
		var new_vertices = apply_projection(vertex)
		if area == null :
			return true
		if area.is_point_in_area(new_vertices):
			return true
	return false

# Cette méthode retourne le build choisi ou renvoie par défaut le mode wireframe
func apply_build(vertices):
	match mesh_mode:
		MeshMode.FULL:
			return build_solid_hypercube_mesh_projected(vertices)
		MeshMode.WIREFRAME:
			return build_wireframe_hypercube_mesh_Vector_3(vertices)
		MeshMode.STYLISH:
			return create_stylish_hypercube()
		_:
			return build_wireframe_hypercube_mesh_Vector_3(vertices)

	
func build_wireframe_hypercube_mesh_Vector_3(vertices: Array) -> Mesh:
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	# On commence à construire le maillage en mode lignes
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	
	# Pour chaque arête de l'hypercube (chaque edge est un tableau [index_sommet1, index_sommet2])
	for edge in dynamic_edges:
		# On récupère directement les positions 3D des sommets
		var p1: Vector3 = vertices[edge[0]]
		var p2: Vector3 = vertices[edge[1]]
		
		if area != null:
			var clipped_points = area.clip_edge(p1, p2)
			# Si il y a bien deux points alors on créer l'arêtes
			if clipped_points.size() == 2:
				surface_tool.add_vertex(clipped_points[0])
				surface_tool.add_vertex(clipped_points[1])
		else :
			surface_tool.add_vertex(p1)
			surface_tool.add_vertex(p2)
	surface_tool.commit(mesh)
	return mesh

func build_stylish_hypercube_mesh_projected(vertices) -> Node3D:
	var parent_node = Node3D.new() # On créer le Node3D qui va contenir tout les éléments qui représentent l'hypercube (arêtes et sommets)

	# Ici on créer une sphère pour chaque sommet
	for vertex in vertices:
		# On applique la projection
		var projected_vertex = vertex
		# Et on continue seulement si le point est toujours dans la zone /// Donc il faut modifier ça si vous souhaitez que la zone soit optionnel
		if area != null : 
			if area.is_point_in_area(projected_vertex):
				# Ensuite c'est seulement visuel, on créer la sphère et son matériau
				var point = MeshInstance3D.new()
				point.mesh = SphereMesh.new()
				point.scale = Vector3(0.2, 0.2, 0.2)
				point.transform.origin = vertex
				var material = StandardMaterial3D.new()
				material.albedo_color = Color.BLUE
				material.roughness = 0.1
				material.metallic = 0.9
				point.mesh.material = material
				# On ajoute le mesh en enfant du Node3D
				parent_node.add_child(point)
		else : 
			var point = MeshInstance3D.new()
			point.mesh = SphereMesh.new()
			point.scale = Vector3(0.2, 0.2, 0.2)
			point.transform.origin = vertex
			var material = StandardMaterial3D.new()
			material.albedo_color = Color.BLUE
			material.roughness = 0.1
			material.metallic = 0.9
			point.mesh.material = material
			# On ajoute le mesh en enfant du Node3D
			parent_node.add_child(point)
	# Ici on créer un cylindre pour chaque arête
	# Pour rappel, get_hypercube_edges est une méthodes qui renvoie les arêtes de l'hypercube
	# donc edge est un tableau qui contient chaque segment --> [[sommet1, sommet2], [sommet4, sommet6], []]
	for edge in dynamic_edges:
		# On applique la projection aux sommets
		var p1 = vertices[edge[0]]
		var p2 = vertices[edge[1]]
		# Si vous souhaitez que la zone soit optionnel alors il ne faut pas oublier de modifier ces lignes
		# Si l'arête est coupé par la zone alors on obtient de nouveaux points grâces à la méthode clip_edge
		var clipped_points = [p1,p2]
		if area != null:
			clipped_points = area.clip_edge(p1, p2)
			
		# Si il y a bien deux points alors on créer l'arêtes
		if clipped_points.size() == 2:
			var cylinder = MeshInstance3D.new()
			# On créer le cylindre et on le paramètre correctement
			cylinder.mesh = CylinderMesh.new()
			cylinder.mesh.bottom_radius = 0.05
			cylinder.mesh.top_radius = 0.05
			# La hauteur du cylindre c'est la distance entre les deux sommets
			cylinder.mesh.height = (clipped_points[0] - clipped_points[1]).length()
			
			# On positionne le cylindre au centre de l'arête
			var mid_point = (clipped_points[0] + clipped_points[1]) / 2.0 # On calcule le milieu
			cylinder.transform.origin = mid_point # Et on le positionne
			
			# On oriente le cylindre dans la bonne direction
			var direction = (clipped_points[1] - clipped_points[0]).normalized()
			
			# On calcule l'axe de rotation pour qu'on puisse l'applqiuer au cylindre (j'ai pas trouvé d'autre moyen de faire)
			# Donc on compare le vecteur direction avec le vecteur UP qui est le vecteur de l'axe y
			# Pour schématiser, si direction ressemble à ça ---, on va calculer l'angle entre | et ---, dans ce cas on devrait trouver 90° puis on va appliquer cette angle au cylindre
			var axis = Vector3.UP.cross(direction).normalized()
			if axis.length() == 0:
				# Si les points sont parfaitement alignés avec l'axe Y
				axis = Vector3(1, 0, 0)

			# On calcule l'angle de rotation
			var angle = acos(Vector3.UP.dot(direction))
			
			# On créer la transformation
			var cylinder_transform = Transform3D()
			cylinder_transform.origin = mid_point
			cylinder_transform.basis = Basis(axis, angle) * cylinder_transform.basis

			# On applique la transformation au cylindre
			cylinder.transform = cylinder_transform

			# On créer le matériau
			var material = StandardMaterial3D.new()
			material.albedo_color = Color.WHITE
			material.roughness = 0.1
			material.metallic = 0.9
			cylinder.mesh.material = material
			# On ajoute le cylindre en enfant de Node3D
			parent_node.add_child(cylinder)
	return parent_node

func build_solid_hypercube_mesh_projected(vertices: Array) -> Mesh:
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	# On initialise la construction du maillage en triangles
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Création et configuration du matériau
	var material = StandardMaterial3D.new()
	material.cull_mode = BaseMaterial3D.CULL_DISABLED         # Désactive le culling pour afficher les faces arrières
	material.albedo_color = Color(1, 1, 1, 0.3)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED # Désactive l'éclairage
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	material.vertex_color_use_as_albedo = true
	surface_tool.set_material(material)
	
	# Construction des faces de l'hypercube
	var iColor = 0
	for cube in CUBES:
		var face_color = FACE_COLORS[iColor]
		iColor += 1
		# Pour chaque face du cube
		for face in CUBE_FACES:
			# Ici, les sommets sont déjà en coordonnées projetées
			var projected_vertices = [
				vertices[cube[face[0]]],
				vertices[cube[face[1]]],
				vertices[cube[face[2]]],
				vertices[cube[face[3]]]
			]
			
			# Découpage de la face selon la zone (optionnel)
			var clipped_face = []
			for i in range(4):
				if area != null :
					var start = projected_vertices[i]
					var end = projected_vertices[(i + 1) % 4]
					clipped_face += area.clip_edge(start, end)
				else : 
					clipped_face += [projected_vertices[i],projected_vertices[(i + 1)%4]]
			
			# On duplique la face découpée si besoin (pour éviter toute référence inattendue)
			clipped_face = clipped_face.duplicate()
			
			# Si la face possède au moins 3 points, on la triangule
			if clipped_face.size() >= 3:
				for i in range(1, clipped_face.size() - 1):
					surface_tool.set_color(face_color)
					surface_tool.add_vertex(clipped_face[0])
					surface_tool.set_color(face_color)
					surface_tool.add_vertex(clipped_face[i])
					surface_tool.set_color(face_color)
					surface_tool.add_vertex(clipped_face[i + 1])
			
			# Optionnel : Si vous souhaitez commiter à chaque face, vous pouvez le laisser ici.
			# Sinon, il est aussi possible de commit une seule fois à la fin.
			surface_tool.commit(mesh)
	
	return mesh

# Cette méthode retoune les arêtes de l'hypercube sous forme de liste --> [[sommet1, sommet4], [], []]
func get_hypercube_edges() -> Array:
	var edges = []
	for i in range(dynamic_vertices.size()):
		for j in range(i + 1, dynamic_vertices.size()):
			if (dynamic_vertices[i] - dynamic_vertices[j]).length() == 2:
				edges.append([i, j])
	return edges

# Cette méthode retourne la projection choisie ou par défaut la projection perspective
func apply_projection(point_4d: Vector4) -> Vector3:
	var point : Vector3
	match projection_mode:
		ProjectionMode.PERSPECTIVE:
			return project_perspective(point_4d)
		ProjectionMode.STEREOGRAPHIC:
			return project_stereographically(point_4d)
		ProjectionMode.ORTHOGONAL:
			return project_orthogonally(point_4d)
		_:
			return project_perspective(point_4d)

# Méthode de la projection perspective=
func project_perspective(point_4d: Vector4) -> Vector3:
	#print(ignored_axis)
	# On calcule la distance entre la caméra et la position de l'hypercube
	var d = camera.global_position.distance_to(marker.global_position)
	return Vector3(point_4d[DIMENSIONS[dimension_selected].x]* d /(point_4d[DIMENSIONS[dimension_selected].w]+d),
	point_4d[DIMENSIONS[dimension_selected].y]* d /(point_4d[DIMENSIONS[dimension_selected].w]+d),
	point_4d[DIMENSIONS[dimension_selected].z]* d /(point_4d[DIMENSIONS[dimension_selected].w]+d))


# On crée une fonction pour la projection stéréographique
func project_stereographically(point_4d: Vector4):
	var projection_center : Vector4 = Vector4(0,0,0,0)
	projection_center[DIMENSIONS[dimension_selected].w]=2
	var t = 1.0 /(projection_center[DIMENSIONS[dimension_selected].w] - point_4d[DIMENSIONS[dimension_selected].w])
	return Vector3(t * point_4d[DIMENSIONS[dimension_selected].x],t*point_4d[DIMENSIONS[dimension_selected].y],t*point_4d[DIMENSIONS[dimension_selected].z])


func project_orthogonally(point_4d: Vector4)->Vector3:
	return Vector3(point_4d[DIMENSIONS[dimension_selected].x],point_4d[DIMENSIONS[dimension_selected].y],point_4d[DIMENSIONS[dimension_selected].z])

func translate_4d(vect: Vector4, vect_translation: Vector4) -> Vector4:
	return vect + vect_translation

# on utilise cette méthode pour déplacer le node3d de sorte à ce qu'il soit au même endroit dans l'espace 3D
# que la projection de l'hypercube
func apply_translation(vect: Vector4):
	var vect_3d = Vector3(vect.x, vect.y, vect.z)
	if false:
		collision_shape.global_transform.origin += vect_3d
		$RayCast3D.global_transform.origin += vect_3d



# Cette méthode applique une rotation ou une double rotation à un point
func rotate_4d(point: Vector4, angle1: float, axis1_a: int, axis1_b: int, angle2: float, axis2_a: int, axis2_b: int) -> Vector4:
	var center = get_global_center(dynamic_vertices)
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
		
func get_global_center(vertices: Array) -> Vector4:
	var center = Vector4()
	for vertex in vertices:
		center += vertex
	return center / vertices.size()

#fonction pour changer le point qu'on ne projette pas
func change_dimension(new_dimension: String):
	hypercube_changed = true
	current_vertices.clear()
	target_vertices.clear()
	if transitioning:
		return # Empêcher d'enchaîner trop vite
	
	is_up_to_date = false
	var old_dimension = DIMENSIONS[dimension_selected] # Dimension actuelle
	for i in range(dynamic_vertices.size()):
		current_vertices.append(apply_projection(dynamic_vertices[i]))
	for i in range(DIMENSIONS.size()):
		if DIMENSIONS[i].name == new_dimension:
			dimension_selected = i
			break
	for i in range(dynamic_vertices.size()):
		target_vertices.append(apply_projection(dynamic_vertices[i]))
	var new_dim = DIMENSIONS[dimension_selected] # Nouvelle dimension sélectionnée
	accesible_dimensions = find_accessible_dimensions(DIMENSIONS[dimension_selected], DIMENSIONS)
		# Lancer l'animation de transition
	animate_dimension_transition()
func set_dimension_selected(new_dimension_selected):
	is_up_to_date = false
	dimension_selected = new_dimension_selected
	is_up_to_date = true



	

func animate_dimension_transition():
	transitioning = true

	var duration = 0.8 # Durée de la transition en secondes
	var steps = 20 # Nombre d'étapes d'interpolation
	var step_time = duration / steps
	var start_vertices = current_vertices.duplicate()	
	for i in range(steps):
		await get_tree().create_timer(step_time).timeout
		var t = float(i + 1) / steps # Progression entre 0 et 1
		current_vertices = lerp_vertices(current_vertices, target_vertices, t)
		for child in mesh_instance.get_children():
			child.queue_free()
		# Re-construit le maillage en cours de transition
		var mesh
		if mesh_mode==2:
			update_stylish_hypercube_Vector3(current_vertices)
		else: # Sinon, le Mesh de l'hypercube devient le Mesh du build
			match mesh_mode:
				MeshMode.FULL:
					mesh = build_solid_hypercube_mesh_projected(current_vertices)
				MeshMode.WIREFRAME:
					mesh = build_wireframe_hypercube_mesh_Vector_3(current_vertices)
				MeshMode.STYLISH:
					mesh = build_stylish_hypercube_mesh_projected(current_vertices)
				_:
					mesh = build_wireframe_hypercube_mesh_Vector_3(current_vertices)
			if mesh_mode !=2 :
				mesh_instance.mesh = mesh
	
	transitioning = false
	is_up_to_date = true

func lerp_vertices(start_vertices, end_vertices, t):
	var new_vertices = []
	for i in range(start_vertices.size()):
		new_vertices.append(start_vertices[i].lerp(end_vertices[i], t))
	
	return new_vertices


func view_face():
	dynamic_vertices = DEFAULT_VERTICES
	hypercube_changed = true
	#rotate_toward_camera()

func fugue_view():
	is_point_of_view_fugue = true
	hypercube_changed = true
	dynamic_vertices = DEFAULT_VERTICES
	is_double_rotate = false
	is_rotate = false
	is_translate = false
	#rotate_toward_camera()
func point_view() :
	hypercube_changed = true
	dynamic_vertices = DEFAULT_VERTICES
	is_double_rotate = false
	is_rotate = false
	is_translate = false
	is_point_of_view_point = true
	#rotate_toward_camera()
	
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
func _on_camera_changed(value):
	camera = value
