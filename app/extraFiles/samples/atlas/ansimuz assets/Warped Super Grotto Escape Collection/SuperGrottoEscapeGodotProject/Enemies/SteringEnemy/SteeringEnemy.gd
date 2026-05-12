extends Enemy

var active_state := true
var _motion := Vector2.ZERO
var speed := 10.0
const MAX_SPEED := 80


var target_direction := Vector2.ZERO

func _process(delta: float) -> void:

	if is_instance_valid(Global.player):
		if active_state:
			chase_player(delta)
	
func chase_player(delta: float)->void:
	target_direction = target_direction.normalized()
	_motion += target_direction * speed * 0.5
	_motion = _motion.clamped(MAX_SPEED)
	_motion = move_and_slide(_motion)
	$Sprite.flip_h = global_position < Global.player.global_position
	

func _on_Timer_timeout() -> void:
	if active_state:
		active_state = false
		$Sprite.play("Idle")
	else:
		if is_instance_valid(Global.player):
			target_direction = Global.player.global_position - global_position
		active_state = true
		$Sprite.play("Chasing")
		


func _on_HitBox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()
