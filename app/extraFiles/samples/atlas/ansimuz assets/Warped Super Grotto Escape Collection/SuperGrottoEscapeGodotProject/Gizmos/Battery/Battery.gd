extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_marked_as_taken():
		queue_free()



	
func mark_as_taken()->void:
	var id = get_unique_id()
	Global.repair_pieces_taken_array.push_back(id)
	
func get_unique_id()->String:
	return owner.name + "_" + name
	
func is_marked_as_taken()->bool:
	var id = get_unique_id()
	return Global.repair_pieces_taken_array.has(id)




func _on_Battery_body_entered(body: Node) -> void:
	mark_as_taken()
	Global.emit_signal("piece_taken")
	AudioManager.play_pickimportant()
	queue_free()
