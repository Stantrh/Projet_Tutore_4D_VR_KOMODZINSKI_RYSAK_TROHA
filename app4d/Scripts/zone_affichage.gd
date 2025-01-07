extends Node3D

# Variable qui définies la taille de la zone d'affichage
@export var area_min = Vector3(-10, -10, -10)
@export var area_max = Vector3(10, 10, 10)

func create_area_mesh(area_min: Vector3, area_max: Vector3) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	var size = area_max - area_min
	cube_mesh.size = size
	mesh_instance.mesh = cube_mesh
	mesh_instance.transform.origin = area_min + size / 2.0
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.8, 0.2, 0.2)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true
	cube_mesh.material = material
	return mesh_instance


func is_point_in_area(point: Vector3) -> bool:
	return point.x >= area_min.x and point.x <= area_max.x and point.y >= area_min.y and point.y <= area_max.y and point.z >= area_min.z and point.z <= area_max.z

func get_clip_planes():
	return [
		Plane(Vector3(1, 0, 0), area_min.x),  # Plan gauche
		Plane(Vector3(-1, 0, 0), -area_max.x),  # Plan droit
		Plane(Vector3(0, 1, 0), area_min.y),  # Plan bas
		Plane(Vector3(0, -1, 0), -area_max.y),  # Plan haut
		Plane(Vector3(0, 0, 1), area_min.z),  # Plan arrière
		Plane(Vector3(0, 0, -1), -area_max.z)  # Plan avant
	]
	
func intersect_line_with_plane(start: Vector3, end: Vector3, plane: Plane):
	var direction = end - start
	var denom = plane.normal.dot(direction)
	if abs(denom) > 0.00001:
		var t = (plane.d - plane.normal.dot(start)) / denom
		if t >= 0.0 and t <= 1.0:
			return start + direction * t
	return null

func clip_edge(start: Vector3, end: Vector3) -> Array:
	var points = []
	if is_point_in_area(start):
		points.append(start)
	if is_point_in_area(end):
		points.append(end)
	for plane in get_clip_planes():
		var intersection = intersect_line_with_plane(start, end, plane)
		if intersection != null and is_point_in_area(intersection):
			points.append(intersection)
	return points
