# Tarea 2 Pregunta 1

### Nombre: Benjamín Farías Valdés

### Número de Alumno: 17642531

## Algoritmo

- Se suman los bytes MENOS significativos de ambos números (num_1_2 y num_2_2).

- Se suman los bytes MÁS significativos de ambos números (num_1_1 y num_2_1). Al resultado de esta última suma se le agrega el Carry de la primera suma (se le suma 1 en caso de haber Carry en la primera suma).

- Esto permite emular la suma de los 16 bits como si no estuvieran separados.

- Para determinar si el resultado es mayor/igual o menor a 0 se compara su byte más significativo con el literal '0', ya que en este byte se encuentra el primer bit del resultado (representa el signo, 0 si es positivo y 1 si es negativo).

- Finalmente se guarda en las variables correspondientes.

## Pseudocódigo

```
num_1_1 <- A
num_1_2 <- B
num_2_1 <- C
num_2_2 <- D
result_2 <- num_1_2 + num_2_2
if Carry:
    result_1 <- num_1_1 + num_2_1 + 1
else:
    result_1 <- num_1_1 + num_2_1
if result_1 < 0:
    res_c <- result_1
    res_d <- result_2
else:
    res_a <- result_1
    res_b <- result_2
```
