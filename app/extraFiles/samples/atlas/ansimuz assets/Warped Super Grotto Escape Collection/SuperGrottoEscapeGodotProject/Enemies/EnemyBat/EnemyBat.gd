extends EnemyNode


var speed := 55.0

onready var wallLeft: RayCast2D = $WallLeft
onready var wallRight: RayCast2D = $WallRight



enum DIRECTION{
	LEFT = -1,
	RIGHT = 1
}

export (DIRECTION) var FLYING_DIRECTION = DIRECTION.LEFT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FLYING_DIRECTION == DIRECTION.RIGHT:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	
	match FLYING_DIRECTION:
		DIRECTION.LEFT:
			position.x += speed * FLYING_DIRECTION * delta
			$Sprite.flip_h = false 
			if wallLeft.is_colliding():
				FLYING_DIRECTION = DIRECTION.RIGHT
		DIRECTION.RIGHT:
			position.x += speed * FLYING_DIRECTION * delta
			$Sprite.flip_h = true 
			if wallRight.is_colliding():
				FLYING_DIRECTION = DIRECTION.LEFT



func _on_HitBox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()
