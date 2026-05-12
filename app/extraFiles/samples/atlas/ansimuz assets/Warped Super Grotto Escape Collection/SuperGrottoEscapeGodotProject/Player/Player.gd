extends KinematicBody2D
class_name Player

const PlayerBullet:PackedScene = preload("res://Projecttiles/PlayerBullet/PlayerBullet.tscn")
const PlayerDeath: PackedScene = preload("res://Fx/PlayerDeath/PlayerDeath.tscn")


var speed := 75.0
var jump_strenght := 200.0
var gravity := 500.0



var _motion := Vector2.ZERO
var current_state := "none"

onready var label:Label = $Label
onready var sprite:AnimatedSprite = $Sprite
onready var muzzle:Position2D = $Muzzle


func _ready() -> void:
	Global.player = self
	
func get_input_vector()->Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	return input_vector

func apply_gravity(delta:float) ->  void:
	_motion.y += gravity * delta


func apply_motion(delta:float)-> void:
	_motion = move_and_slide(_motion, Vector2.UP)
	
func climb_motion(val)->void:
	_motion.y = val
	
func apply_base_movement(input_vector:Vector2, delta: float)->void:
	_motion.x = input_vector.x * speed
	
func jump()->void:
	_motion.y = -jump_strenght
	
func fire_bullet(direction:int)->void:
	var bullet = Global.instance_on_main(PlayerBullet, muzzle.global_position)
	bullet.direction = direction
	
func change_facing(direction)->void:
	if sign(direction) == -1:
		sprite.flip_h = true
		muzzle.position.x = -17
	elif sign(direction) == 1:
		sprite.flip_h = false
		muzzle.position.x = 17
		
func kill()->void:
	Global.instance_on_main(PlayerDeath, global_position)
	queue_free()




