extends CharacterBody3D

@onready var animation_tree :AnimationTree  = get_node("AnimationTree")
@onready var playback = animation_tree.get("parameters/playback")
@onready var player_mesh = get_node("Knight")

@export var gravity : float = 9.8
@export var jump_force : int = 10
@export var walk_speed: int = 3
@export var run_speed: int = 10


#animation node names

var idle_node_name: String = "Idle"
var walk_node_name: String = "Walk"
var run_node_name: String = "Run"
var jump_node_name: String = "Jump"
var attack1_node_name: String = "Attack1"
var death_node_name: String = "Death"


#State Machine Conditions

var is_attacking: bool
var is_walking: bool
var is_running: bool
var is_dying: bool


# Physics Value

var direction : Vector3
var horizontal_velocity : Vector3
var aim_turn : float
var movement : Vector3
var vertical_velocity : Vector3
var movement_speed : int
var angular_acceleration : int
var acceleration : int
var just_hit : bool


@onready var camrot_h = get_node("camroot/h")

func _ready():
	var game_node = get_node(Game.get_path())
	game_node.level_up.connect(Callable(self, "_on_level_up"))
	
	
func _input(event):
	if event is InputEventMouseMotion : 
		aim_turn = -event.relative.x * 0.015
	if event.is_action_pressed("aim"):
		direction = camrot_h.global_transform.basis.z
func _physics_process(delta):
	var on_floor = is_on_floor()
	if !is_dying : 
		attack1()
		if !on_floor : 
			vertical_velocity += Vector3.DOWN * gravity * 2 * delta
		else : 
			vertical_velocity = Vector3.DOWN * gravity/10
		
		if Input.is_action_just_pressed("jump") and !is_attacking and on_floor:
			vertical_velocity = Vector3.UP * jump_force
		angular_acceleration = 10
		movement_speed = 0
		acceleration = 15
		
		if (attack1_node_name in playback.get_current_node()):
			is_attacking = true
		else : 
			is_attacking = false
		var h_rot = camrot_h.global_transform.basis.get_euler().y
		if(Input.is_action_pressed("forward") || Input.is_action_pressed("backward") ||Input.is_action_pressed("left") || Input.is_action_pressed("right")):
			direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),0,Input.get_action_strength("forward")-Input.get_action_strength("backward"))
				
			direction = direction.rotated(Vector3.UP, h_rot).normalized()
			if Input.is_action_pressed("sprint") and (is_walking):
				movement_speed = run_speed
				is_running = true
				$VFX_puff_run.emitting = true
			else : 
				$VFX_puff_run.emitting = false
				is_walking = true
				movement_speed = walk_speed
		else :
			is_walking = false
			is_running = false	
		if Input.is_action_pressed("aim"):
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y,camrot_h.rotation.y,delta * angular_acceleration)
		else : 
			player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y,atan2(direction.x, direction.z)-rotation.y,delta * angular_acceleration)
		
		if is_attacking : 
				horizontal_velocity = horizontal_velocity.lerp(direction.normalized()*0.1, delta * acceleration)
		else : 
			horizontal_velocity = horizontal_velocity.lerp(direction.normalized()*movement_speed, delta * acceleration)

		
		velocity.z = horizontal_velocity.z  + vertical_velocity.z
		velocity.y = vertical_velocity.y
		velocity.x = horizontal_velocity.x  + vertical_velocity.x
		
		move_and_slide()
	animation_tree["parameters/conditions/IsOnFloor"] = on_floor
	animation_tree["parameters/conditions/IsInAir"] = !on_floor
	animation_tree["parameters/conditions/IsWalking"] = is_walking
	animation_tree["parameters/conditions/IsNotWalking"] = !is_walking
	animation_tree["parameters/conditions/IsRunning"] = is_running
	animation_tree["parameters/conditions/IsNotRunning"] = !is_running
	animation_tree["parameters/conditions/is_dying"] = is_dying
		
func attack1():
	if (idle_node_name in playback.get_current_node() or walk_node_name in playback.get_current_node() or run_node_name in playback.get_current_node()):
		if Input.is_action_just_pressed("attack"):
			if !is_attacking:
				playback.travel(attack1_node_name)


func _on_damage_detector_body_entered(body):
	if body.is_in_group("monster") and is_attacking: 
		$damage.play()
		body.hit(Game.player_damage)
		$"Knight/Rig/Skeleton3D/right_hand_slot/HIT VFX/AnimationPlayer".play("hit")

func hit(damage : int):
	if !just_hit : 
		just_hit = true
		$hit.play()
		$just_hit.start()
		var damage_done = damage - Game.player_defense
		if damage_done > 0 :
			Game.damage_player(damage_done)
		else :
			Game.damage_player(1)
		if Game.player_health <= 0 : 
			is_dying = true
			playback.travel(death_node_name)
		#knockback
		var tween = create_tween()
		tween.tween_property(self,"global_position",global_position - (direction/1.5),0.2)
		



func _on_just_hit_timeout():
	just_hit = false;


func _on_animation_tree_animation_finished(anim_name):
	if "Death" in anim_name : 
		await get_tree().create_timer(1).timeout
		get_node("../gameover_overlay").game_over()

func _on_level_up():
	$VFX_level_up_hugo/AnimationPlayer.play("default")