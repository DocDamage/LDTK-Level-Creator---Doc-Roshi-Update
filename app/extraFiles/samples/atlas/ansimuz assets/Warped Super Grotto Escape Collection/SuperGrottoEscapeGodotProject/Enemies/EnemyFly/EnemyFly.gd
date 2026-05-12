extends EnemyNode


var speed := 30.0

onready var TopDetector:RayCast2D = $RayCasts/TopDetector
onready var BottomDetector:RayCast2D = $RayCasts/BottomDetector
onready var sprite:AnimatedSprite = $Sprite



enum DIRECTION{
	UP = -1,
	DOWN = 1
}

var state_direction: int

export (DIRECTION) var FLYING_DIRECTION = DIRECTION.DOWN


func _ready() -> void:
	state_direction = FLYING_DIRECTION


func _process(delta: float) -> void:
 
	match state_direction:
		DIRECTION.UP:
			position.y += speed  * state_direction * delta
			if TopDetector.is_colliding():
				state_direction = DIRECTION.DOWN
		DIRECTION.DOWN:
			position.y += speed  * state_direction * delta
			if BottomDetector.is_colliding():
				state_direction = DIRECTION.UP
				
	face_player()
	

func face_player()->void:
	if  is_instance_valid(Global.player):
		if Global.player.position.x < position.x:
			sprite.flip_h = false
		else:
			sprite.flip_h = true



func _on_HitBox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()
