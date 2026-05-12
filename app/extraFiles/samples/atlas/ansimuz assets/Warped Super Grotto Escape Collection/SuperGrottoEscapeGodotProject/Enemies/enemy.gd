extends KinematicBody2D
class_name Enemy

""" 
This class contains common methods for the KinematicBody2D enemies 
"""

const EXPLOSION: PackedScene = preload("res://Fx/Explosion/Explosion.tscn")

func _ready() -> void:
	if is_marked_as_defeated():
		queue_free()

func kill()->void:
	Global.instance_on_main(EXPLOSION,global_position)
	mark_as_defeated()
	queue_free()

func mark_as_defeated()->void:
	var id = get_unique_id()
	Global.enemies_defeated_array.push_back(id)
	
func get_unique_id()->String:
	return owner.name + "_" + name
	
func is_marked_as_defeated()->bool:
	var id = get_unique_id()
	return Global.enemies_defeated_array.has(id)
