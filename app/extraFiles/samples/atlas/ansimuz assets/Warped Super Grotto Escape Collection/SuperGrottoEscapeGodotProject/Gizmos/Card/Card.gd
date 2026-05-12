extends Area2D


onready var sprite:Sprite = $Sprite

export var color := "green"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if color == "green":
		sprite.frame = 1
	elif color == "red":
		sprite.frame = 2
	elif color == "blue":
		sprite.frame = 3


func _on_Card_body_entered(body: Node) -> void:
	Global.current_card = color
	Global.emit_signal("card_taken")
	AudioManager.play_pickup()
