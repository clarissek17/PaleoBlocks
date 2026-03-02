extends TextureRect
@onready var texture_rect: TextureRect = $"."


var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	var random_int = rng.randi_range(1,4)
	if random_int == 1:
		texture_rect.texture = load("res://assets/Level_1_Resized 2.png")
	if random_int == 2:
		texture_rect.texture = load("res://assets/Level_2_Resized.png")
	if random_int == 3:
		texture_rect.texture = load("res://assets/Level_3_Resized.png")
	if random_int == 4:
		texture_rect.texture = load("res://assets/Level_4.png")
