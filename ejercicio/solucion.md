## Solución del mini ejercicio

`aggregatewordcount` cuenta tokens separados por espacios, tabuladores o saltos de línea. Las palabras distinguen mayúsculas de minúsculas y no se quita la puntuación.

Con el archivo del ejercicio, `aggregatewordcount` muestra:

```text
datos       2
hadoop      2
procesa     2
textos      2
y           1
```

`aggregatewordhist` resume los conteos por palabra con seis valores: cantidad de palabras distintas, mínimo, mediana, máximo, promedio y desviación estándar. Para los conteos `1, 2, 2, 2, 2`, la salida esperada es:

```text
WORD_HISTOGRAM    5    1    2    2    1.8    0.4000000000000001
```

Es decir: 5 palabras distintas, mínimo 1, mediana 2, máximo 2, promedio 9/5 = 1.8 y desviación estándar 0.4.