extends Entity
const SFX_DRAGON_ATK_1 = ("uid://bkcsrb1ysmjj")
const SFX_DRAGON_ATK_2 = ("uid://boakk5vcp6d3d")

enum State{NULL,
	IDLE,ATK_1,ATK_2,HURT,DIE
}
var current_state:State=State.NULL
@export var speed=450
const AMMO = preload("uid://dp56hgjxcdhmc")


func _physics_process(delta: float) -> void:
	#var is_jump_pressed=Input.is_action_just_pressed("space")
	var is_atk1_pressed=Input.is_action_just_pressed("mouse_left")
	var is_atk2_pressed=Input.is_action_just_pressed("mouse_right")
	#var input_x=Input.get_axis("a","d")
	var input=Input.get_vector("a","d","w","s")
	
	velocity=Vector2.ZERO
	#1/3.状态判断
	var next_state=current_state
	match current_state:
		State.NULL:next_state=State.IDLE
		State.IDLE:
			if is_atk1_pressed:next_state=State.ATK_1
			if is_atk2_pressed:next_state=State.ATK_2
			if is_hurted:next_state=judge_state_try_enter_hurt(next_state)
		State.ATK_1:
			if not %AnimationPlayer.is_playing():next_state=State.IDLE
			if is_hurted:next_state=judge_state_try_enter_hurt(next_state)
		State.ATK_2:
			if not %AnimationPlayer.is_playing():next_state=State.IDLE
			if is_hurted:next_state=judge_state_try_enter_hurt(next_state)
		State.HURT:
			if not %AnimationPlayer.is_playing():
				next_state=State.IDLE
				if hp<=0:next_state=State.DIE
	#2/3.状态切换
	if next_state==current_state:pass
	else:
		match current_state:
			State.IDLE:pass
			State.ATK_1:%Hitbox.set_deferred("monitoring",false)
		match next_state:
			State.IDLE:%AnimationPlayer.play("idle")
			State.ATK_1:
				%AnimationPlayer.play("atk")
				%Hitbox.hurtboxes.clear()
				%Hitbox.set_deferred("monitoring",true)
				%GPUParticles2D.restart()
				Global.play_sfx(SFX_DRAGON_ATK_1)
			State.ATK_2:
				%AnimationPlayer.play("atk")
				var a=AMMO.instantiate()
				a.scale.x=direction
				a.position=%Marker2D.global_position
				a.velocity.x=direction*900
				add_sibling(a)
				Global.play_sfx(SFX_DRAGON_ATK_2)
			State.HURT:%AnimationPlayer.play("hurt")
			State.DIE:
				%AnimationPlayer.play("die")
				Global.play_sfx(Global.SFX_PLAYER_DEAD)
		current_state=next_state
	#3/3.状态运行
	match current_state:
		State.IDLE:
			if not is_zero_approx(input.x):direction=Direction.LEFT if input.x<0 else Direction.RIGHT
			velocity=input.normalized()*speed
		State.HURT:is_hurted=false
	move_and_slide()

func judge_state_try_enter_hurt(state:State)->State:
	if %TimerInvincible.is_stopped():
		state=State.HURT
		hp-=%Hurtbox.damage
		print(hp)
		Global.play_sfx(Global.SFX_PLAYER_HURT)
	is_hurted=false
	%Hurtbox.damage=0
	return state

func _on_timer_invincible_timeout() -> void:%Graphic.modulate.a=1

func _on_hurtbox_get_damage() -> void:is_hurted=true
