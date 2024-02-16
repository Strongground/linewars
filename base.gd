extends Node2D
class_name Base

# Add main game node as reference to access its functions
@onready var game = get_node("/root/game")

# Members
@export var strength:int = 0
@export var growth_rate:float = 1.0
@export var max_strength:int = 100
@export var player_owner:int = -1
@export var connections:Array = []
var selected:bool = false

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
	self.z_index = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Update the strength label
	$strength_label.text = str(strength)
	# Update the base color
	if self.player_owner == -1:
		# If the base is not owned by anyone, paint it grey
		$circle.set_modulate(Color(0.5, 0.5, 0.5))
		return
	else:
		$circle.set_modulate(game.get_player_color(player_owner))
	# Update the selection circle
	if self.selected:
		$selection.set_visible(true)
	else:
		$selection.set_visible(false)
	# Rotate selection circle
	$selection.rotate(0.05)

# Custom functions
func _handle_growth():
	# If the base is not owned by anyone, it will not grow
	if self.player_owner < 0:
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
	return player_owner

func set_player_owner(new_owner:int):
	# Make sure the new owner is valid
	if new_owner != player_owner && game.get_player(new_owner) != null:
		player_owner = new_owner

func get_connections():
	return connections

func add_connection(node_id:String):
	# Check if connection already exists, if not add connection
	if not connections.has(node_id):
		connections.append(node_id)

func base_is_connected(base:Base):
	return connections.has(base)

func select():
	selected = true
	$selection.set_visible(true)

func deselect():
	selected = false
	$selection.set_visible(false)

# Handle clicks on the base nodes
func _on_area_2d_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT && mouse_event.pressed:
			# If the base is owned by the human player, select it
			if self.player_owner == game.get_human_player():
				game.select_base(self)
			# If the base is not owned by the human player, try to attack it
			else:
				game.attack_base(self)

func add_gliders(amount:int, target_base:Base):
	# Spawn gliders with 0.5s delay for each one, and send them to the target base
	for i in range(amount):
		var glider = preload("res://glider.tscn").instantiate()
		game.add_child(glider)
		glider.set_position(self.get_position())
		# glider.rotate_toward(target_base.get_position())
		glider.start(target_base)
		await get_tree().create_timer(0.5).timeout
