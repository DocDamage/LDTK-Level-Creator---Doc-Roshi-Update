extends Area2D

export (String, FILE, "*.tscn") var new_level_path = ""
export var spawn_point := "none"




func _on_LevelZone_body_entered(body: Node) -> void:
	Global.spawn_point = spawn_point
	get_tree().change_scene(new_level_path)
