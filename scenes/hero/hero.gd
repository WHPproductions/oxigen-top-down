extends CharacterBody2D

@export var speed: float = 200.0

@onready var animasi: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	# 1. Mengambil input arah dari pemain (Up, Down, Left, Right)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Menghitung kecepatan berdasarkan arah
	if direction != Vector2.ZERO:
		velocity = direction * speed
		animasi.play("walk")
		
		# Mengubah arah pandang player tergantung input
		if direction.x >= 0:
			animasi.flip_h = false
		else :
			animasi.flip_h = true
	else:
		# Jika tidak ada input, karakter berhenti
		velocity = Vector2.ZERO
		animasi.play("idle")
	
	# 3. Fungsi bawaan Godot untuk menggerakkan karakter dan menangani collision
	move_and_slide()
