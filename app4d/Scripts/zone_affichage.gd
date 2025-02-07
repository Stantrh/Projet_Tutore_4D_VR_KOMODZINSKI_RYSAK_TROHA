extends Node3D

# Variables qui définies la taille de la zone d'affichage
# Ici les exports ne servent à rien
@export var area_min = Vector3(-3, -3, -3)
@export var area_max = Vector3(3, 3, 3)
# Créer une zone de taille area_min - area_max
func create_area_mesh() -> MeshInstance3D:
	# On créer le Mesh sous forme de cube
	var mesh_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	var size = area_max - area_min
	cube_mesh.size = size
	mesh_instance.mesh = cube_mesh
	mesh_instance.transform.origin = area_min + size / 2.0 # on positionne le cube au centre
	# On créer le matériau
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.8, 0.2, 0.5)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true
	cube_mesh.material = material
	return mesh_instance

# Cette méthode vérifie si le point donné se trouve dans la zone
func is_point_in_area(point: Vector3) -> bool:
	return point.x >= area_min.x and point.x <= area_max.x and point.y >= area_min.y and point.y <= area_max.y and point.z >= area_min.z and point.z <= area_max.z

# Donne les plans (les faces) de la zone
# On en a besoin lorsqu'on souhaite calculer les points d'intersections lorsque la figure sort de la zone
func get_clip_planes():
	return [
		Plane(Vector3(1, 0, 0), area_min.x),  # Plan gauche
		Plane(Vector3(-1, 0, 0), -area_max.x),  # Plan droit
		Plane(Vector3(0, 1, 0), area_min.y),  # Plan bas
		Plane(Vector3(0, -1, 0), -area_max.y),  # Plan haut
		Plane(Vector3(0, 0, 1), area_min.z),  # Plan arrière
		Plane(Vector3(0, 0, -1), -area_max.z)  # Plan avant
	]

# Cette méthode calcule le point d'intersection avec le plan donné
func intersect_line_with_plane(start: Vector3, end: Vector3, plane: Plane):
	var direction = end - start # On calcule la direction
	# On projette la direction sur la normale du plan (produit scalaire)
	var denom = plane.normal.dot(direction)
	if abs(denom) > 0.00001: # Si c'est 0 alors la direction est parrallèle au plan donc pas d'intersection
		var t = (plane.d - plane.normal.dot(start)) / denom # t est le point d'intersection
		if t >= 0.0 and t <= 1.0: # S'il est entre 0 et 1 alors il est sur le segment
			return start + direction * t # Et on retourne le point d'intersection
	return null

# Cette méthode découpe l'arête entre start et end en fonction de area_min - area_max
func clip_edge(start: Vector3, end: Vector3) -> Array:
	var points = [] # Le tableau des points qui survivent au clipping
	# Si start et end sont dans la zone alors on les garde
	if is_point_in_area(start):
		points.append(start)
	if is_point_in_area(end):
		points.append(end)
	# On parcourt les plans et on vérifie s'il y a une intersection
	for plane in get_clip_planes():
		var intersection = intersect_line_with_plane(start, end, plane)
		if intersection != null and is_point_in_area(intersection):
			points.append(intersection)
	return points
