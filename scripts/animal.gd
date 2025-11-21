extends Node2D


@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

var range = 10

func _ready():
	anim.play("idle")
