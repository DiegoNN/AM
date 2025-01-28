extends Node3D

@export var velocidade_maxima: float = 5.0
@export var aceleracao: float = 1.0
@export var desaceleracao: float = 5.0
@export var velocidade_rotacao: float = 0.5
@export var velocidade_re: float = 1.0
@export var velocidade_vertical: float = 10.0
@export var intensidade_inclinacao: float = 2.5

var velocidade_atual: float = 0.0
var velocidade_vertical_atual: float = 0.0
var rotacao_z_alvo: float = 0.0
var rotacao_x_alvo: float = 0.0

@onready var nave: CharacterBody3D = $nave

func _physics_process(delta):
	# Aceleração e Desaceleração Horizontal
	if Input.is_action_pressed("ui_up"):
		velocidade_atual = min(velocidade_atual + aceleracao * delta, velocidade_maxima)
	elif Input.is_action_pressed("ui_down"):
		velocidade_atual = max(velocidade_atual - aceleracao * delta, -velocidade_re)
	else:
		if velocidade_atual > 0:
			velocidade_atual = max(velocidade_atual - desaceleracao * delta, 0.0)
		elif velocidade_atual < 0:
			velocidade_atual = min(velocidade_atual + desaceleracao * delta, 0.0)

	# Movimentação Vertical
	if Input.is_action_pressed("ui_page_up"):
		velocidade_vertical_atual = min(velocidade_vertical_atual + aceleracao * delta, velocidade_vertical)
	elif Input.is_action_pressed("ui_page_down"):
		velocidade_vertical_atual = max(velocidade_vertical_atual - aceleracao * delta, -velocidade_vertical)
	else:
		if velocidade_vertical_atual > 0:
			velocidade_vertical_atual = max(velocidade_vertical_atual - desaceleracao * delta, 0.0)
		elif velocidade_vertical_atual < 0:
			velocidade_vertical_atual = min(velocidade_vertical_atual + desaceleracao * delta, 0.0)

	# Rotação e Inclinação
	var rotacao_y_atual = 0.0
	var rotacao_x_atual = 0.0

	if velocidade_atual != 0 and (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
		# Rotação em torno do próprio eixo (com aceleração e direcional)
		if Input.is_action_pressed("ui_left"):
			nave.rotation.y += velocidade_rotacao * delta
			rotacao_y_atual = velocidade_rotacao * delta * intensidade_inclinacao * 10
		if Input.is_action_pressed("ui_right"):
			nave.rotation.y -= velocidade_rotacao * delta
			rotacao_y_atual = -velocidade_rotacao * delta * intensidade_inclinacao * 10
	else:
		# Rotação em torno da frente da nave (sem aceleração ou sem direcional)
		if Input.is_action_pressed("ui_left"):
			rotation.y += velocidade_rotacao * delta
			rotacao_y_atual = velocidade_rotacao * delta * intensidade_inclinacao * 10
		if Input.is_action_pressed("ui_right"):
			rotation.y -= velocidade_rotacao * delta
			rotacao_y_atual = -velocidade_rotacao * delta * intensidade_inclinacao * 10

	if Input.is_action_pressed("ui_page_up"):
		rotation.x += velocidade_rotacao * delta
		rotacao_x_atual = velocidade_rotacao * delta * intensidade_inclinacao
	if Input.is_action_pressed("ui_page_down"):
		rotation.x -= velocidade_rotacao * delta
		rotacao_x_atual = -velocidade_rotacao * delta * intensidade_inclinacao

	rotacao_z_alvo = rotacao_y_atual
	rotacao_x_alvo = rotacao_x_atual 

	nave.rotation.z = lerp(nave.rotation.z, rotacao_z_alvo, 1 * delta)
	nave.rotation.x = lerp(nave.rotation.x, rotacao_x_alvo, 1 * delta)
	nave.rotation.x = clamp(nave.rotation.x, -deg_to_rad(20), deg_to_rad(20))

	# Movimento Horizontal
	var direcao_local: Vector3 = Vector3.FORWARD * velocidade_atual
	var direcao_global: Vector3 = transform.basis * direcao_local

	nave.velocity = direcao_global
	nave.move_and_slide()

	# Debug (Opcional)
	print("Rotação Y: ", rotation.y)
	print("Rotação Z: ", nave.rotation.z)
	print("Rotação X: ", nave.rotation.x)
	print("Velocidade: ", nave.velocity)
	print("Velocidade Atual: ", velocidade_atual)
	print("Velocidade Vertical Atual: ", velocidade_vertical_atual)
