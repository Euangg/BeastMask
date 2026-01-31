extends Control

var player:Entity=null
@onready var camera_2d: Camera2D = %Camera2D
var dict_level={
	"level_1":preload("uid://do05lhdu1wb7n"),
	"level_2":preload("uid://cp7qtitcteb3r"),
}
var dict_player={
	"monkey":preload("uid://6bb6evdb8488"),
	"dragon":preload("uid://c373u7op7kppl"),
	"bear":preload("uid://qsbc2kitpjnm"),
	"wolf":preload("uid://6qiv5d0ni4o0")
}

func switch_level(str_level:String):
	var old_level:Array=%Node2DLevel.get_children()
	for l in old_level:l.queue_free()
	
	var new_level:Level=dict_level[str_level].instantiate()
	%Node2DLevel.add_child(new_level)
	var marks:Array=new_level.enter_point.get_children()
	player.position=marks[0].position
	
	camera_2d.limit_left=new_level.lt.position.x
	camera_2d.limit_top=new_level.lt.position.y
	camera_2d.limit_right=new_level.rb.position.x
	camera_2d.limit_bottom=new_level.rb.position.y

func switch_player(str_player:String):
	var old_position:Vector2=Vector2.ZERO
	if player:
		old_position=player.position
		player.queue_free()
	var new_player:Entity=dict_player[str_player].instantiate()
	%Node2DPlayer.add_child(new_player)
	new_player.position=old_position
	new_player.dead.connect(game_fail)
	player=new_player
	Global.player=player
	match str_player:
		"dragon":Global.play_sfx([Global.SFX_TRANSFORM_DRAGON_1,Global.SFX_TRANSFORM_DRAGON_2].pick_random())
		"bear":Global.play_sfx(Global.SFX_TRANSFORM_BEAR)
		"wolf":Global.play_sfx([Global.SFX_TRANSFORM_WOLF_1,Global.SFX_TRANSFORM_WOLF_2].pick_random())
	

func _ready() -> void:
	player=%Player
	player.dead.connect(game_fail)
	Global.player=%Player
	Global.play_bgm(Global.BGM)
	switch_level("level_1")

func _process(delta: float) -> void:
	if player:camera_2d.position=player.position

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("j"):switch_player("dragon")
	
func game_fail():Global.switch_scene(Global.UI_FAIL)
