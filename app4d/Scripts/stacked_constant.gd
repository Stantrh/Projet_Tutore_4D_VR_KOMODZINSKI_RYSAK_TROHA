extends Node

var CUBE_FACES = [
	[0, 1, 3, 2], [4, 5, 7, 6], [0, 1, 5, 4], 
	[2, 3, 7, 6], [0, 2, 6, 4], [1, 3, 7, 5]
]
const CELLS = [
	[0, 1, 2, 3, 4, 5, 6, 7],
	[8, 9, 10, 11, 12, 13, 14, 15],
	[0, 1, 4, 5, 8, 9, 12, 13],
	[2, 3, 6, 7, 10, 11, 14, 15],
	[0, 2, 4, 6, 8, 10, 12, 14],
	[1, 3, 5, 7, 9, 11, 13, 15],
	[0, 1, 2, 3, 8, 9, 10, 11],
	[4, 5, 6, 7, 12, 13, 14, 15]
]

# Initialisation automatique
var DEFAULT_VERTICES = generate_transformed_hypercube_vertices()

var CUBES = generate_cells(DEFAULT_VERTICES)
var EDGES = get_hypercube_edges()

func generate_transformed_hypercube_vertices() -> Array:
	var all_hypercubes = []
	var small_vertices = generate_small_hypercube_vertices()

	for i in [-1, 1]:
		for j in [-1, 1]:
			for k in [-1, 1]:
				for l in [-1, 1]:
					for vertex in small_vertices:
						var new_vertex = Vector4(vertex.x + i, vertex.y + j, vertex.z + k, vertex.w + l)
						all_hypercubes.append(new_vertex)

	return all_hypercubes
func generate_small_hypercube_vertices() -> Array:
	var vertices = []
	for a in [-1, 1]:
		for b in [-1, 1]:
			for c in [-1, 1]:
				for d in [-1, 1]:
					vertices.append(Vector4(a, b, c, d))
	return vertices

# Génération des cellules sans doublons
static func generate_cells(vertices: Array) -> Array:
	var cells = []
	for t_idx in range(16):
		for cube in CELLS:
			var transformed_cube = []
			for index in cube:
				transformed_cube.append(index + t_idx * 16)  # Décalage des indices
			cells.append(transformed_cube)
	return cells
func _ready():
	print("Total Sommets:", DEFAULT_VERTICES.size())
	print("Total Cellules:", CUBES)

func get_hypercube_edges() -> Array:
	var edges = []
	for i in range(DEFAULT_VERTICES.size()):
		for j in range(i + 1, DEFAULT_VERTICES.size()):
			if (DEFAULT_VERTICES[i] - DEFAULT_VERTICES[j]).length() == 2:
				edges.append([i, j])
	return edges
