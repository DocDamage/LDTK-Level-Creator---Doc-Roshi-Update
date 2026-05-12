extends AnimatedSprite

func _ready() -> void:
	play()

func _on_LandDust_animation_finished() -> void:
	queue_free()
