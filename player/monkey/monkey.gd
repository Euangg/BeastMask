extends Entity

enum State{NULL,
	IDLE,RUN,RISE,FALL,ATK,HURT,DIE
}
var current_state:State=State.NULL
@export var speed=350
@export var ability_jump=1300

func _physics_process(delta: float) -> void:
	var is_jump_pressed=Input.is_action_just_pressed("space")
	var is_atk1_pressed=Input.is_action_just_pressed("mouse_left")
	var is_atk2_pressed=Input.is_action_just_pressed("mouse_right")
	var input_x=Input.get_axis("a","d")
	
	velocity.x=0
	#1/3.状态判断
	var next_state=current_state
	match current_state:
		State.NULL:next_state=State.IDLE
		State.IDLE:
			if is_zero_approx(input_x):pass
			else:next_state=State.RUN
			if velocity.y>0:next_state=State.FALL
			if velocity.y<0:next_state=State.RISE
			if is_atk1_pressed:next_state=State.ATK
			if is_atk2_pressed:next_state=State.ATK
			if is_hurted:next_state=judge_state_try_enter_hurt(next_state)
		State.RUN:
			if is_zero_approx(input_x):next_state=State.IDLE
			if velocity.y>0:next_state=State.FALL
			if velocity.y<0:next_state=State.RISE
			if is_atk1_pressed:next_state=State.ATK
			if is_atk2_pressed:next_state=State.ATK
			if is_hurted:next_state=judge_state_try_enter_hurt(next_state)
		State.RISE:
			if is_on_floor():next_state=State.IDLE
			if velocity.y>0:next_state=State.FALL
			if velocity.y<0:next_state=State.RISE
			if is_atk1_pressed:next_state=State.ATK
			if is_atk2_pressed:next_state=State.ATK
			if is_hurted:next_state=judge_state_try_enter_hurt(next_state)
		State.FALL:
			if is_on_floor():next_state=State.IDLE
			if velocity.y>0:next_state=State.FALL
			if velocity.y<0:next_state=State.RISE
			if is_atk1_pressed:next_state=State.ATK
			if is_atk2_pressed:next_state=State.ATK
			if is_hurted:next_state=judge_state_try_enter_hurt(next_state)
		State.ATK:
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
			State.RUN:%AudioStreamPlayer.stop()
			State.RISE:pass
			State.FALL:pass
			State.ATK:
				%Hitbox.set_deferred("monitoring",false)
		match next_state:
			State.IDLE:%AnimationPlayer.play("idle")
			State.RUN:
				%AnimationPlayer.play("run")
				%AudioStreamPlayer.play()
			State.RISE:%AnimationPlayer.play("rise")
			State.FALL:%AnimationPlayer.play("fall")
			State.ATK:
				%AnimationPlayer.play("atk")
				%Hitbox.hurtboxes.clear()
				%Hitbox.set_deferred("monitoring",true)
				Global.play_sfx(Global.SFX_FAQ)
			State.HURT:
				%AnimationPlayer.play("hurt")
				%TimerInvincible.start()
				%Graphic.modulate.a=0.5
			State.DIE:
				%AnimationPlayer.play("die")
				Global.play_sfx(Global.SFX_PLAYER_DEAD)
		current_state=next_state
	#3/3.状态运行
	match current_state:
		State.IDLE:
			if is_jump_pressed:jump()
			if not is_zero_approx(input_x):direction=Direction.LEFT if input_x<0 else Direction.RIGHT
			velocity.x=input_x*speed
		State.RUN:
			if is_jump_pressed:jump()
			if not is_zero_approx(input_x):direction=Direction.LEFT if input_x<0 else Direction.RIGHT
			velocity.x=input_x*speed
		State.RISE:
			if not is_zero_approx(input_x):direction=Direction.LEFT if input_x<0 else Direction.RIGHT
			velocity.x=input_x*speed
		State.FALL:
			if not is_zero_approx(input_x):direction=Direction.LEFT if input_x<0 else Direction.RIGHT
			velocity.x=input_x*speed
		State.ATK:pass
		State.HURT:
			is_hurted=false
	
	velocity.y+=4000*delta
	move_and_slide()

func jump():
	velocity.y=-ability_jump
	Global.play_sfx_packed(Global.SFX_JUMP.pick_random())

func _on_hurtbox_get_damage() -> void:is_hurted=true

func judge_state_try_enter_hurt(state:State)->State:
	if %TimerInvincible.is_stopped():
		state=State.HURT
		hp-=%Hurtbox.damage
		print(hp)
		effect_num(%Hurtbox.damage)
		Global.play_sfx(Global.SFX_PLAYER_HURT)
	is_hurted=false
	%Hurtbox.damage=0
	return state

func _on_timer_invincible_timeout() -> void:%Graphic.modulate.a=1


func _on_audio_stream_player_finished() -> void:%AudioStreamPlayer.play()
