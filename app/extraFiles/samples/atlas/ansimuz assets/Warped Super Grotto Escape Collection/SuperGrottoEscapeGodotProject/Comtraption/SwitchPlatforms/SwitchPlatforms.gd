extends Area2D

onready var sprite:Sprite = $Sprite

var state:String = "Off"
 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.flag_platforms:
		state = "On"
		sprite.frame = 1
		activate()
		


func activate()->void:
	
	Global.flag_platforms = true


func _on_SwitchPlatforms_body_entered(body: Node) -> void:
	if state == "Off":
		state = "On"
		sprite.frame = 1
		AudioManager.play_switch()
		activate()
