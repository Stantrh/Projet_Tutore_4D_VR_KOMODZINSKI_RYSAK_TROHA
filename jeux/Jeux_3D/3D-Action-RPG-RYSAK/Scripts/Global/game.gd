extends Node


signal health_changed(damage)
signal level_up()
var items : Dictionary = {
	"long sword": preload("res://Scenes/Player/GUI/inventory/long_sword.tres"),
	"iron sword": preload("res://Scenes/Player/GUI/inventory/iron_sword.tres"),
	"small potion": preload("res://Scenes/Player/GUI/inventory/small_potion.tres"),
	"iron body": preload("res://Scenes/Player/GUI/inventory/iron_body.tres")
}

var gold := 100
var player_health : int = 5
var player_health_max : int = 5
var right_hand_equipped : ItemData
var body_equiped: ItemData


var player_damage: int = 0
var player_defense : int = 0
var current_exp : int = 0
var exp_to_next_level : int = 100
var player_level: int = 1 

var shopping : bool = false

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func damage_player(amount : int)-> void : 
	self.emit_signal("health_changed",amount)
	player_health -= amount
func heal_player(amount : int)-> void : 
	self.emit_signal("health_changed",-amount)
	player_health += amount
	if player_health > player_health_max : 
		player_health = player_health_max

func _process(delta):
	player_damage = right_hand_equipped.item_damage + body_equiped.item_damage
	player_defense =  right_hand_equipped.item_defense + body_equiped.item_defense

func gain_exp(amount : int):
	current_exp += amount
	while current_exp >= exp_to_next_level:
		self.emit_signal("level_up")
		player_level += 1 
		player_health_max += player_level * 10
		player_health = player_health_max
		current_exp -= exp_to_next_level
		exp_to_next_level = round(exp_to_next_level * 1.3)
		exp_to_next_level= exp_to_next_level * pow(1.2, player_level-1)
		
