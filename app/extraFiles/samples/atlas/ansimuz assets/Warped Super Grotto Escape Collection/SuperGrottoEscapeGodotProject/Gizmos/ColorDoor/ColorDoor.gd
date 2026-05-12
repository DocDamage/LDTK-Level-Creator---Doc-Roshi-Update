extends Area2D


onready var sprite:Sprite = $Sprite

export var color := "green"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if color == "blue":
		sprite.frame = 0
	elif color == "green":
		sprite.frame = 1
	elif color == "red":
		sprite.frame = 2


func _process(delta: float) -> void:
	
	if is_instance_valid( Global.player):
		if overlaps_body(Global.player):
			
			if Input.is_action_just_pressed("ui_up"):
				
				if Global.current_card == "green" and color == "green":
					get_tree().change_scene("res://Levels/Level-green-room.tscn")
					AudioManager.play_opendoor()
				elif Global.current_card == "blue" and color == "blue":
					get_tree().change_scene("res://Levels/Level-blue-room.tscn")
					AudioManager.play_opendoor()
				elif Global.current_card == "red" and color == 'red':
					get_tree().change_scene("res://Levels/Level-red-room.tscn")
					AudioManager.play_opendoor()
				else:
					AudioManager.play_error()





func _on_ColorDoor_body_entered(body: Node) -> void:
	$Arrow.visible =true
	
	


func _on_ColorDoor_body_exited(body: Node) -> void:
	$Arrow.visible = false
