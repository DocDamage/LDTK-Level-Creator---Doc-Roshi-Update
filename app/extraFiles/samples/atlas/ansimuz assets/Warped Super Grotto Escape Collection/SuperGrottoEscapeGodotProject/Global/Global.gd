extends Node

var debug_mode := false

var player = null
var spawn_point := "none"
var lives := 3
var batteries_array := []
var lives_taken_array := []
var max_battery := 6
var batteries_charged := 0
var UI = null



var enemies_defeated_array := []
var repair_pieces_taken_array := []
var door_opened := false
var barrier_opened := false


var current_card := "none"

var flag_ladder := false
var ladder_position := Vector2.ZERO

var flag_spikes_disabled := false

var flag_platforms := false

var flag_help_blocks := false

signal energy_taken()
signal piece_taken()
signal card_taken()
signal life_taken()
signal help_blocks_activated()


func reset_values()->void:
	spawn_point = "none"
	lives = 3
	batteries_array = []
	lives_taken_array = []
	batteries_charged = 0

	enemies_defeated_array = []
	repair_pieces_taken_array = []
	door_opened = false
	barrier_opened = false
	current_card = "none"
	flag_ladder = false
	flag_spikes_disabled = false
	flag_platforms = false
	flag_help_blocks = false

func _unhandled_input(event: InputEvent) -> void:
	if debug_mode:
		if event.is_action_released("reset"):
			reload_game()
		if event.is_action_released("lives"):
			Global.lives += 1
			Global.emit_signal("life_taken")
			AudioManager.play_pickup()

func instance_on_main(scene, position)->PackedScene:
	var main = get_tree().current_scene
	var instance = scene.instance()
	main.call_deferred("add_child", instance)
	instance.global_position = position
	return instance

func reload_game()->void:
	get_tree().reload_current_scene()
