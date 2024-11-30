extends Node3D

@onready var warrior_scene : PackedScene = preload("res://Scenes/monsters/AI Melee/skeleton_warrior_monster.tscn")

@onready var gridmap = $floor
@onready var gridmap_walls = $walls

func _ready():
	while $monsters.get_child_count() <10 :
		var x_pos = randi_range(-40,40)
		var z_pos = randi_range(-40,40)
		var monster_temp = warrior_scene.instantiate()
		if gridmap.get_cell_item(Vector3i(x_pos,-1,z_pos)) == 0 :
			if gridmap_walls.get_cell_item(Vector3i(x_pos,-1,z_pos))!=2:
				monster_temp.transform.origin = Vector3(x_pos,-1,z_pos)
				monster_temp.player = $player
				$monsters.add_child(monster_temp)
			
