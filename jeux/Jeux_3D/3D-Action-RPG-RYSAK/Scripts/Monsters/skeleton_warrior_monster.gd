extends CharacterBody3D



const JUMP_VELOCITY = 4.5


var speed := 1.0

@onready var item_object_scene = preload("res://Scenes/item_object.tscn")
@onready var state_controller = get_node("StateMachine")
@export var player : CharacterBody3D
var direction : Vector3
var awakening := false
var attacking := false
var health := 4 
var damage := 4 
var dying := false
var just_hit := false


func _ready():
	state_controller.change_state("Idle")
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if !player.is_dying : 
		direction = (player.global_transform.origin - self.global_transform.origin).normalized()
	move_and_slide()


func _on_chase_player_detection_body_entered(body):
	if body.is_in_group("player") and !dying : 
		state_controller.change_state("Run")
	


func _on_chase_player_detection_body_exited(body):
	if body.is_in_group("player") and !dying : 
		state_controller.change_state("Idle")


func _on_attack_player_body_entered(body):
	if body.is_in_group("player") and !dying : 
		state_controller.change_state("Attack")

func _on_attack_player_body_exited(body):
	if body.is_in_group("player") and !dying : 
		state_controller.change_state("Run")


func _on_animation_tree_animation_finished(anim_name):
	if "Awaken" in anim_name : 
		awakening = false
	elif "Attack" in anim_name : 
		if (player in get_node("attack_player").get_overlapping_bodies() and !dying):
			state_controller.change_state("Attack")
		elif "Death" in anim_name:
			death()

func death():
	var rng = randi_range(2,4)
	for i in rng : 
		var item_object_temp = item_object_scene.instantiate()
		item_object_temp.transform.origin = self.global_position
		get_node("../../items").add_child(item_object_temp)
	Game.gain_exp(100)
	$Skeleton_Warrior.hide()
	$"HIT VFX2/AnimationPlayer".play("hit")
	

func hit(damage : int):
	if !just_hit:
		just_hit = true
		$just_hit.start()
		$"HIT VFX/AnimationPlayer".play("hit")
		health -= damage
		if health <= 0 :
			state_controller.change_state("Death")
		#knockback
		var tween = create_tween()
		tween.tween_property(self,"global_position",global_position - (direction/1.5),0.2)
		


func _on_just_hit_timeout():
	just_hit = false


func _on_hit_area_body_entered(body):
	if body.is_in_group("player") and attacking : 
		body.hit(10)


func _on_animation_player_animation_finished(anim_name):
	self.queue_free()
