extends Node

var coins = 0;

var score = 0;


func _process(_delta):
	$GUI/CoinsValue.text = str(coins)
	$GUI/ScoreValue.text = str(score)
	
	

func play_sound_fx(stream : AudioStream):
	$SoundFX.stream = stream
	$SoundFX.play()
	
	
