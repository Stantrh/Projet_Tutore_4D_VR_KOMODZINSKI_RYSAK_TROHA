extends Node

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

const FACE_COLORS = [
	Color(1, 0, 0, 1),  # rouge
	Color(0, 1, 0, 1),  # vert
	Color(0, 0, 1, 1),  # bleu
	Color(1, 1, 0, 1),  # jaune
	Color(1, 0, 1, 1),  # magenta
	Color(0, 1, 1, 1),  # cyan
	Color(1, 0.5, 0, 1),# orange
	Color(0.5, 0, 1, 1) # violet
]

const DIMENSIONS = [
	{"name": "XYZ", "x": 0, "y": 1, "z": 2, "w": 3},
	{"name": "XYW", "x": 0, "y": 1, "z": 3, "w": 2},
	{"name": "XZW", "x": 0, "y": 2, "z": 3, "w": 1},
	{"name": "XWY", "x": 0, "y": 3, "z": 1, "w": 2},
	{"name": "XWZ", "x": 0, "y": 3, "z": 2, "w": 1},
	{"name": "XZY", "x": 0, "y": 2, "z": 1, "w": 3},
	{"name": "YZW", "x": 1, "y": 2, "z": 3, "w": 0},
	{"name": "YZX", "x": 1, "y": 2, "z": 0, "w": 3},
	{"name": "YXW", "x": 1, "y": 0, "z": 3, "w": 2},
	{"name": "YXZ", "x": 1, "y": 0, "z": 2, "w": 3},
	{"name": "YWX", "x": 1, "y": 3, "z": 0, "w": 2},
	{"name": "YWZ", "x": 1, "y": 3, "z": 2, "w": 0},
	{"name": "ZXY", "x": 2, "y": 0, "z": 1, "w": 3},
	{"name": "ZXW", "x": 2, "y": 0, "z": 3, "w": 1},
	{"name": "ZYX", "x": 2, "y": 1, "z": 0, "w": 3},
	{"name": "ZYW", "x": 2, "y": 1, "z": 3, "w": 0},
	{"name": "ZWX", "x": 2, "y": 3, "z": 0, "w": 1},
	{"name": "ZWY", "x": 2, "y": 3, "z": 1, "w": 0},
	{"name": "WXY", "x": 3, "y": 0, "z": 1, "w": 2},
	{"name": "WXZ", "x": 3, "y": 0, "z": 2, "w": 1},
	{"name": "WYX", "x": 3, "y": 1, "z": 0, "w": 2},
	{"name": "WYZ", "x": 3, "y": 1, "z": 2, "w": 0},
	{"name": "WZY", "x": 3, "y": 2, "z": 1, "w": 0},
	{"name": "WZX", "x": 3, "y": 2, "z": 0, "w": 1}
]

# Pour initialiser les sommets de l'hypercube, et lors des resets pour les points de vue
const DEFAULT_VERTICES = [
	Vector4(-1, -1, -1, -1), Vector4(-1, -1, -1,  1), Vector4(-1, -1,  1, -1), Vector4(-1, -1,  1,  1),
	Vector4(-1,  1, -1, -1), Vector4(-1,  1, -1,  1), Vector4(-1,  1,  1, -1), Vector4(-1,  1,  1,  1),
	Vector4( 1, -1, -1, -1), Vector4( 1, -1, -1,  1), Vector4( 1, -1,  1, -1), Vector4( 1, -1,  1,  1),
	Vector4( 1,  1, -1, -1), Vector4( 1,  1, -1,  1), Vector4( 1,  1,  1, -1), Vector4( 1,  1,  1,  1)
]
