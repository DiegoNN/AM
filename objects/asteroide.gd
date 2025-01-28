extends StaticBody3D

@export var tamanho: float = 1.0
@export var velocidade_rotacao: float = 10.0
var recursos_possiveis = ["ferro", "ouro", "cristais"]
var recurso: String
var quantidade: int

signal nave_proxima(asteroide)
signal nave_distante(asteroide)

var nave_na_area = false # Variável de estado para evitar emissões repetidas

func _ready():
	recurso = recursos_possiveis[randi() % recursos_possiveis.size()]
	quantidade = randi_range(50, 200)
	scale = Vector3(tamanho, tamanho, tamanho)
	print("Asteroide gerado: Recurso = ", recurso, ", Quantidade = ", quantidade)

	# Conecta os sinais da Area3D (Usando get_node para maior segurança)
	if get_node("Area3D"): #Verifica se o node existe
		get_node("Area3D").body_entered.connect(_on_body_entered)
		get_node("Area3D").body_exited.connect(_on_body_exited)
	else:
		print("Erro: Area3D não encontrado no asteroide!")

func _process(delta):
	rotate_y(deg_to_rad(velocidade_rotacao * delta)) #Rotaciona o asteroide

func _on_body_entered(body):
	if body.is_in_group("nave") and not nave_na_area:
		print("Nave ENTROU na área do asteroide!")
		nave_na_area = true
		emit_signal("nave_proxima", self)

func _on_body_exited(body):
	if body.is_in_group("nave") and nave_na_area:
		print("Nave SAIU da área do asteroide!")
		nave_na_area = false
		emit_signal("nave_distante", self)
