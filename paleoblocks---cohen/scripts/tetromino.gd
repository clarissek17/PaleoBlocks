extends Node2D

class_name Tetromino

signal lock_tetromino(tetromino: Tetromino)

var bounds = {
	"min_x": -80,
	"max_x": 80,
	"max_y": 160
}

var hittingatetronimo = false
var rotation_index = 0
var wall_kicks
var tetromino_data
var is_next_piece
var pieces = []
var other_tetrominos: Array[Tetromino] = []

@onready var timer: Timer = $Timer

@onready var piece_scene = preload("res://scenes/piece.tscn")

var tetromino_cells
func _ready():
	tetromino_cells = Shared.cells[tetromino_data.tetromino_type]
	
	for cell in tetromino_cells:
		var piece = piece_scene.instantiate() as Piece 
		pieces.append(piece)
		add_child(piece)
		piece.set_texture(tetromino_data.piece_texture)
		piece.position = cell * piece.get_size()
		
	if is_next_piece == false:
		position = tetromino_data.spawn_position
		wall_kicks = Shared.wall_kicks_i if tetromino_data.tetromino_type == Shared.Tetromino.I else Shared.wall_kicks_jlostz


func _input(event):
	
	#if not get_parent().get_node("PieceSpawner").game_started:
		#return
	
	if Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("down"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("hard_drop"):
		hard_drop()
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_tetromino(-1)
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_tetromino(1)

func move(direction: Vector2) -> bool:
	### NEW CODE
	is_colliding_with_dirt(direction, global_position)
	var dirt_hit = collidingdirts
	

	
	###
	var new_position = calculate_global_position(direction, global_position)
	if dirt_hit:
		# If moving DOWN and we hit dirt
		if direction == Vector2.DOWN:
			if hittingatetronimo == false:
				remove_dirt(collidingdirts)
				# Move down one last time and lock
				
				global_position += direction * pieces[0].get_size().x
				lock()
				return false
		return false # Block sideways movement into dirt
	if new_position:
		global_position = new_position
		return true
	return false

### NEW CODE
func remove_dirt(dirt_block):
	for i in dirt_block.size():
		get_parent().dirt_blocks.erase(dirt_block[i])
		dirt_block[i].queue_free()
	collidingdirts.clear()
	
	# Win Condition: Check if all dirt is gone
	if get_parent().dirt_blocks.size() == 0:
		print("You cleared the dirt! You win!")
###

func calculate_global_position(direction: Vector2, starting_global_position: Vector2):
	#TODO CHECK POSITION WITH OTHER TETRONIMOES AND EVERTUALLY DIRT
	if is_colliding_with_other_tetrominos(direction, starting_global_position):
		return null
	
	if !is_within_game_bounds(direction, starting_global_position):
		return null
	return starting_global_position + direction * pieces[0].get_size().x
	
	
func is_within_game_bounds(direction: Vector2, starting_global_position: Vector2):
	for piece in pieces:
		var new_position = piece.position + starting_global_position + direction * piece.get_size()
		if new_position.x < bounds.get("min_x") || new_position.x > bounds.get("max_x") || new_position.y >= bounds.get("max_y"):
			return false
	return true

func is_colliding_with_other_tetrominos(direction: Vector2, starting_global_position: Vector2):
	for tetromino in other_tetrominos:
		var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece)
		for tetromino_piece in tetromino_pieces:
			for piece in pieces:
				if starting_global_position + piece.position + direction * piece.get_size().x == tetromino.global_position + tetromino_piece.position:
					hittingatetronimo = true
					print("hitting a tetronimo")
					return true
					
	hittingatetronimo = false
	return false

func rotate_tetromino(direction: int):
	var original_rotation_index = rotation_index
	if tetromino_data.tetromino_type == Shared.Tetromino.O:
		return

	apply_rotation(direction)
	
	rotation_index = wrap(rotation_index + direction, 0, 4)
	
	if!test_wall_kicks(rotation_index, direction):
		rotation_index = original_rotation_index
		apply_rotation(-direction)

func test_wall_kicks(rotation_index: int, rotation_direction: int):
	var wall_kick_index = get_wall_kick_index(rotation_index, rotation_direction)
	
	for i in wall_kicks[0].size():
		var translation = wall_kicks[wall_kick_index][i]
		if move(translation):
			return true
	return false
	
func get_wall_kick_index(rotation_index: int, rotation_direction):
	var wall_kick_index = rotation_index * 2
	if rotation_direction < 0:
		wall_kick_index -= 1
		
	return wrap(wall_kick_index, 0, wall_kicks.size())

func apply_rotation(direction: int):
	var rotation_matrix = Shared.clockwise_rotation_matrix if direction == 1 else Shared.counter_clockwise_rotation_matrix
	
	var tetromino_cells = Shared.cells[tetromino_data.tetromino_type]
	
	for i in tetromino_cells.size():
		var cell = tetromino_cells[i]
		var x
		var y
		var coordinates = rotation_matrix[0] * cell.x + rotation_matrix[1] * cell.y
		tetromino_cells[i] = coordinates
		
	for i in pieces.size():
		var piece = pieces[i]
		piece.position = tetromino_cells[i] * piece.get_size()

func hard_drop():
	while(move(Vector2.DOWN)):
		continue
	lock()
		
var delayer = 0
func lock():
	timer.stop()
	if delayer == 0:
		lock_tetromino.emit(self)
		delayer = 1
		await get_tree().create_timer(.1).timeout
		delayer = 0
	set_process_input(false)

func _on_timer_timeout() -> void:
	var should_lock = !move(Vector2.DOWN)
	if should_lock:
		lock()

var collidingdirts = []
### NEW CODE
func is_colliding_with_dirt(direction: Vector2, starting_global_position: Vector2):
	if hittingatetronimo == true:
		return null
	for dirt in get_parent().dirt_blocks: # Look at the board's dirt list
		for piece in pieces:
			# Check if the piece's next position overlaps a dirt block
			if starting_global_position + piece.position + direction * piece.get_size().x == dirt.global_position:
				#return dirt # Return the specific dirt block found
				collidingdirts.append(dirt)
	return null
###
