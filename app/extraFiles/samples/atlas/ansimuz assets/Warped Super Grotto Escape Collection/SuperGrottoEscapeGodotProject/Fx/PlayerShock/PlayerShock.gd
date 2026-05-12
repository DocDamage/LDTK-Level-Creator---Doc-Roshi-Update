extends KinematicBody2D


var _motion := Vector2.ZERO
var reload_counter:= 200

func _ready() -> void:
	AudioManager.play_shock()
	_motion.y += -200
	_motion.x -= 30

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_motion.y += 10
	_motion = move_and_slide(_motion)
	
	if reload_counter <= 0:
		get_tree().change_scene("res://Screens/GameOverScreen.tscn")
	


