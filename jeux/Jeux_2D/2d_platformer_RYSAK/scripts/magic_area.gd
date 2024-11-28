extends Area2D



const SPEED = 1500
var velocity
var player_object
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	player_object = get_node("../Player").get_node("AnimatedSprite2D")
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if direction == 1 : 
		velocity = Vector2(-1,0).rotated(rotation_degrees) * SPEED * delta
		$Magic/CPUParticles2D.gravity.x = 3000
	else : 
		velocity = Vector2(1,0).rotated(rotation_degrees) * SPEED * delta
		$Magic/CPUParticles2D.gravity.x = -3000
	position += velocity

func _on_timer_timeout():
	queue_free()


func _on_area_entered(area):
	if area.is_in_group("ennemy"):
		GameManager.score += 100
		area.get_parent().queue_free()
		queue_free()
