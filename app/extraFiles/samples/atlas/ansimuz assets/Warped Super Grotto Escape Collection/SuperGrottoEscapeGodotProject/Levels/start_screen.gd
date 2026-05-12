extends Node2D


const PlayerDeath: PackedScene = preload("res://Fx/PlayerShock/PlayerShock.tscn")
const Shock: PackedScene = preload("res://Fx/Shock/Shock.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(Global.player):
		if Global.player.position.x > 200:
			Global.instance_on_main(Shock, Global.player.global_position)
			Global.instance_on_main(PlayerDeath, Global.player.global_position)
			Global.player.queue_free()
			$Timer.start()
			
	


func _on_Timer_timeout() -> void:
	get_tree().change_scene("res://Levels/FallScreen.tscn")
