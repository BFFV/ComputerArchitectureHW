# Tarea 2 Pregunta 2

### Nombre: Benjamín Farías Valdés

### Número de Alumno: 17642531

## Algoritmo

- Se revisa el primer elemento del arreglo y se coloca como la Moda (por default).

- Se avanza al siguiente elemento del arreglo. Si es el mismo número que el elemento anterior, entonces se le suma 1 a su cantidad de ocurrencias. Si es que el número actual es la Moda, entonces también se le suma 1 a la cantidad de ocurrencias de la Moda (ya que corresponde al número actual). En caso de que sea un nuevo número, se resetea su cantidad de ocurrencias (es la primera vez que aparece).

- Tras el paso anterior, se compara la cantidad de ocurrencias del elemento actual con las de la Moda actual. Si la cantidad de ocurrencias del elemento es igual a la de la Moda, el número actual pasa a ser la nueva Moda.

- Se repite el procedimiento anterior para todos los elementos restantes del arreglo.

## Pseudocódigo

```
array <- A
mode_amount <- 0
current_amount <- 0
result <- 0
foreach(num in array):
    if first(num):   // Si es el primer elemento
        result <- num
    else if num != last:  // Si es un nuevo num
        current_amount <- 0
    current_amount ++   // Se aumenta en 1
    if num == result:
        mode_amount ++   // Se aumenta en 1
    else if current_amount == mode_amount:
        result <- num    // Nueva Moda
```
