extends Area2D


export var msg: = 1





func _on_Terminal_body_exited(body: Node) -> void:
	Global.UI.close_terminal()


func _on_Terminal_body_entered(body: Node) -> void:
	Global.UI.open_terminal(msg)
