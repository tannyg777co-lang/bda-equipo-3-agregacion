# Mini ejercicio: agrega palabras

Usa [`datos/entrada.txt`](./datos/entrada.txt) como entrada.

1. Antes de ejecutar nada, lee el archivo y predice cuántas veces aparece cada palabra.
2. Predice cuántas palabras distintas hay y qué valores esperas para el mínimo, mediana, máximo y promedio de sus frecuencias.
3. Desde la raíz del proyecto, ejecuta los ejemplos:

```bash
bash scripts/ejecutar.sh ejercicio/datos
```

4. Comprueba tus respuestas mirando `resultados/salida-aggregatewordcount/part-r-00000` y `resultados/salida-aggregatewordhist/part-r-00000`. Explica qué resume `aggregatewordhist`.

No cambies el código de Hadoop. El script limpia únicamente las salidas de esta práctica antes de volver a ejecutar los dos ejemplos.
