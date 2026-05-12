extends State

func unhandled_input(_event: InputEvent) -> void:
	pass
	
func physics_process(delta: float) -> void:
	
	

	var input_vector = owner.get_input_vector()
	
	if Input.is_action_pressed("ui_down"):
		if !Global.flag_ladder or owner.is_on_floor():
			_state_machine.transition_to("Fall")
		owner.climb_motion(50)
		owner.apply_motion(delta)
		
	elif Input.is_action_pressed("ui_up"):
		if !Global.flag_ladder:
			_state_machine.transition_to("Fall")
		owner.climb_motion(-50)
		owner.apply_motion(delta)
	
	
func enter(msg: Dictionary = {}) -> void:
	owner.sprite.play("Ladder")
	owner._motion.x = 0
	

func exit() -> void:
	pass
