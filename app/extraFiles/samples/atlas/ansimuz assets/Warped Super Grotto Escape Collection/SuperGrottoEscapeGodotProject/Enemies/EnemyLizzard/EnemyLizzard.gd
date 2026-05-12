extends Enemy


var speed := 35.0
var gravity := 200.0
var _motion := Vector2.ZERO


enum DIRECTION{
	LEFT = -1,
	RIGHT = 1
}

var state_direction: int

export (DIRECTION) var WALKING_DIRECTION = DIRECTION.RIGHT

onready var floorLeft: RayCast2D = $Raycasts/FloorLeft
onready var floorRight: RayCast2D = $Raycasts/FloorRight
onready var wallRight: RayCast2D = $Raycasts/WallRight
onready var wallLeft: RayCast2D = $Raycasts/WallLeft


func _ready() -> void:
	state_direction = WALKING_DIRECTION

func _physics_process(delta: float) -> void:
	_motion.y += gravity * delta 

	
	if floorLeft.is_colliding() or floorRight.is_colliding():
		direction_manager()
	
	_motion = move_and_slide(_motion, Vector2.UP)
	
	if is_on_floor():
		$Sprite.play("Run")
	else:
		$Sprite.play("Jump")

	
func jump_right()->void:
	_motion.y = -80

func direction_manager()->void:
	match state_direction:
		DIRECTION.RIGHT:
			$Sprite.flip_h = true
			_motion.x = speed
			if not floorRight.is_colliding():
				jump_right()
			if wallRight.is_colliding():
				state_direction = DIRECTION.LEFT
		DIRECTION.LEFT:
			_motion.x = -speed
			$Sprite.flip_h = false
			if not floorLeft.is_colliding() :
				jump_right()
			if wallLeft.is_colliding():
				state_direction = DIRECTION.RIGHT



func _on_HitBox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()
	
		

