
class Cliente {
	var property deuda = 0
	method comprar(monto) {
		deuda = deuda + monto
		console.println("Cliente - comprar")
	}
}

mixin SafeShop {
	var property montoMaximoSafeShop = 50
	
	method comprar(monto) {
		console.println("SafeShop - comprar")
		if (monto > montoMaximoSafeShop) {
			console.println("SafeShop - Validación falló")
			error.throwWithMessage("Debe comprar por menos de " + montoMaximoSafeShop)
		}
		console.println("SafeShop - Validación ok")
		super(monto)
	}
}

mixin Promocion {
	var property puntosPromocion = 0
	
	method comprar(monto) {
		console.println("Promocion - comprar")
		super(monto)
		if (monto > 20) {
			console.println("Promoción - sumo puntos")
			puntosPromocion = puntosPromocion + 15
		}
	}
}

