extends Area2D

onready var sprite:Sprite = $Sprite

var state:String = "Off"

export var targetObjectPath:NodePath
export var targetObjectPath2:NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.barrier_opened:
		state = "On"
		sprite.frame = 1
		activate()
		

func activate()->void:
	var targetObject = get_node(targetObjectPath)
	var targetObject2 = get_node(targetObjectPath2)
	
	targetObject.open_barrier()
	targetObject2.open_barrier()
	Global.barrier_opened = true




func _on_SwitchBarrier_body_entered(body: Node) -> void:
	
	if state == "Off":
		state = "On"
		sprite.frame = 1
		AudioManager.play_switch()
		activate()
