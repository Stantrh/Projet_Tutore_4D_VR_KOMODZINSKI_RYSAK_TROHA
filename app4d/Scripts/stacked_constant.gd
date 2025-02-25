extends Node

# Valeurs associées aux indices de la grille globale (pour un empilement de tesseracts)
const GRID_COORDS = [-1, 1, 3]  # Pour un indice 0, 1 et 2 respectivement.

# --- Faces d'un cube 3D (pour dessiner les faces de chaque cellule 3D d'un tesseract) ---
const CUBE_FACES = [
	[0, 1, 3, 2],
	[4, 5, 7, 6],
	[0, 1, 5, 4],
	[2, 3, 7, 6],
	[0, 2, 6, 4],
	[1, 3, 7, 5]
]

# Ces variables seront calculées au démarrage.
var DEFAULT_VERTICES = generate_transformed_hypercube_vertices()  # 81 sommets uniques (grille 3x3x3x3)
var CUBES = generate_cubes()            # 16 petits hypercubes, chacun défini par 16 indices dans DEFAULT_VERTICES

func _ready():
	#DEFAULT_VERTICES = generate_default_vertices()
	#CUBES = generate_cubes()
	
	# Affichage dans la console pour vérification
	print("DEFAULT_VERTICES (", DEFAULT_VERTICES.size(), " sommets ) :")
	for i in range(DEFAULT_VERTICES.size()):
		print(i, ":", DEFAULT_VERTICES[i])
		
	print("\nCUBES (", CUBES.size(), " cellules ) :")
	for i in range(CUBES.size()):
		print("Cellule ", i, ":", CUBES[i])

# Génère les 81 sommets de la grille globale.
# Génère les 16 cellules (petits hypercubes) de la grille.
# Pour chaque petit hypercube, on choisit un coin inférieur (indices cx,cy,cz,cw) avec cx,cy,cz,cw ∈ {0,1}
# Les 16 sommets d'une cellule sont obtenus en ajoutant 0 ou 1 à chacun des indices et en convertissant via GRID_COORDS.
func generate_cubes() -> Array:
	var cubes = []
	# Les positions de départ dans la grille pour chaque petit hypercube (0 ou 1 dans chaque dimension)
	for cw in [0, 1]:
		for cz in [0, 1]:
			for cy in [0, 1]:
				for cx in [0, 1]:
					var cell = []
					# Ordre des sommets pour reproduire l'ordre classique d'un tesseract
					# (pour chaque axe, on prend d'abord l'indice de départ, puis +1)
					for dw in [0, 1]:
						for dz in [0, 1]:
							for dy in [0, 1]:
								for dx in [0, 1]:
									# Conversion d'une coordonnée de grille (entre 0 et 2) en indice dans DEFAULT_VERTICES.
									# L'ordre est : x (le plus rapide), puis y, puis z, puis w.
									var grid_x = cx + dx
									var grid_y = cy + dy
									var grid_z = cz + dz
									var grid_w = cw + dw
									var index = grid_x + 3 * (grid_y + 3 * (grid_z + 3 * grid_w))
									cell.append(index)
					cubes.append(cell)
	return cubes
	
	
	

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
