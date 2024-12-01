extends Sprite3D


var coins = 5
var test_name = "Robot"
var hearts := 3.5

const SPEED := 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_inputs()


	
func check_inputs():
	if Input.is_action_pressed("ui_left"): # la flèche gauche 
		# on le fait spin à gauche
		rotate_y(deg_to_rad(-SPEED))
	elif Input.is_action_pressed("ui_right"):
		rotate_y(deg_to_rad(SPEED))
