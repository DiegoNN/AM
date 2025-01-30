extends CanvasLayer  

@onready var label_inventario: Label = $LabelInventario  
@onready var nave = get_node("../../pivotNave/nave")  # Ajuste o caminho conforme necessário  

func _process(delta):  
	if nave:  
		var texto_inventario = "Inventário:\n"  
		for recurso in nave.recursos_coletados:  
			texto_inventario += str(recurso) + ": " + str(nave.recursos_coletados[recurso]) + "\n"  
		label_inventario.text = texto_inventario  
