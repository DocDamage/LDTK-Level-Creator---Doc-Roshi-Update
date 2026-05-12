extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Player.rotation += 0.1
	$Player.position.y += 2


func _on_Timer_timeout() -> void:
	AudioManager.play_music()
	get_tree().change_scene("res://Levels/Level-b-3.tscn")
