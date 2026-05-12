extends Area2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_marked_as_taken():
		queue_free()



	
func mark_as_taken()->void:
	var id = get_unique_id()
	Global.lives_taken_array.push_back(id)
	
func get_unique_id()->String:
	return owner.name + "_" + name
	
func is_marked_as_taken()->bool:
	var id = get_unique_id()
	return Global.lives_taken_array.has(id)






func _on_Life_body_entered(body: Node) -> void:

	Global.lives += 1
	mark_as_taken()
	Global.emit_signal("life_taken")
	AudioManager.play_pickup()
	queue_free()
