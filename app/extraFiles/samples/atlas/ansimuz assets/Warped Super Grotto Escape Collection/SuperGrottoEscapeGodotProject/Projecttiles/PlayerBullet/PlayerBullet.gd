extends Node2D

var velocity := 200
var direction := 1

const HIT_FX: PackedScene = preload("res://Fx/BulletHit/BulletHit.tscn")

func _ready() -> void:
	Global.batteries_charged -= 1
	Global.emit_signal("energy_taken")
	AudioManager.play_laser()

func _process(delta: float) -> void:
	position.x += (velocity * direction) * delta
	if direction == -1:
		$Sprite.flip_h = true

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
	

# collide with world
func _on_HitBox_body_entered(body: Node) -> void:
	if body is TileMap:
		kill()

# kill enemies
func _on_HitBox_area_entered(area: Area2D) -> void:
	area.owner.kill()
	queue_free()

# destroy bullet
func kill()->void:
	Global.instance_on_main(HIT_FX, global_position)
	queue_free()
