extends GPUParticles3D

func _ready():
	# Garante que as partículas não sejam regeneradas
	one_shot = true

	# Configura o material das partículas para ficarem estáticas
	var material = ParticleProcessMaterial.new()
	material.gravity = Vector3(0, 0, 0) # Sem gravidade
	material.initial_velocity_min = 0   # Velocidade inicial mínima zero
	material.initial_velocity_max = 0   # Velocidade inicial máxima zero
	material.linear_accel_min = 0       # Aceleração linear mínima zero
	material.linear_accel_max = 0       # Aceleração linear máxima zero
	material.spread = 180               # Distribuição uniforme das partículas
	process_material = material

	# Para garantir que as partículas não desapareçam
	lifetime = 1000 # Tempo de vida muito alto
