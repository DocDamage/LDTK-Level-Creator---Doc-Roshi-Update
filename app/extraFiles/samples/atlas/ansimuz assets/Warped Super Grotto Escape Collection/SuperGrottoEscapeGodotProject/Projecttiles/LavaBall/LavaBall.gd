extends KinematicBody2D


var init_Y := 0.0
var _motion = Vector2.ZERO
var gravity := 10.0
var counter := 150

export var jump_vel := 350

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.flag_help_blocks:
		queue_free()
	init_Y = global_position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	if global_position.y > init_Y:
		_motion.y = 0
	else:
		_motion.y += gravity 
		
		
		
	if counter <= 0:
		_motion.y = -jump_vel
		counter = 150
	else:
		counter -= 1
		
	_motion = move_and_slide(_motion)


func _on_HitBox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()
