extends Node

const UI_THEME = preload("uid://dfa43m1akf7gs")
const UI_PLAY = preload("uid://bmqikbyoogitf")
const UI_PASS = preload("uid://bddui4ooiilgm")
const UI_FAIL = preload("uid://b4mw8c3p2a4wo")

func switch_scene(packed_scene:PackedScene):
	get_tree().call_deferred("change_scene_to_packed",packed_scene)
	
const BGM = ("uid://cpr6bxs7kelqq")
func play_bgm(bgm:String):
	%Bgm.stream=load(bgm)
	%Bgm.play()
func _on_bgm_finished() -> void:%Bgm.play()

const SFX_TRANSFORM_DRAGON_1 = ("uid://dlut6nhn55fa5")
const SFX_TRANSFORM_DRAGON_2 = ("uid://bvsybvyiif4wl")
const SFX_TRANSFORM_WOLF_1 = ("uid://sjgfxkiiml3n")
const SFX_TRANSFORM_WOLF_2 = ("uid://00gsivso581b")
const SFX_TRANSFORM_BEAR = ("uid://3rf565oolh6n")
const SFX_FAQ = ("uid://b453q6gqs66rp")
const SFX_PLAYER_DEAD = ("uid://cn8jpd0fd6t4s")
const SFX_PLAYER_HURT = ("uid://d2gxuy3ckswhf")
const SFX_PASS = ("uid://j6qvwupn06pl")
const SFX_FAIL = ("uid://bqgsx74o2qho1")

var SFX_JUMP=[("uid://rk7ii5c5p6ag"),("uid://ge0qnlue05ti"),("uid://cq5mvtt3j27gt"),("uid://sc4o0rf58p20")]

const SFX = preload("uid://betxa8n7jvl5g")
func play_sfx(sfx:String):
	var s:Sfx=SFX.instantiate()
	s.stream=load(sfx)
	%Sfx.add_child(s)

enum EnumEnemy{
	STONE,
	ATTACKER,
	ZOMBIE
}
var pack_enemy:Array=[
	preload("uid://ciar6x6412wcf"),
	preload("uid://d2lslivf0podk"),
	preload("uid://cnrd6ves3ilva")
]

var player:Entity=null
var node_enemy:Node=null
