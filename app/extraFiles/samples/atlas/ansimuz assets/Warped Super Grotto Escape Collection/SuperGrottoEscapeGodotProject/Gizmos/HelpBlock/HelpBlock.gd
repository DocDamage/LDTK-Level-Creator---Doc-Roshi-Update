extends StaticBody2D


onready var collision = $collision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Global.connect("help_blocks_activated", self, "_on_help_blocks_activated")
	
	if ! Global.flag_help_blocks:
		visible = false
		collision.disabled = true
		
func _on_help_blocks_activated()->void:
	
	visible = true
	collision.disabled = false

