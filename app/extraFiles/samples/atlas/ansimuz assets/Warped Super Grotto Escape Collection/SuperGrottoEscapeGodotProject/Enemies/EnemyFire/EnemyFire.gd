extends EnemyNode

onready var sprite:AnimatedSprite = $Sprite
onready var muzzle:Position2D = $Muzzle


const Bullet:PackedScene = preload("res://Projecttiles/EnemyBullet/EnemyBullet.tscn")

var fire_flag := true

enum SPEEDS{
	SLOW,
	MEDIUM
}

export(SPEEDS) var speed = SPEEDS.MEDIUM

enum DIRECTION{
	LEFT = -1,
	RIGHT = 1
}

var state_direction: int

export (DIRECTION) var FACING_DIRECTION = DIRECTION.LEFT

func _ready() -> void:
	state_direction = FACING_DIRECTION
	if state_direction == -DIRECTION.LEFT:
		$Sprite.flip_h = true
		muzzle.position.x = 17
	else:
		$Sprite.flip_h = false
		muzzle.position.x = -17
		
	if speed == SPEEDS.SLOW:
		$Sprite.play("Slow")
	else:
		$Sprite.play("Medium")

func _process(delta: float) -> void:
	if sprite.frame == 6 and fire_flag:
		fire_flag = false
		var bullet = Global.instance_on_main(Bullet, muzzle.global_position)
		bullet.direction = state_direction
	if sprite.frame == 1:
		fire_flag = true



func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()
