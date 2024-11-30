extends Node


var AIController


func _ready():
	AIController = get_parent().get_parent()
	if AIController.awakening : 
		await  AIController.get_node("AnimationTree").animation_finished
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Death")
	AIController.dying = true; 
	await  AIController.get_node("AnimationTree").animation_finished	
	AIController.death()
	
func _physics_process(delta):
	if AIController : 
		AIController.velocity.x = 0;
		AIController.velocity.z = 0;
