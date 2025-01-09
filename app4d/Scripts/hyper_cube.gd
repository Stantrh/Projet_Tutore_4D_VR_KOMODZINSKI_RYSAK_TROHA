extends Node3D

var dynamic_vertices = [
	Vector4(-1, -1, -1, -1), Vector4(-1, -1, -1,  1), Vector4(-1, -1,  1, -1), Vector4(-1, -1,  1,  1),
	Vector4(-1,  1, -1, -1), Vector4(-1,  1, -1,  1), Vector4(-1,  1,  1, -1), Vector4(-1,  1,  1,  1),
	Vector4( 1, -1, -1, -1), Vector4( 1, -1, -1,  1), Vector4( 1, -1,  1, -1), Vector4( 1, -1,  1,  1),
	Vector4( 1,  1, -1, -1), Vector4( 1,  1, -1,  1), Vector4( 1,  1,  1, -1), Vector4( 1,  1,  1,  1)
]


const CUBE_FACES = [
	[0, 1, 3, 2], [4, 5, 7, 6], [0, 1, 5, 4], 
	[2, 3, 7, 6], [0, 2, 6, 4], [1, 3, 7, 5]
]

const CUBES = [
		[0, 1, 2, 3, 4, 5, 6, 7],
		[8, 9, 10, 11, 12, 13, 14, 15],
		[0, 1, 4, 5, 8, 9, 12, 13],
		[2, 3, 6, 7, 10, 11, 14, 15],
		[0, 2, 4, 6, 8, 10, 12, 14],
		[1, 3, 5, 7, 9, 11, 13, 15],
		[0, 1, 2, 3, 8, 9, 10, 11],
		[4, 5, 6, 7, 12, 13, 14, 15]
	]

	

enum ProjectionMode {
	PERSPECTIVE,
	STEREOGRAPHIC,
	ORTHOGONAL
}

enum MeshMode {
	WIREFRAME,
	FULL,
	STYLISH
}

@export var is_rotate = false  # Activer la rotation
@export var is_double_rotate = false  # Activer la rotation double
@export var rotation_angle = 90  # Angle de rotation
@export var axe_a = 0 # x, y, z, w = 0, 1, 2, 3
@export var axe_b = 3 # x, y, z, w = 0, 1, 2, 3
@export var rotation_angle2 = 90
@export var axe2_a = 1
@export var axe2_b = 3
@export var mesh_mode: int = 0  # 0: Plein, 1: stylisé, 2: Filaire
@export var projection_mode: int = 0  # 0: Perspective, 1: Stéréographique, 2: Orthogonale

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
		

# pour la translation
@export var is_translate = false # Activer la translation
@export var vect_translate = Vector4(0, 0, 0, 0) # Vecteur de translation
var collision_shape = Node


@onready var camera = $"../CharacterView/Camera3D"
@onready var area = $ZoneAffichage

var mesh_instance: MeshInstance3D

func _ready():
	collision_shape = $Area3D/CollisionShape3D
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	var bounds_mesh = area.create_area_mesh()
	add_child(bounds_mesh)
	update_hypercube()
	

func _process(delta):
	if is_rotate:
		rotation_angle += delta
		if is_double_rotate:
			rotation_angle2 += delta
	update_hypercube()


func update_hypercube():
	for child in mesh_instance.get_children():
		child.queue_free()
	# Transformer les sommets
	var new_vertices = []
	if is_translate:
		for vertex in dynamic_vertices:
			var new_vect = translate_4d(vertex, vect_translate)
			new_vertices.append(new_vect)
		dynamic_vertices = new_vertices	
		apply_translation(vect_translate)
	elif is_rotate:
		for vertex in dynamic_vertices:
			new_vertices.append(rotate_4d(vertex, rotation_angle, axe_a, axe_b, rotation_angle2, axe2_a, axe2_b))
	else :
		for vertex in dynamic_vertices:
			new_vertices.append(vertex)
	
	if not is_hypercube_visible(new_vertices):
		mesh_instance.visible = false
		return
	else:
		mesh_instance.visible = true
	
	# Générer le maillage
	var mesh
	if mesh_mode==2:
		mesh = apply_build(new_vertices)
		mesh_instance.add_child(mesh)
	else:
		mesh = apply_build(new_vertices)
		mesh_instance.mesh = mesh

	if is_translate:
		is_translate = false

func is_hypercube_visible(vertices: Array) -> bool:
	for vertex in vertices:
		var projected_point = apply_projection(vertex)
		if area.is_point_in_area(projected_point):
			return true
	return false

func apply_build(vertices):
	match mesh_mode:
		MeshMode.FULL:
			return build_solid_hypercube_mesh(vertices)
		MeshMode.WIREFRAME:
			return build_wireframe_hypercube_mesh(vertices)
		MeshMode.STYLISH:
			return build_stylish_hypercube_mesh(vertices)
		_:
			return build_wireframe_hypercube_mesh(vertices)

func build_wireframe_hypercube_mesh(vertices) -> Mesh:
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)

	# Ajouter les arêtes
	for edge in get_hypercube_edges():
		var p1 = apply_projection(vertices[edge[0]])
		var p2 = apply_projection(vertices[edge[1]])
		var clipped_points = area.clip_edge(p1, p2)
		
		if clipped_points.size() == 2:
			surface_tool.add_vertex(clipped_points[0])
			surface_tool.add_vertex(clipped_points[1])

	surface_tool.commit(mesh)
	return mesh

func build_stylish_hypercube_mesh(vertices) -> Node3D:
	var parent_node = Node3D.new()

	# Créer des points pour chaque sommet
	for vertex in vertices:
		var projected_vertex = apply_projection(vertex)
		if area.is_point_in_area(projected_vertex):
			var point = MeshInstance3D.new()
			point.mesh = SphereMesh.new()
			point.scale = Vector3(0.2, 0.2, 0.2)
			point.transform.origin = apply_projection(vertex)
			var material = StandardMaterial3D.new()
			material.albedo_color = Color.BLUE
			material.roughness = 0.1
			material.metallic = 0.9
			point.mesh.material = material
			parent_node.add_child(point)

	# Créer des cylindres pour chaque arête
	for edge in get_hypercube_edges():
		var p1 = apply_projection(vertices[edge[0]])
		var p2 = apply_projection(vertices[edge[1]])
		var clipped_points = area.clip_edge(p1, p2)
		
		if clipped_points.size() == 2:
			var cylinder = MeshInstance3D.new()
			cylinder.mesh = CylinderMesh.new()
			cylinder.mesh.bottom_radius = 0.05
			cylinder.mesh.top_radius = 0.05
			cylinder.mesh.height = (clipped_points[0] - clipped_points[1]).length()
			
			# Positionner le cylindre entre les deux points
			var mid_point = (clipped_points[0] + clipped_points[1]) / 2.0
			cylinder.transform.origin = mid_point
			
			# Orienter le cylindre dans la bonne direction
			var direction = (clipped_points[1] - clipped_points[0]).normalized()
			
			# Calculer l'axe de rotation
			var axis = Vector3.UP.cross(direction).normalized()
			if axis.length() == 0:
				# Si les points sont parfaitement alignés avec l'axe Y
				axis = Vector3(1, 0, 0)

			# Calculer l'angle de rotation
			var angle = acos(Vector3.UP.dot(direction))
			
			# Créer la transformation
			var cylinder_transform = Transform3D()
			cylinder_transform.origin = mid_point
			cylinder_transform.basis = Basis(axis, angle) * cylinder_transform.basis

			# Appliquer la transformation au cylindre
			cylinder.transform = cylinder_transform

			# Ajouter un matériau
			var material = StandardMaterial3D.new()
			material.albedo_color = Color.WHITE
			material.roughness = 0.1
			material.metallic = 0.9
			cylinder.mesh.material = material

			parent_node.add_child(cylinder)
	return parent_node

func build_solid_hypercube_mesh(vertices) -> Mesh:
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Créer un matériau non éclairé
	var material = StandardMaterial3D.new()
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.1, 0.2, 0.8, 0.3)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # Mode non éclairé
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	# Appliquer ce matériau
	surface_tool.set_material(material)

	# Construire chaque face pour chaque cube
	for cube in CUBES:
		for face in CUBE_FACES:
			var projected_vertices = [
				apply_projection(vertices[cube[face[0]]]),
				apply_projection(vertices[cube[face[1]]]),
				apply_projection(vertices[cube[face[2]]]),
				apply_projection(vertices[cube[face[3]]])
			]

			var clipped_face = []
			for i in range(4):
				var start = projected_vertices[i]
				var end = projected_vertices[(i + 1) % 4]
				clipped_face += area.clip_edge(start, end)

			clipped_face = clipped_face.duplicate()

			if clipped_face.size() >= 3:
				for i in range(1, clipped_face.size() - 1):
					surface_tool.add_vertex(clipped_face[0])
					surface_tool.add_vertex(clipped_face[i])
					surface_tool.add_vertex(clipped_face[i + 1])

	surface_tool.commit(mesh)
	return mesh

func get_hypercube_edges() -> Array:
	var edges = []
	for i in range(16):
		for j in range(i + 1, 16):
			if (dynamic_vertices[i] - dynamic_vertices[j]).length() == 2:
				edges.append([i, j])
	return edges

func apply_projection(point_4d: Vector4) -> Vector3:
	match projection_mode:
		ProjectionMode.PERSPECTIVE:
			return project_perspective(point_4d)
		ProjectionMode.STEREOGRAPHIC:
			return project_stereographically(point_4d)
		ProjectionMode.ORTHOGONAL:
			return project_orthogonally(point_4d)
		_:
			return project_perspective(point_4d)

func project_perspective(point_4d: Vector4) -> Vector3:
	var d = camera.global_position.distance_to(global_position)
	var w = point_4d.w + d
	if abs(w) < 0.01:
		w = 0.01
	return Vector3(point_4d.x * d / w, point_4d.y * d / w, point_4d.z * d / w)


# On crée une fonction pour la projection stéréographique
func project_stereographically(point_4d: Vector4):
	# On choisit le point de projection
	var projection_center = Vector4(0, 0, 0, 2)
	# on calcule le facteur de projection
	var t = 1.0 / (projection_center.w - point_4d.w)
	# puis on projette x y et z en 3D avec le facteur de projection
	return Vector3(t * point_4d.x, t * point_4d.y, t * point_4d.z)

# à rajouter plus tard, possibilité de choisir la coordonnée à exclure
func project_orthogonally(point_4d: Vector4)->Vector3:
	return Vector3(point_4d.x, point_4d.y, point_4d.z)


func translate_4d(vect: Vector4, vect_translation: Vector4) -> Vector4:
	return vect + vect_translation

# on utilise cette méthode pour déplacer le node3d de sorte à ce qu'il soit au même endroit dans l'espace 3D
# que la projection de l'hypercube
func apply_translation(vect: Vector4):
	var vect_3d = Vector3(vect.x, vect.y, vect.z)
	collision_shape.global_transform.origin += vect_3d
	global_transform.origin += vect_3d
	

func rotate_4d(point: Vector4, angle1: float, axis1_a: int, axis1_b: int, angle2: float, axis2_a: int, axis2_b: int) -> Vector4:
	var cos_theta1 = cos(angle1)
	var sin_theta1 = sin(angle1)
	var rotated_point = point
	var temp_a = point[axis1_a]
	var temp_b = point[axis1_b]
	rotated_point[axis1_a] = temp_a * cos_theta1 - temp_b * sin_theta1
	rotated_point[axis1_b] = temp_a * sin_theta1 + temp_b * cos_theta1
	
	if is_double_rotate:
		var cos_theta2 = cos(angle2)
		var sin_theta2 = sin(angle2)
		temp_a = point[axis2_a]
		temp_b = point[axis2_b]
		rotated_point[axis2_a] = temp_a * cos_theta2 - temp_b * sin_theta2
		rotated_point[axis2_b] = temp_a * sin_theta2 + temp_b * cos_theta2
	return rotated_point
