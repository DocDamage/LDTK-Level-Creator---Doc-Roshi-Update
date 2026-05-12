extends Enemy

var speed := 35.0
var gravity := 180.0
var _motion := Vector2.ZERO


enum DIRECTION{
	LEFT = -1,
	RIGHT = 1,
	IDLE = 0
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
	
	if _motion.x == 0:
		$Sprite.play("Idle")
	else:
		$Sprite.play("Walk")
	
func direction_manager()->void:
	match state_direction:
		DIRECTION.RIGHT:
			$Sprite.flip_h = false
			_motion.x = speed
			if not floorRight.is_colliding() or wallRight.is_colliding():
				state_direction = DIRECTION.LEFT
		DIRECTION.LEFT:
			_motion.x = -speed
			$Sprite.flip_h = true
			if not floorLeft.is_colliding() or wallLeft.is_colliding():
				state_direction = DIRECTION.RIGHT
		DIRECTION.IDLE:
			_motion.x = 0
			if !is_instance_valid(Global.player):
				return
			if Global.player.global_position.x < global_position.x:
				$Sprite.flip_h = true
			else:
				$Sprite.flip_h = false




func _on_HitBox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()
