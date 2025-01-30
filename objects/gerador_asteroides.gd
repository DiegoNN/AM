extends Node3D

@export var quantidade_asteroides: int = 10
@export var area_geracao: Vector3 = Vector3(50, 5, 50)
@export var distancia_minima: float = 20.0
@export var cena_asteroide: PackedScene

@onready var nave = get_node("../pivotNave/nave") # <--- CAMINHO PARA A NAVE (VERIFIQUE!)

func _ready(): # <--- O if DEVE ESTAR AQUI DENTRO DE UMA FUNÇÃO
	if nave == null:
		printerr("Erro CRÍTICO: Não foi possível encontrar a Nave na cena principal!")
		return # Impede a execução do resto do _ready

	if cena_asteroide == null:
		print("Erro: Cena do asteroide não foi carregada! Verifique o @export.")
		return
	gerar_asteroides()

func gerar_asteroides():
	for i in range(quantidade_asteroides):
		var asteroide = cena_asteroide.instantiate()
		var posicao = gerar_posicao_valida()
		if posicao != Vector3.ZERO:
			asteroide.position = posicao
			add_child(asteroide)

			if nave != null and is_instance_valid(nave) and nave.has_method("_on_nave_proxima") and nave.has_method("_on_nave_distante"):
				conectar_sinais_asteroides(asteroide)
			else:
				print("Erro: Nave inválida ou métodos _on_nave_proxima/_on_nave_distante não encontrados.")
				if nave == null:
					print("Nave é nula")
				elif not is_instance_valid(nave):
					print("Nave não é uma instância válida.")
				elif not nave.has_method("_on_nave_proxima"):
					print("Nave não tem o método _on_nave_proxima")
				elif not nave.has_method("_on_nave_distante"):
					print("Nave não tem o método _on_nave_distante")

func gerar_posicao_valida():
	var posicao: Vector3
	var valido: bool = false
	var tentativas = 0
	var max_tentativas = 100 # Número máximo de tentativas para encontrar uma posição válida

	while not valido and tentativas < max_tentativas:
		tentativas += 1
		posicao = Vector3(
			randf_range(-area_geracao.x / 2, area_geracao.x / 2),
			randf_range(-area_geracao.y / 2, area_geracao.y / 2),
			randf_range(-area_geracao.z / 2, area_geracao.z / 2)
		)

		valido = true
		for filho in get_children():
			if filho.position.distance_to(posicao) < distancia_minima:
				valido = false
				break

	if not valido:
		print("Erro: Não foi possível gerar uma posição válida após ", max_tentativas, " tentativas. Aumente a area_geracao ou diminua a distancia_minima.")
		return Vector3.ZERO # Retorna Vector3.ZERO se não encontrar posição válida

	return posicao

func conectar_sinais_asteroides(asteroide):
	if asteroide is StaticBody3D and is_instance_valid(nave):
		if not asteroide.is_connected("nave_proxima", Callable(nave, "_on_nave_proxima")):  # Corrected
			asteroide.connect("nave_proxima", Callable(nave, "_on_nave_proxima"))
			print("Sinal nave_proxima conectado com sucesso!")
		if not asteroide.is_connected("nave_distante", Callable(nave, "_on_nave_distante")):  # Corrected
			asteroide.connect("nave_distante", Callable(nave, "_on_nave_distante"))
			print("Sinal nave_distante conectado com sucesso!")
