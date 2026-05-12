extends State

const Dust: PackedScene = preload("res://Fx/LandDust/LandDust.tscn")

func unhandled_input(_event: InputEvent) -> void:
	pass
	
func physics_process(delta: float) -> void:
	
	
	
	
	var input_vector = owner.get_input_vector()
	
	owner.apply_base_movement(input_vector, delta)
	owner.change_facing(input_vector.x)
	
	owner.apply_gravity(delta)
	owner.apply_motion(delta)

	if owner.is_on_floor():
		_state_machine.transition_to("Idle")

func enter(msg: Dictionary = {}) -> void:
	owner.sprite.play("Fall")

	

func exit() -> void:
	AudioManager.play_land()
	Global.instance_on_main(Dust, owner.global_position)
	pass
