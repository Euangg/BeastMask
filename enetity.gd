class_name Entity
extends CharacterBody2D

signal dead

enum Direction{LEFT=-1,RIGHT=1}
@export var direction:Direction=Direction.RIGHT:
	set(v):
		direction=v
		if not is_node_ready():await ready
		%Graphic.scale.x=direction

static var gravity=4800

var is_hurted:bool=false
var direction_hurt:Direction

@export var hp:float=100


func sig_dead():dead.emit()
