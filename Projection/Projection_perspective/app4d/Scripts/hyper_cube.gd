extends Node3D

const HYPERCUBE_VERTICES = [
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

@export var is_rotate = false  # Activer la rotation
@export var rotation_angle = 90  # Angle de rotation
@export var is_solid = false  # Affichage plein ou filaire
@onready var camera = $"../CharacterView/Camera3D"

var mesh_instance: MeshInstance3D

func _ready():
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	update_hypercube()

func _process(delta):
	if rotation_angle:
		rotation_angle+=delta
	update_hypercube()

func update_hypercube():
	# Transformer les sommets
	var transformed_vertices = []
	for vertex in HYPERCUBE_VERTICES:
		if is_rotate:
			transformed_vertices.append(rotate_4d(vertex, rotation_angle, 0, 3))
		else:
			transformed_vertices.append(vertex)

	# Générer le maillage
	var mesh
	if is_solid:
		mesh = build_solid_hypercube_mesh(transformed_vertices)
	else:
		mesh = build_wireframe_hypercube_mesh(transformed_vertices)
	mesh_instance.mesh = mesh

func build_wireframe_hypercube_mesh(vertices) -> Mesh:
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)

	# Ajouter les arêtes
	for edge in get_hypercube_edges():
		var p1 = project_to_3d(vertices[edge[0]])
		var p2 = project_to_3d(vertices[edge[1]])
		surface_tool.add_vertex(p1)
		surface_tool.add_vertex(p2)

	surface_tool.commit(mesh)
	return mesh

func build_solid_hypercube_mesh(vertices) -> Mesh:
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Créer un matériau non éclairé
	var material = StandardMaterial3D.new()
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0, 0, 0)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # Mode non éclairé

	# Appliquer ce matériau
	surface_tool.set_material(material)

	# Construire chaque face pour chaque cube
	for cube in CUBES:
		for face in CUBE_FACES:
			var p1 = project_to_3d(vertices[cube[face[0]]])
			var p2 = project_to_3d(vertices[cube[face[1]]])
			var p3 = project_to_3d(vertices[cube[face[2]]])
			var p4 = project_to_3d(vertices[cube[face[3]]])

			# Deux triangles pour une face
			surface_tool.add_vertex(p1)
			surface_tool.add_vertex(p2)
			surface_tool.add_vertex(p3)

			surface_tool.add_vertex(p3)
			surface_tool.add_vertex(p4)
			surface_tool.add_vertex(p1)

	surface_tool.commit(mesh)
	return mesh

func get_hypercube_edges() -> Array:
	var edges = []
	for i in range(16):
		for j in range(i + 1, 16):
			if (HYPERCUBE_VERTICES[i] - HYPERCUBE_VERTICES[j]).length() == 2:
				edges.append([i, j])
	return edges


func project_to_3d(point_4d: Vector4) -> Vector3:
	var d = camera.global_position.distance_to(global_position)
	var w = point_4d.w + d
	if abs(w) < 0.01:
		w = 0.01
	return Vector3(point_4d.x * d / w, point_4d.y * d / w, point_4d.z * d / w)

func rotate_4d(point: Vector4, angle: float, axis_a: int, axis_b: int) -> Vector4:
	var cos_theta = cos(angle)
	var sin_theta = sin(angle)
	var rotated_point = point
	var temp_a = point[axis_a]
	var temp_b = point[axis_b]
	rotated_point[axis_a] = temp_a * cos_theta - temp_b * sin_theta
	rotated_point[axis_b] = temp_a * sin_theta + temp_b * cos_theta
	return rotated_point
