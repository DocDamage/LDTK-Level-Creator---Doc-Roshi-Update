extends Area2D

onready var sprite:Sprite = $Sprite

var state:String = "Off"
export var targetObjectPath:NodePath


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.door_opened:
		state = "On"
		sprite.frame = 1
		activate()
		
	



func activate()->void:
	var targetObject = get_node(targetObjectPath)
	
	targetObject.queue_free()
	Global.door_opened = true


func _on_Switch_body_entered(body: Node) -> void:
	if state == "Off":
		state = "On"
		sprite.frame = 1
		AudioManager.play_switch()
		activate()



