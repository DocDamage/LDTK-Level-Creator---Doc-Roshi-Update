extends State

var fire_flag := false

func unhandled_input(_event: InputEvent) -> void:
	pass
	
func physics_process(delta: float) -> void:


	if owner.sprite.frame == 3 and fire_flag == false:
		fire_flag = true
		
		owner.fire_bullet(get_bullet_direction())
		
	if owner.sprite.frame >= 4  and fire_flag:
		_state_machine.transition_to("Idle")
		

func get_bullet_direction():
	return  -1 if owner.sprite.flip_h else 1
	
func enter(msg: Dictionary = {}) -> void:
	owner.sprite.play("Fire")
	fire_flag = false
	
	

func exit() -> void:
	pass




