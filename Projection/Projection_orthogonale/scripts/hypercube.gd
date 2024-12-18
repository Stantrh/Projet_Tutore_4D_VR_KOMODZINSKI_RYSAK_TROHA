extends Node3D


@export var taille : float = 1

var sommets : Array[Vector4] = []



func generer_sommets():
	sommets= [
	Vector4(0,0,0,0),Vector4(taille,0,0,0),
	Vector4(taille,0,taille,0),Vector4(taille,0,0,taille),
	Vector4(taille,taille,0,0),Vector4(taille,taille,taille,0),
	Vector4(taille,taille,taille,taille),Vector4(taille,0,taille,taille),
	Vector4(taille,taille,0,taille),Vector4(0,taille,0,0),
	Vector4(0,taille,taille,0),Vector4(0,taille,taille,taille),
	Vector4(0,0,taille,taille),Vector4(0,taille,0,taille),
	Vector4(0,0,taille,0),Vector4(0,0,0,taille)
]
func _ready():
	
	generer_sommets()
	var new_sommets : Array[Vector3] = []
	
	for s in sommets :
		new_sommets.append(projeter_4D_3D(s))
	var arretes = generer_arrete2_test(sommets)
	
	for arrete in arretes :
		dessiner_arrete(arrete[0],arrete[1])
	var faces = generer_faces(sommets)
	var count = 0;
	for face in faces:
		dessiner_face(face)
func projeter_4D_3D(sommet : Vector4)->Vector3:
	return Vector3(sommet.x,sommet.y,sommet.z)

#A utiliser plutot que generer_arrete
func generer_arrete2_test(sommets : Array[Vector4]):
	var edges = []
	for i in sommets.size():
		for j in sommets.size():
			if sont_points_adjacents(sommets[i],sommets[j]):
				edges.append([projeter_4D_3D(sommets[i]),projeter_4D_3D(sommets[j])])
	return edges
func generer_arrete(sommets : Array[Vector3]):
	var edges = []
	for i in sommets.size():
		for j in sommets.size():
			var somme =(sommets[i] - sommets[j]).abs().x + (sommets[i] - sommets[j]).abs().y + (sommets[i] - sommets[j]).abs().z
			if i != j and somme == taille:
				edges.append([sommets[i], sommets[j]])
	return edges

func generer_faces(sommets: Array[Vector4]) -> Array:
	var faces = []
	var seen_faces = {} 
	for i in sommets:
		for j in sommets:
			for k in sommets:
				for l in sommets:
					if sont_points_adjacents(i, j) and sont_points_adjacents(i, k) and sont_points_adjacents(j, l) and sont_points_adjacents(k, l) and ((k!=j) and (i!=l)):
						var face = [i, j, k, l]
						face.sort_custom(_compare_vectors)
						var face_key = str(face) 
						if not seen_faces.has(face_key):
							seen_faces[face_key] = true
							faces.append(face)
	return faces

func _compare_vectors(a, b):
	return a.x < b.x or (a.x == b.x and (a.y < b.y or (a.y == b.y and (a.z < b.z or (a.z == b.z and a.w < b.w)))))

func sont_points_adjacents(p1 : Vector4, p2: Vector4):
	var somme =(p1 - p2).abs().x + (p1 - p2).abs().y + (p1 - p2).abs().z+ (p1 - p2).abs().w
	return p1 != p2 and somme == taille
func dessiner_arrete(v1 : Vector3,v2 : Vector3):
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	mesh_instance.mesh = immediate_mesh
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(v1)
	immediate_mesh.surface_add_vertex(v2)
	immediate_mesh.surface_end()
	material.albedo_color = Color.AQUA
	var diff = (v1 - v2).abs()
	if (diff.x == taille ):
		material.albedo_color = Color.RED
	elif (diff.y == taille):
		material.albedo_color = Color.GREEN
	else :
		material.albedo_color = Color.BLUE	
	add_child(mesh_instance)

func dessiner_face(face):
	var mesh_instance = MeshInstance3D.new()
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Créer un matériau non éclairé
	var material = StandardMaterial3D.new()
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # Mode non éclairé

	# Appliquer ce matériau
	surface_tool.set_material(material)

	# Construire chaque face pour chaque cube
	var p1 = projeter_4D_3D(face[0])
	var p2 = projeter_4D_3D(face[1])
	var p3 = projeter_4D_3D(face[2])
	var p4 = projeter_4D_3D(face[3])

	# Deux triangles pour une face
	surface_tool.add_vertex(p1)
	surface_tool.add_vertex(p2)
	surface_tool.add_vertex(p3)

	surface_tool.add_vertex(p3)
	surface_tool.add_vertex(p4)
	surface_tool.add_vertex(p1)

	surface_tool.commit(mesh)
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
