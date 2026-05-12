extends State

func unhandled_input(_event: InputEvent) -> void:
	pass
	
func physics_process(delta: float) -> void:
	
	if  owner._motion.y > 1:
		_state_machine.transition_to("Fall")
	
	if Global.flag_ladder:

		if Input.is_action_just_pressed("ui_up"):
			owner.global_position.x = Global.ladder_position.x
			_state_machine.transition_to("Ladder")
			
		if Input.is_action_just_pressed("ui_down"):
			owner.global_position.x = Global.ladder_position.x
			owner.global_position.y += 10
			_state_machine.transition_to("Ladder")
			

	
	var input_vector = owner.get_input_vector()
	
	owner.apply_gravity(delta)
	owner.apply_motion(delta)
	
	if input_vector.x != 0:
		_state_machine.transition_to("Run")
		
	if Input.is_action_just_pressed("jump") and owner.is_on_floor():
		_state_machine.transition_to("Jump")
		
	if Input.is_action_just_pressed("fire") and owner.is_on_floor():
		if Global.batteries_charged > 0:
			_state_machine.transition_to("Fire")
			
	
	
func enter(msg: Dictionary = {}) -> void:
	
	owner.sprite.play("Idle")
	owner._motion.x = 0
	
	
	

func exit() -> void:
	pass
