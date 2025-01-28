extends CharacterBody3D

# Constantes para melhor leitura e manutenção
const INPUT_ACCELERAR = "acelerar"
const INPUT_DESACELERAR = "re"
const INPUT_ASCENDER = "ui_up"
const INPUT_DESCER = "ui_down"
const INPUT_GIRAR_ESQUERDA = "ui_left"
const INPUT_GIRAR_DIREITA = "ui_right"
const MAX_INCLINACAO_X_RAD = deg_to_rad(20)

# Variáveis exportadas (ajustáveis no editor)
@export var velocidade_maxima: float = 5.0  # m/s
@export var aceleracao: float = 1.0
@export var desaceleracao: float = 5.0
@export var velocidade_rotacao: float = 2.0 #rad/s
@export var velocidade_re: float = 1.0
@export var velocidade_vertical: float = 10.0
@export var intensidade_inclinacao: float = 2.5

# Variáveis de estado
var velocidade_atual: float = 0.0  # m/s
var velocidade_vertical_atual: float = 0.0

func _physics_process(delta):
	_processar_movimento_horizontal(delta)
	_processar_movimento_vertical(delta)
	_processar_rotacao_inclinacao(delta)
	_aplicar_movimento()

	# Debug (Opcional - Remova em builds de produção)

func _processar_movimento_horizontal(delta):
	# Lógica de aceleração e desaceleração simplificada
	var input_direcao = int(Input.is_action_pressed(INPUT_ACCELERAR)) - int(Input.is_action_pressed(INPUT_DESACELERAR))
	velocidade_atual = clamp(velocidade_atual + input_direcao * aceleracao * delta, -velocidade_re, velocidade_maxima)

	if input_direcao == 0: # Sem input, aplica desaceleração
		velocidade_atual = move_toward(velocidade_atual, 0.0, desaceleracao * delta)

func _processar_movimento_vertical(delta):
	# Lógica de movimento vertical simplificada (similar ao horizontal)
	var input_vertical = int(Input.is_action_pressed(INPUT_ASCENDER)) - int(Input.is_action_pressed(INPUT_DESCER))
	velocidade_vertical_atual = clamp(velocidade_vertical_atual + input_vertical * aceleracao * delta, -velocidade_vertical, velocidade_vertical)

	if input_vertical == 0:
		velocidade_vertical_atual = move_toward(velocidade_vertical_atual, 0.0, desaceleracao * delta)

func _processar_rotacao_inclinacao(delta):
	var rotacao_y_atual = 0.0
	var rotacao_x_atual = 0.0

	# Solução 1: Processamento Independente das Entradas (Recomendado pela clareza)
	if Input.is_action_pressed(INPUT_GIRAR_ESQUERDA):
		rotation.y += velocidade_rotacao * delta
		rotacao_y_atual += velocidade_rotacao * delta * (velocidade_atual / velocidade_maxima)
	if Input.is_action_pressed(INPUT_GIRAR_DIREITA):
		rotation.y -= velocidade_rotacao * delta
		rotacao_y_atual -= velocidade_rotacao * delta * (velocidade_atual / velocidade_maxima)

	# Solução 2: Usando um único valor de entrada para direção (Mais conciso)
	# var input_rotacao = int(Input.is_action_pressed(INPUT_GIRAR_DIREITA)) - int(Input.is_action_pressed(INPUT_GIRAR_ESQUERDA))
	# rotation.y += input_rotacao * velocidade_rotacao * delta
	# rotacao_y_atual = input_rotacao * velocidade_rotacao * delta * (velocidade_atual / velocidade_maxima)


	if Input.is_action_pressed(INPUT_ASCENDER):
		rotation.x += velocidade_rotacao * delta
		rotacao_x_atual = velocidade_rotacao * delta * intensidade_inclinacao
	elif Input.is_action_pressed(INPUT_DESCER):
		rotation.x -= velocidade_rotacao * delta
		rotacao_x_atual = -velocidade_rotacao * delta * intensidade_inclinacao

	# Aplica rotação e inclinação (com interpolação para suavizar inclinação Z)
	rotation.y += rotacao_y_atual
	rotation.z = lerp(rotation.z, rotacao_y_atual * intensidade_inclinacao * 10, delta)
	rotation.x = clamp(lerp(rotation.x, rotacao_x_atual, delta), -MAX_INCLINACAO_X_RAD, MAX_INCLINACAO_X_RAD)


func _aplicar_movimento():
	# Movimento Horizontal (usando transform.basis para direção correta)
	velocity = transform.basis.x * 0 + transform.basis.y * velocidade_vertical_atual + transform.basis.z * -velocidade_atual
	move_and_slide()
	
func _ready():
	add_to_group("nave")

func _on_nave_proxima(asteroide):
	print("Nave próxima do asteroide:")
	print("Recurso: ", asteroide.recurso)
	print("Quantidade: ", asteroide.quantidade)

func _on_nave_distante(asteroide):
	print("Nave distante do asteroide")
