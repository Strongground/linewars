extends Node2D

@export var players:Array = []
var player_template = {
	"name": "Player 1",
	"strength": 1, # Only used for AI players
	"color": Color(0, 0, 1)
}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_player("Player 1", Color(0, 0, 1))
	self.add_player("Player 2", Color(1, 0, 0))
	# Quick & Dirty assign bases to players
	self.get_node("base").set_player_owner(0)
	self.get_node("base4").set_player_owner(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func add_player(player_name:String, color:Color, strength:int = 1):
	var new_player = player_template.duplicate()
	new_player.name = player_name
	new_player.color = color
	new_player.strength = strength
	players.append(new_player)

func get_player(id:int):
	if id < 0 or id >= players.size():
		return null
	return players[id]

func get_player_color(id:int):
	var player = self.get_player(id)
	if player == null:
		return null
	return player.color

# Paint connecting lines between bases, according to the bases "connections" property
func _draw():
	for i in range(self.get_child_count()):
		var node = self.get_child(i)
		if node is Base:
			for j in range(node.get_connections().size()):
				var target = node.get_connections()[j]
				draw_line(node.global_position, target.global_position, Color(1,1,1,0.25), 2, true)
