extends Area2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_marked_as_taken():
		queue_free()



	
func mark_as_taken()->void:
	var id = get_unique_id()
	Global.batteries_array.push_back(id)
	
func get_unique_id()->String:
	return owner.name + "_" + name
	
func is_marked_as_taken()->bool:
	var id = get_unique_id()
	return Global.batteries_array.has(id)


func _on_Battery_body_entered(body: Node) -> void:
	if Global.batteries_charged >= Global.max_battery:
		return
	
	Global.batteries_charged += 1
	mark_as_taken()
	Global.emit_signal("energy_taken")
	AudioManager.play_pickup()
	queue_free()
