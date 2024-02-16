extends Node2D

@export var players:Array = []
var player_template = {
	"name": "Player 1",
	"strength": 1, # Only used for AI players
	"color": Color(0, 0, 1),
	"human_player": true
}
var selected_base:Base = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_player("Player 1", Color(0, 0, 1))
	self.add_player("Player 2", Color(1, 0, 0), 1, false)
	# Quick & Dirty assign bases to players
	self.get_node("base").set_player_owner(0)
	self.get_node("base4").set_player_owner(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func add_player(player_name:String, color:Color, strength:int = 1, human_player:bool = true):
	var new_player = player_template.duplicate()
	new_player.name = player_name
	new_player.color = color
	new_player.strength = strength
	new_player.human_player = human_player
	players.append(new_player)

func get_player(id:int):
	if id < 0 or id >= players.size():
		return null
	return players[id]

# Return the index of the human player
func get_human_player():
	for i in range(players.size()):
		if players[i].human_player:
			return i
	return -1

func get_player_color(id:int):
	var player = self.get_player(id)
	if player == null:
		return null
	return player.color

func select_base(base:Base):
	if self.selected_base != null && self.selected_base != base:
		self.selected_base.deselect()
	var player_owner = self.get_player(base.get_player_owner())
	if player_owner.human_player:
		# Deselect previous selected base
		self.selected_base = base
		base.select()

func attack_base(base:Base):
	# Only allow attacking if a base is selected
	if self.selected_base == null:
		return
	# Only allow attacking if the selected base is owned by the human player
	# and if the two bases are connected by a path
	var player_owner = self.get_player(self.selected_base.get_player_owner())
	if player_owner.human_player && self.selected_base.base_is_connected(base) && base.base_is_connected(self.selected_base):
		var attacking_base = self.selected_base
		var attack_size = attacking_base.strength
		var defending_base = base
		# Decrease the strength of the selected base by its current strength
		attacking_base.remove_strength(attack_size)
		attacking_base.add_gliders(attack_size, defending_base)
