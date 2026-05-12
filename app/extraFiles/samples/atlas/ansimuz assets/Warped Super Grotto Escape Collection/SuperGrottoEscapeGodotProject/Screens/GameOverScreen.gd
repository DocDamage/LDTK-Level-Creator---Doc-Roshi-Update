extends Control


var new_level_path = "res://Levels/Level-b-3.tscn"

var counter := 200

func _ready() -> void:
	Global.reset_values()

func _process(delta: float) -> void:
	counter -= 1

func _unhandled_key_input(event: InputEventKey) -> void:
	if counter > 0:
		return
	get_tree().change_scene(new_level_path)
