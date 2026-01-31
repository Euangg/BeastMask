class_name Level
extends Node2D

@onready var enter_point: Node = $NodeEnterPoint
@onready var lt: Marker2D = $NodeCameraRange/LT
@onready var rb: Marker2D = $NodeCameraRange/RB


func _on_enemy_stone_15_dead() -> void:Global.switch_scene(Global.UI_PASS)
