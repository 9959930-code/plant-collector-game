extends CharacterBody2D

## 플레이어 캐릭터 — 4방향 이동 + 애니메이션
## 스타듀밸리/포켓몬 스타일 탑다운 2D 이동

const SPEED = 80.0

@onready var anim_sprite = $AnimatedSprite2D
@onready var interact_ray = $InteractRay
@onready var dust_particles = $DustParticles

var direction = "down"
var is_moving = false
var spritesheet: Texture2D

func _ready():
	spritesheet = preload("res://Assets/Images/character_spritesheet.png")
	setup_animations()

func setup_animations():
	var frames = SpriteFrames.new()
	var img = spritesheet.get_image()
	var sheet_w: int = img.get_width()
	var sheet_h: int = img.get_height()
	var cols: int = 4
	var rows: int = 4
	var frame_w: int = sheet_w / cols
	var frame_h: int = sheet_h / rows
	
	var dir_names = ["down", "left", "right", "up"]
	
	for row in range(rows):
		var dir_name = dir_names[row]
		
		# idle 애니메이션
		var idle_name = "idle_" + dir_name
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 6)
		frames.set_animation_loop(idle_name, true)
		
		var idle_rect = Rect2i(0, row * frame_h, frame_w, frame_h)
		var idle_img = img.get_region(idle_rect)
		var idle_tex = ImageTexture.create_from_image(idle_img)
		frames.add_frame(idle_name, idle_tex)
		
		# walk 애니메이션
		var walk_name = "walk_" + dir_name
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, 8)
		frames.set_animation_loop(walk_name, true)
		
		for col in range(cols):
			var rect = Rect2i(col * frame_w, row * frame_h, frame_w, frame_h)
			var frame_img = img.get_region(rect)
			var frame_tex = ImageTexture.create_from_image(frame_img)
			frames.add_frame(walk_name, frame_tex)
	
	if frames.has_animation("default"):
		frames.remove_animation("default")
	
	anim_sprite.sprite_frames = frames
	anim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim_sprite.play("idle_down")

func _physics_process(_delta):
	var input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
		direction = "right"
	elif Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
		direction = "left"
	elif Input.is_action_pressed("ui_down"):
		input_dir.y += 1
		direction = "down"
	elif Input.is_action_pressed("ui_up"):
		input_dir.y -= 1
		direction = "up"
	
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		velocity = input_dir * SPEED
		is_moving = true
		
		match direction:
			"down": interact_ray.target_position = Vector2(0, 16)
			"up": interact_ray.target_position = Vector2(0, -16)
			"left": interact_ray.target_position = Vector2(-16, 0)
			"right": interact_ray.target_position = Vector2(16, 0)
	else:
		velocity = Vector2.ZERO
		is_moving = false
	
	update_animation()
	move_and_slide()

func update_animation():
	if is_moving:
		anim_sprite.play("walk_" + direction)
		dust_particles.emitting = true
	else:
		anim_sprite.play("idle_" + direction)
		dust_particles.emitting = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		interact()

func interact():
	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		if target.has_method("on_interact"):
			target.on_interact(self)
