extends Camera3D

# Variáveis para controle do delay
@export var target: NodePath = "../nave" # Nó da nave que a câmera seguirá
@export var smooth_speed: float = 5.0 # Velocidade de suavização
@export var offset: Vector3 = Vector3(0, 1, 2) # Distância e altura da câmera em relação à nave

var _target_node: Node3D

func _ready():
	# Verifica se o alvo foi definido
	if target:
		_target_node = get_node(target)
	else:
		printerr("Nenhum alvo definido para a câmera!")

func _process(delta):
	if _target_node:
		# Calcula a posição desejada da câmera (fixa atrás da nave)
		var desired_position = _target_node.global_transform.origin + _target_node.global_transform.basis.z * offset.z + _target_node.global_transform.basis.y * offset.y

		# Interpola suavemente a posição da câmera em direção à posição desejada
		global_transform.origin = global_transform.origin.lerp(desired_position, smooth_speed * delta)
		
		# Rotação suavizada
		var target_rotation = _target_node.global_transform.basis
		global_transform.basis = global_transform.basis.slerp(target_rotation, smooth_speed * delta)

		# Faz a câmera sempre olhar para a nave
		look_at(_target_node.global_transform.origin, Vector3.UP)
