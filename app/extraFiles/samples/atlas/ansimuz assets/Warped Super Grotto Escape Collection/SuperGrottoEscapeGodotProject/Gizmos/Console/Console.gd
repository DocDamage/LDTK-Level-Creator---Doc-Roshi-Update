extends Area2D

onready var door:StaticBody2D = $Door

func _on_Terminal_body_entered(body: Node) -> void:
	
	
	if Global.repair_pieces_taken_array.size() >= 14: # total 14:
		
		if is_instance_valid(door):
			door.queue_free() 
			AudioManager.play_pickimportant()
			Global.UI.open_terminal(7)
			
	else:
		Global.UI.open_terminal(6)



func _on_Terminal_body_exited(body: Node) -> void:
	Global.UI.close_terminal()
