extends State

func unhandled_input(_event: InputEvent) -> void:
	pass
	
func physics_process(delta: float) -> void:
	
	var input_vector = owner.get_input_vector()
	
	owner.apply_base_movement(input_vector, delta)
	owner.change_facing(input_vector.x)
	
	owner.apply_gravity(delta)
	owner.apply_motion(delta)

	if Input.is_action_just_pressed("jump") and owner.is_on_floor():
		_state_machine.transition_to("Jump")
		
	if input_vector.x == 0:
		_state_machine.transition_to("Idle")
		
	if Input.is_action_just_pressed("fire") and owner.is_on_floor():
		if Global.batteries_charged > 0:
			_state_machine.transition_to("Fire")
		
	if owner._motion.y > 10:
		_state_machine.transition_to("Fall")

func enter(msg: Dictionary = {}) -> void:
	owner.sprite.play("Run")
	

func exit() -> void:
	pass
