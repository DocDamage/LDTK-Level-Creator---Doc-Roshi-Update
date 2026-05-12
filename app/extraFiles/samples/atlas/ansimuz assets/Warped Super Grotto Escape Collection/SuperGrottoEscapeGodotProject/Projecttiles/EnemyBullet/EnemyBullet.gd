extends Node2D

var velocity := 80
var direction := 1

const HIT_FX: PackedScene = preload("res://Fx/BulletHit/BulletHit.tscn")

func _process(delta: float) -> void:
	position.x += (velocity * direction) * delta
	if direction == -1:
		$Sprite.flip_h = true
		


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
	
# hit world
func _on_HitBox_body_entered(body: Node) -> void:
	if body is TileMap:
		kill()

# kill player
func _on_HitBox_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()
	
func kill()->void:
	Global.instance_on_main(HIT_FX, global_position)
	queue_free()
