extends Node2D
class_name Glider

var player_owner : int
var game : Node
var target : Node2D
var speed = 50

func _ready():
    game = get_tree().get_root().get_node("game")
    self.z_index = 50

func _process(delta):
    $sprite.set_modulate(game.get_player_color(player_owner))
    self.position = position.move_toward(target.get_position(), delta * speed)
    var angle_to_target = global_position.direction_to(target.get_position()).angle()
    rotation = move_toward(rotation, angle_to_target, delta * speed)
    if global_position.distance_to(target.get_position()) < 10:
        if target.get_strength() == 0:
            if target.player_owner != self.player_owner:
                target.player_owner = self.player_owner
            elif target.player_owner == self.player_owner:
                target.add_strength(1)
        else:
            if target.player_owner == self.player_owner:
                target.add_strength(1)
            else:
                target.remove_strength(1)
        queue_free()

func start(base:Base):
    target = base
