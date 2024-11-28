extends CharacterBody2D

const SPEED = 600.0
const JUMP_FORCE = -1900.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE
	
	var run_multiplier = 1 
	
	if Input.is_action_pressed("run"):
		run_multiplier = 2;
	else :
		run_multiplier = 1;
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * run_multiplier)
	
	if velocity.x <0 :
		$AnimatedSprite2D.flip_h = true
		
	
	if velocity.x > 0 :
		$AnimatedSprite2D.flip_h = false
	
	if velocity.x != 0 :
		$AnimatedSprite2D.play("walk")
	else : 
		$AnimatedSprite2D.play("idle")
	move_and_slide()
	
	if Input.is_action_just_pressed("magic"):
		var magic_node = load("res://scenes/magic_area.tscn")
		var new_magic = magic_node.instantiate()
		if $AnimatedSprite2D.flip_h == false :
			new_magic.direction = -1
		else : 
			new_magic.direction = 1;
		new_magic.set_position($MagicSpawnPoint.global_transform.origin)
		get_parent().add_child(new_magic)


func killPlayer():
	position = %RespawnPoint.position
	$AnimatedSprite2D.flip_h = false

func _on_death_area_body_entered(body):
	killPlayer()
