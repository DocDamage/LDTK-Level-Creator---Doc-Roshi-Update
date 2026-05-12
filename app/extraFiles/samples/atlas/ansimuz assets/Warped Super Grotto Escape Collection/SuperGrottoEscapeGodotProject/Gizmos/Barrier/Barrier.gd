extends Node2D

var initPos := Vector2.ZERO



func _ready()->void:
	initPos = global_position

func open_barrier()->void:
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property($Sprite, "position", Vector2(0, -16), 0.5)


