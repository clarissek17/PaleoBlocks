extends Node

var current_tetromino
@export var board: Board
@export var start_screen: TextureRect
var game_started = false

@export var game_over_screen: TextureRect

func trigger_game_over():
	game_started = false
	game_over_screen.show()
	
	# Wait for 3 seconds
	await get_tree().create_timer(3.0).timeout
	
	# Back to Start Screen
	game_over_screen.hide()
	start_screen.show()
	
	get_tree().reload_current_scene()

func _ready():
	# Ensure the board is connected to the spawner's logic
	#if board and !board.tetromino_locked.is_connected(on_tetromino_locked):
	#	board.tetromino_locked.connect(on_tetromino_locked)
	board.tetromino_locked.connect(on_tetromino_locked2)
	# Wait until the end of the frame to spawn the very first piece
	# spawn_new_piece() # so game doesnt start immediately
	#call_deferred("spawn_new_piece")

func _input(event):
	if not game_started and Input.is_key_pressed(KEY_Z):
		start_game()

func start_game():
	game_started = true
	start_screen.hide()
	board.start_board() # Initialize dirt only when starting
	spawn_new_piece()
	
	#if start_screen:
	#	start_screen.visible = false # Hide the start image
	#spawn_new_piece()

func spawn_new_piece():
	# Pick a random type and tell the board to instantiate it
	current_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false, null)


func on_tetromino_locked2():
	# When the current piece signals it is done, spawn the next one
	var new_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(new_tetromino, false, null)
		
