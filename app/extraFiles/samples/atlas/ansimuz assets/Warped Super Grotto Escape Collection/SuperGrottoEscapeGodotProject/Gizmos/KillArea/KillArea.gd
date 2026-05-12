extends Area2D





func _on_KillArea_area_entered(area: Area2D) -> void:

	if area.owner is Player:
		area.owner.kill()
