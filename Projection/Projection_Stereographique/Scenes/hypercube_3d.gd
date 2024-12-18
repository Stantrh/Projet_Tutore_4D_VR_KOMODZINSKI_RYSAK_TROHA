extends Node3D

# Liste qui représente les sommets (16 pour un hypercube)
var vertices_4d = []
# Liste des arêtes sous la forme d'une paire de 2 sommets (donc les coordonnées de début et de fin)
var edges = []
# Liste des sommets projetés en 3D (Vector3)
var projected_vertices = []

"""
on ne peut pas directement afficher l'hypercube via un noeud étant donné qu'il n'y a pas de noeud 4D avec 4 coordonnées
donc même l'affichage doit être fait à la main
"""

func _ready():
	create_hypercube() # pour créer sommets et arêtes en 4D
	project_stereographically() # pour projeter en 3D les sommets
	visualize_hypercube() # et pour créer les noeuds nécessaires pour afficher l'hypercube
	
# Étape 1 : Générer les sommets et les arêtes de l'hypercube
func create_hypercube():
	# Donc on génère déjà les 16 sommets
	for i in range(16):
		var w = (i & 8) >> 3  # 4e coordonnée (w)
		var x = (i & 4) >> 2  # 3e coordonnée (x)
		var y = (i & 2) >> 1  # 2e coordonnée (y)
		var z = i & 1         # 1ère coordonnée (z)
		# Convertir en valeurs (-1, 1) au lieu de (0, 1)
		vertices_4d.append(Vector4(w * 2 - 1, x * 2 - 1, y * 2 - 1, z * 2 - 1))

	# ici on génére les arêtes à partir des points (sommets)
	for i in range(16):
		for j in range(i + 1, 16):
			# la distance hamming c'est pour vérifier que deux sommets peuvent être reliés
			# et pour qu'ils le soient, il faut qu'ils aient une seule coordonnées de différence
			# par exemple, (1, 1, 1, 1) est relié avec (-1, 1, 1, 1) mais pas avec (-1, -1, 1, 1)
			if hamming_distance(vertices_4d[i], vertices_4d[j]) == 1:
				edges.append([i, j])

# On crée une fonction pour la distance de hamming qui permet de déterminer si deux sommets sont reliés
func hamming_distance(v1: Vector4, v2: Vector4) -> int:
	var diff_coord = 0
	# donc on compte le nombre de coordonnées différentes de chaque sommet
	if v1.x != v2.x: diff_coord += 1
	if v1.y != v2.y: diff_coord += 1
	if v1.z != v2.z: diff_coord += 1
	if v1.w != v2.w: diff_coord += 1
	return diff_coord

# On crée une fonction pour la projection stéréographique
func project_stereographically():
	# On choisit le point de projection
	var projection_center = Vector4(0, 0, 0, 2)

	for vertex in vertices_4d:
		# on calcule le facteur de projection
		var t = 1.0 / (projection_center.w - vertex.w)
		# puis on projette x y et z en 3D avec le facteur de projection
		var x = t * vertex.x
		var y = t * vertex.y
		var z = t * vertex.z
		projected_vertices.append(Vector3(x, y, z))

# pour visualiser le cube en le dessinant avec des meshinstances
func visualize_hypercube():
	# Matériel pour personnaliser l'apparence
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 0, 1)

	# Donc on affiche les sommets projetés par stéréographie
	for vertex in projected_vertices:
		var sphere = SphereMesh.new()
		# on fait des sommets petits, mais qu'on puisse différencier des arêtes
		sphere.radius = 0.005
		sphere.height = 0.005
		var instance = MeshInstance3D.new()
		instance.mesh = sphere
		instance.material_override = material
		instance.transform.origin = vertex
		add_child(instance)

	# Puis on affiche les arêtes avec une méthode
	for edge in edges:
		var start = projected_vertices[edge[0]]
		var end = projected_vertices[edge[1]]
		
	draw_edges(vertices_4d)
	
func draw_edges(vertices):
	var line_material = StandardMaterial3D.new()
	line_material.albedo_color = Color(1, 0, 0) # en rouge
	for edge in edges:
		var start = projected_vertices[edge[0]]
		var end = projected_vertices[edge[1]]

		var line = ImmediateMesh.new()
		var instance = MeshInstance3D.new()
		instance.mesh = line
		instance.material_override = line_material
		line.surface_begin(Mesh.PRIMITIVE_LINES, null)
		line.surface_add_vertex(start)
		line.surface_add_vertex(end)
		line.surface_end()
		add_child(instance)
		
		
		
#func draw_edges(vertices):
	#var cylinder_material = StandardMaterial3D.new()
	#cylinder_material.albedo_color = Color(0, 0, 0)  # Couleur des cylindres (par exemple noir)
#
	#for edge in edges:
		#var start = projected_vertices[edge[0]]
		#var end = projected_vertices[edge[1]]
#
		## Calcul de la direction et de la distance entre les deux sommets
		#var direction = end - start
		#var distance = direction.length()
#
		## Créer un cylindre pour chaque arête
		#var cylinder_mesh = CylinderMesh.new()
		#cylinder_mesh.bottom_radius = 0.05  # Épaisseur du cylindre (à ajuster)
		#cylinder_mesh.top_radius = 0.05  # Épaisseur du cylindre (à ajuster)
		#cylinder_mesh.height = distance  # La hauteur du cylindre correspond à la distance entre les points
#
		#var cylinder_instance = MeshInstance3D.new()
		#cylinder_instance.mesh = cylinder_mesh
		#cylinder_instance.material_override = cylinder_material
		#
		## Calcul de la position au centre entre les deux points
		#var position = (start + end) / 2
		#cylinder_instance.transform.origin = position
#
		## Orientation du cylindre : on oriente le cylindre pour qu'il pointe de "start" à "end"
		#var up_vector = Vector3(0, 1, 0)  # Vecteur 'up' de référence pour le cylindre
		#cylinder_instance.look_at(end, up_vector)  # Aligne le cylindre de "start" à "end"
		#
		#add_child(cylinder_instance)
