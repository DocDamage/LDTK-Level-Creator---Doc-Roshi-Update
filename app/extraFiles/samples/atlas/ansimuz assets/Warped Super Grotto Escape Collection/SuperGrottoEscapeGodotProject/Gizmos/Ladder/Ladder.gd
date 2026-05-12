extends Area2D


func _on_Ladder_body_entered(body: Node) -> void:
	if body is Player:
		Global.flag_ladder = true
		Global.ladder_position = global_position


func _on_Ladder_body_exited(body: Node) -> void:
	if body is Player:
		Global.flag_ladder = false
