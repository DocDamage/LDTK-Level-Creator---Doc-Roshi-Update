extends StaticBody2D


onready var timer:Timer = $Timer
onready var sprite:Sprite = $Sprite
onready var hitAreaCollision:CollisionShape2D = $HitArea/Collision


enum STATE{
	OUT = 0,
	IN = 1
}

export(STATE) var state:int = STATE.IN
export var wait_time = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	timer.wait_time = wait_time
	switch_state()


func switch_state()->void:
	if Global.flag_spikes_disabled:
		sprite.frame = 0
		hitAreaCollision.disabled = 1
		return
	
	if state == STATE.IN:
		state = STATE.OUT
		sprite.frame = 0
		hitAreaCollision.disabled = 1
	elif state == STATE.OUT:
		state = STATE.IN
		sprite.frame = 1
		hitAreaCollision.disabled = 0


func _on_HitArea_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		area.owner.kill()


func _on_Timer_timeout() -> void:
	switch_state()
