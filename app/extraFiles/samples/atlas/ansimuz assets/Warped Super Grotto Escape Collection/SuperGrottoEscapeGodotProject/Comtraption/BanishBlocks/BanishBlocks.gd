extends StaticBody2D


onready var timer:Timer = $Timer
onready var sprite:Sprite = $Sprite
onready var collider:CollisionShape2D = $Collider

enum STATE{
	GASEOUS = 0,
	SOLID = 1,
}

export(STATE) var state:int = STATE.SOLID
export var wait_time = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = wait_time
	switch_state()
	
func switch_state()->void:
	if state == STATE.SOLID:
		state = STATE.GASEOUS
		sprite.frame = 0
		collider.disabled = 1
	elif state == STATE.GASEOUS:
		state = STATE.SOLID
		sprite.frame = 1
		collider.disabled = 0


func _on_Timer_timeout() -> void:
	if Global.flag_platforms:
		switch_state()
