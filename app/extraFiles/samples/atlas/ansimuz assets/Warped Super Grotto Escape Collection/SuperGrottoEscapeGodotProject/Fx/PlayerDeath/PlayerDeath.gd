extends KinematicBody2D


var _motion := Vector2.ZERO
var reload_counter:= 200

func _ready() -> void:
	
	AudioManager.stop_music()
	AudioManager.play_death()
	

	Global.lives -= 1
	Global.emit_signal("life_taken")
	_motion.y += -200

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_motion.y += 10
	_motion = move_and_slide(_motion)
	
	if reload_counter <= 0:
		if Global.lives == 0:
			get_tree().change_scene("res://Screens/GameOverScreen.tscn")
		else:
			AudioManager.play_music()
			Global.reload_game()
	reload_counter -= 1
	
func kill()->void:
	queue_free()
	

