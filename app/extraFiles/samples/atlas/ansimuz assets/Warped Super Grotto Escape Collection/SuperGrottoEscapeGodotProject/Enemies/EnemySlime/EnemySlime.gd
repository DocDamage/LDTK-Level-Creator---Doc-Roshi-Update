extends Enemy


export var MAX_SPEED := 25.0

enum DIRECTION{
	LEFT=-1,
	RIGHT=1
}
export(DIRECTION) var WALKING_DIRECTION = DIRECTION.RIGHT


onready var floorCast:RayCast2D = $FloorCast
onready var wallCast:RayCast2D = $WallCast




func _ready() -> void:
	wallCast.cast_to.x *= WALKING_DIRECTION
	if WALKING_DIRECTION == DIRECTION.RIGHT:
		$Sprite.flip_h = true
	
func _physics_process(delta: float) -> void:
	if wallCast.is_colliding():
		global_position = wallCast.get_collision_point()
		var normal = wallCast.get_collision_normal()
		rotation = normal.rotated(deg2rad(90)).angle()
	else:
		floorCast.rotation_degrees =- MAX_SPEED * 10 * WALKING_DIRECTION * delta
		if floorCast.is_colliding():
			global_position = floorCast.get_collision_point()
			var normal = floorCast.get_collision_normal()
			rotation = normal.rotated(deg2rad(90)).angle()
		else:
			rotation_degrees += 20 * WALKING_DIRECTION


func kill()->void:
	var temp_pos = global_position
	temp_pos.y -= 10
	Global.instance_on_main(EXPLOSION,temp_pos)
	mark_as_defeated()
	queue_free()



func _on_HitBox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()
