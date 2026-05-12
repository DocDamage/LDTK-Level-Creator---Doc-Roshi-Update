extends State

func unhandled_input(_event: InputEvent) -> void:
	pass
	
func physics_process(delta: float) -> void:
	
	
	var input_vector = owner.get_input_vector()
	
	owner.apply_base_movement(input_vector, delta)
	owner.change_facing(input_vector.x)
	
	owner.apply_gravity(delta)
	owner.apply_motion(delta)

	if owner._motion.y > 10:
		_state_machine.transition_to("Fall")

func enter(msg: Dictionary = {}) -> void:
	owner.sprite.play("Jump")
	owner.jump()
	

func exit() -> void:
	pass
