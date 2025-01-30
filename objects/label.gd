extends Label

@onready var nave = get_node("../pivotNave/nave")
@onready var label = self

		
func _ready():
	label.visible = true
	if nave:
		print("Nave encontrada, conectando sinais...")
		nave.connect("acoplou", _on_nave_acoplou)
		nave.connect("desacoplou", _on_nave_desacoplou)
		nave.connect("mineracao_iniciada", _on_mineracao_iniciada)
		nave.connect("mineracao_finalizada", _on_mineracao_finalizada)
		nave.connect("nave_proxima",_on_nave_proxima)
	else:
		print("Erro: Nave não encontrada!")

func _on_nave_proxima(asteroide):
	label.text = "Pressione [SPC] para acoplar " + asteroide.recurso
	print("Proximo: ", label.text)

func _on_nave_acoplou(asteroide):
	label.text = "Pressione [ESC] para minerar " + asteroide.recurso
	print("Acoplou: ", label.text)
	
func _on_nave_desacoplou():
	label.text = ""
	print("Desacoplou")

func _on_mineracao_iniciada(asteroide):
	label.text = "Minerando " + asteroide.recurso + " [ESC] para parar"
	print("Mineração iniciada: ", label.text)

func _on_mineracao_finalizada():
	label.text = "Mineração finalizada"
	print("Mineração finalizada")
