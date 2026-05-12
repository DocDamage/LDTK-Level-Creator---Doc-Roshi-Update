extends Area2D

onready var sprite:Sprite = $Sprite

var state:String = "Off"
 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.flag_help_blocks:
		state = "On"
		sprite.frame = 1
		activate()
		


func activate()->void:
	Global.emit_signal("help_blocks_activated")
	Global.flag_help_blocks = true



func _on_SwitchHelpBlocks_body_entered(body: Node) -> void:
	if state == "Off":
		state = "On"
		sprite.frame = 1
		AudioManager.play_switch()
		activate()
