extends Position2D

var position_clear_flag := false

func _ready() -> void:
	$Sprite.visible = false
	if Global.spawn_point == name:
		Global.player.position = position
