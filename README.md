# Clientes de una tarjeta de crédito

El proyecto cuenta cómo agregar comportamiento a un objeto en forma dinámica.

En el [enunciado original](https://docs.google.com/document/d/1Ijz8Pe-ci6bYwbxIn-VZDV1QcijDy2JuAUQtohNX0oA/edit#), tenemos un cliente de una tarjeta de crédito que tiene un comportamiento muy simple: posee una deuda que se incrementa con cada compra.

El usuario pide los siguientes agregados:

- ciertos clientes se adhieren a un sistema Safe Shop que bloquea las compras por más de un monto determinado
- otros clientes que completan un formulario ingresan a un sistema de puntos por recompensa con cada compra mayor a un monto x.

# Soluciones

Las soluciones posibles que cuenta el apunte son

- agregar dos condicionales dentro de la definición de un cliente
- tener una colección de strategies que ocurren al comprar
- decorar al cliente
- una variante de decorar mediante una colección de strategies al cliente
- descartando de plano la herencia que no permite combinar clientes a secas, clientes con promoción, clientes con safe shop y clientes con safe shop y promoción sin repetir código.

# La variante en Wollok : Mixins

Los mixins de Wollok permiten definir comportamiento sin atarlo a una clase o wko. En este caso dada la clase Cliente

```javascript
class Cliente {
	var property deuda = 0
	method comprar(monto) {
		deuda = deuda + monto
	}
}
```

sin afectar directamente al cliente generamos dos mixins, uno con cada agregado nuevo:

```javascript
mixin SafeShop {
	var property montoMaximoSafeShop = 50
	
	method comprar(monto) {
		if (monto > montoMaximoSafeShop) {
			error.throwWithMessage("Debe comprar por menos de " + montoMaximoSafeShop)
		}
		super(monto)
	}
}

mixin Promocion {
	var property puntosPromocion = 0
	
	method comprar(monto) {
		super(monto)
		if (monto > 20) {
			puntosPromocion = puntosPromocion + 15
		}
	}
}
```

El uso de super(monto) no refiere a la herencia, sino al proceso de **linearización** que ocurre con posterioridad, en los tests. El mixin delega a una jerarquía que se completa en tiempo de ejecución, lo que le da una gran flexibilidad (y ciertamente un grado de indirección que puede dificultar el mantenimiento posterior).

# Instanciar un cliente

En el test puede verse cómo crear un cliente con safe shop y otro que combina ambos mixins:

```javascript
describe "tests de clientes" {

	const clienteSafeShop = new Cliente() with SafeShop
	const clienteSafePromo = new Cliente() with Promocion with SafeShop
```

Los mixins no son solo polimórficos con el cliente, también agregan comportamiento y propiedades, como se puede ver en este test que verifica los puntos de promoción:

```javascript
	test "cliente con safe shop y promoción compra, valida y suma puntos promo" {
		clienteSafePromo.comprar(25)
		assert.equals(15, clienteSafePromo.puntosPromocion())
	}
```

Por otra parte, podemos estar seguros que un cliente con safe shop y promoción no suma los puntos de promoción si el mixin de safe shop detecta que sobrepasó el máximo permitido, ya que el orden de las delegaciones con super está bien implementado:

```javascript
	test "cliente con safe shop y promoción no puede comprar por mucho" {
		assert.throwsExceptionWithMessage("Debe comprar por menos de 50", { clienteSafePromo.comprar(150) })
		assert.equals(0, clienteSafePromo.puntosPromocion())
	}
```

# Más información

Pueden verla en [este link](http://www.wollok.org/documentacion/conceptos/), ingresando a la solapa "Avanzados".
