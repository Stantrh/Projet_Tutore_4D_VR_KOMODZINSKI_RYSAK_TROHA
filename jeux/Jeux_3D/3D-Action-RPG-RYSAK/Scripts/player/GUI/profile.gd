extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("stats_label").text = "
	Player Health: %s/%s
	Player Attack: %s
	Player Defense: %s
	Player Level: %s
	Player EXP: %s/%s" % [Game.player_health, Game.player_health_max, Game.player_damage, Game.player_defense, Game.player_level,Game.current_exp,Game.exp_to_next_level]
