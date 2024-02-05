extends Node2D
class_name Base

# Add main game node as reference to access its functions
@onready var game = get_node("/root/game")

# Members
@export var strength:int = 0
@export var growth_rate:float = 1.0
@export var max_strength:int = 100
@export var base_owner:int = -1
@export var connections:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	self._fill_connections()
	# Create a timer to handle the growth of the base
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 1.0 / growth_rate
	timer.autostart = true
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_handle_growth"))
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Update the strength label
	$strength_label.text = str(strength)
	# Update the base color
	if base_owner == -1:
		# If the base is not owned by anyone, paint it grey
		$circle.set_modulate(Color(0.5, 0.5, 0.5))
		return
	else:
		$circle.set_modulate(game.get_player_color(base_owner))

# Custom functions
func _handle_growth():
	# If the base is not owned by anyone, it will not grow
	if self.base_owner < 0:
		return
	self.add_strength(1)

# Get all ids from 'connections' array, return their node references and replace them in the array
func _fill_connections():
	var new_connections = []
	for i in range(connections.size()):
		var node = game.get_node(connections[i])
		if node != null:
			new_connections.append(node)
	connections = new_connections

# Public functions
func add_strength(amount:int):
	strength += amount
	if strength > max_strength:
		strength = max_strength

func remove_strength(amount:int):
	strength -= amount
	if strength < 0:
		strength = 0

func get_strength():
	return strength

func get_player_owner():
	return base_owner

func set_player_owner(new_owner:int):
	# Make sure the new owner is valid
	if new_owner != base_owner && game.get_player(new_owner) != null:
		base_owner = new_owner

func get_connections():
	return connections
