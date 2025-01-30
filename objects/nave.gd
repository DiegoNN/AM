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
var asteroide_proximo: Node3D = null  
var acoplado: bool = false


signal nave_proxima(asteroide)
signal acoplou(asteroide)
signal desacoplou
signal mineracao_iniciada(asteroide)
signal mineracao_finalizada

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

  

# Funções para detectar proximidade  
func _on_nave_proxima(asteroide):  
	print("Nave próxima do asteroide: ", asteroide.recurso)
	asteroide_proximo = asteroide  
	emit_signal("nave_proxima", asteroide_proximo)  
	
func _on_nave_distante(asteroide):  
	print("Nave distante do asteroide")  
	if asteroide_proximo == asteroide:  
		asteroide_proximo = null  

# Função para acoplar  
func acoplar():  
	if asteroide_proximo and not acoplado:  
		acoplado = true
		emit_signal("acoplou", asteroide_proximo)  
		print("Nave acoplada ao asteroide: ", asteroide_proximo.recurso)  
		# Desabilita o controle de movimento  
		set_physics_process(false)  

# Função para desacoplar  
func desacoplar():  
	if acoplado:  
		acoplado = false
		emit_signal("desacoplou")  
		print("Nave desacoplada do asteroide")  
		# Reabilita o controle de movimento  
		set_physics_process(true)  

# Input para acoplar/desacoplar   
			
# Variáveis de mineração  - INICIO
@export var taxa_mineracao: float = 1.0  # Recursos por segundo  
var recursos_coletados: Dictionary = {}  
var mineração_em_andamento: bool = false  

# Função para iniciar a mineração  
func iniciar_mineracao():  
	if acoplado and asteroide_proximo and not mineração_em_andamento:  
		mineração_em_andamento = true
		emit_signal("mineracao_iniciada", asteroide_proximo)  
		print("Iniciando mineração no asteroide: ", asteroide_proximo.recurso)  
		# Inicia um timer para simular a mineração  
		$TimerMineracao.start()  

# Função para parar a mineração  
func parar_mineracao():  
	if mineração_em_andamento:  
		mineração_em_andamento = false  
		$TimerMineracao.stop()
		emit_signal("mineracao_finalizada")  
		print("Mineração interrompida")  

# Função chamada quando o timer completa  
func _on_timer_timeout():  
	if asteroide_proximo and asteroide_proximo.quantidade > 0:  
		# Coleta recursos  
		var recurso = asteroide_proximo.recurso  
		var quantidade_coletada = min(taxa_mineracao, asteroide_proximo.quantidade)  
		
		# Atualiza o inventário  
		if recurso in recursos_coletados:  
			recursos_coletados[recurso] += quantidade_coletada  
		else:  
			recursos_coletados[recurso] = quantidade_coletada  
		
		# Reduz a quantidade de recursos no asteroide  
		asteroide_proximo.quantidade -= quantidade_coletada  
		print("Recurso coletado: ", recurso, " (", quantidade_coletada, ")")  
		
		# Verifica se o asteroide foi esgotado  
		if asteroide_proximo.quantidade <= 0:  
			parar_mineracao()  
			print("Asteroide esgotado!")  
	else:  
		parar_mineracao()  

# Input para iniciar/parar a mineração  
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if acoplado:
			desacoplar()
		elif asteroide_proximo:
			acoplar()
	elif event.is_action_pressed("ui_cancel"):
		if acoplado and not mineração_em_andamento:
			iniciar_mineracao()
		elif mineração_em_andamento:
			parar_mineracao()  
			
func exibir_inventario():  
	print("Inventário:")  
	for recurso in recursos_coletados:  
		print(recurso, ": ", recursos_coletados[recurso]) 
