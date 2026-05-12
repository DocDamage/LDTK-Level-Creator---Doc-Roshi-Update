extends Control


onready var scroll = $scroll
var init = 392.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init = scroll.position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll.global_position.y -= 0.25
	
	if scroll.global_position.y <= -448:
		scroll.global_position.y = init
	
	
