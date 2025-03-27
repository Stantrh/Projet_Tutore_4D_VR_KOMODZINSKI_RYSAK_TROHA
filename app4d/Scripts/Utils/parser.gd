extends Node
class_name Parser

static func load_hypercube_constants(ply_file_path: String) -> Dictionary:
	var data = {
		"vertices": [],
		"edges": []
	}
	
	# Ouvre le fichier en lecture avec FileAccess (Godot 4)
	var file = FileAccess.open(ply_file_path, FileAccess.READ)
	if file == null:
		push_error("Impossible d'ouvrir le fichier: " + ply_file_path)
		return data
	
	# --- Lecture de l'en-tête et construction de l'ordre des éléments ---
	var element_order = []  # Chaque élément : { "name": nom, "count": nombre }
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		# Ignore les lignes vides ou commençant par "#" ou "comment"
		if line == "" or line.begins_with("#") or line.begins_with("comment"):
			continue
		if line == "end_header":
			break
		if line.begins_with("element "):
			var parts = line.split(" ")
			if parts.size() >= 3:
				var elem_name = parts[1]
				var elem_count = int(parts[2])
				element_order.append({"name": elem_name, "count": elem_count})
	
	# --- Lecture des données en fonction de l'ordre des éléments ---
	for element in element_order:
		var elem_name = element["name"]
		var count = element["count"]
		for i in range(count):
			# Lire la prochaine ligne de données valide (ignore lignes vides et commentaires)
			var line = ""
			while not file.eof_reached():
				line = file.get_line().strip_edges()
				if line == "" or line.begins_with("#"):
					continue
				else:
					break
			var parts = line.split(" ")
			match elem_name:
				"vertices":
					# On attend 4 floats par ligne
					if parts.size() >= 4:
						data["vertices"].append(Vector4(
							float(parts[0]),
							float(parts[1]),
							float(parts[2]),
							float(parts[3])
						))
				"edges":
					# On attend 2 entiers par ligne
					if parts.size() >= 2:
						data["edges"].append([int(parts[0]), int(parts[1])])
				_:
					# Pour d'autres éléments (non utilisés ici)
					pass
	
	file.close()
	return data
