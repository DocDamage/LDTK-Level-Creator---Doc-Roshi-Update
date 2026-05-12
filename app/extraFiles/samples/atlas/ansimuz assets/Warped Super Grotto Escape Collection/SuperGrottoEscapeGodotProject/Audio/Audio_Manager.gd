extends Node2D

onready var laser_audio:AudioStreamPlayer = $Laser




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#play_music()
	pass

func play_music()->void:
	#return
	$Music.play()
	
func stop_music()->void:
	$Music.stop()
	
func play_pickimportant()->void:
	$Important.play()
	
func play_shock()->void:
	$Shock.play()
	
func play_laser()->void:
	laser_audio.play()
	
func play_explosion()->void:
	$Explosion.play()
	
func play_pickup()->void:
	$Pickup.play()
	
func play_death()->void:
	$Death.play() 
	
	
func open_terminal()->void:
	$OpenTerminal.play()
	
	
func close_terminal()->void:
	$CloseTerminal.play()
		
func play_terminal()->void:
	$Terminal.play()
	
func play_land()->void:
	$Land.play()
	
func play_error()->void:
	$Error.play()
	
func play_opendoor()->void:
	$OpenDoor.play()
	
func play_switch()->void:
	$Switch.play()
