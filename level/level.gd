class_name Level
extends Node2D
const CLAWN_COMMON = preload("uid://dmyh7ah4pxn73")

@onready var enter_point: Node = $NodeEnterPoint
@onready var lt: Marker2D = $NodeCameraRange/LT
@onready var rb: Marker2D = $NodeCameraRange/RB

func _on_enemy_stone_15_dead() -> void:Global.switch_scene(Global.UI_PASS)

func _on_dragon_taken() -> void:swicth_player("dragon")
func _on_bear_taken() -> void:swicth_player("bear")
func _on_wolf_taken() -> void:swicth_player("wolf")
	
func _ready() -> void:
	Global.node_enemy=%Node2DEnemy

func swicth_player(str_player:String):
	var node_level=get_parent()
	if node_level:
		var ui_play=node_level.get_parent()
		if ui_play:ui_play.call_deferred("switch_player",str_player)


func _on_area_2d_body_entered(body: Node2D) -> void:
	%Area2D.queue_free()
	var boss:Enemy=CLAWN_COMMON.instantiate()
	boss.position=%Marker2DSpawn.position
	boss.target_position=%Marker2DTarget.position
	boss.dead.connect(level_pass)
	Global.node_enemy.call_deferred("add_child",boss)
	
	var node_level=get_parent()
	if node_level:
		var ui_play=node_level.get_parent()
		if ui_play:ui_play.filiter()
	

func level_pass():Global.switch_scene(Global.UI_PASS)
func level_fail():Global.switch_scene(Global.UI_FAIL)
