extends Node2D

func _ready() -> void:
	Global.player=%Wolf
	Global.player.dead.connect(level_fail)
	Global.node_enemy=self
	%ClawnCommon.target_position=%Marker2D.position
	%ClawnCommon.dead.connect(level_pass)
	
func _physics_process(delta: float) -> void:
	pass
	#if Input.is_action_just_pressed("space"):%PointEnemy.spawn()

func level_pass():Global.switch_scene(Global.UI_PASS)
func level_fail():Global.switch_scene(Global.UI_FAIL)
