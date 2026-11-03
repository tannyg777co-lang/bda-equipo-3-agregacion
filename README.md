# Equipo 3: Agregación en Hadoop

Demostración reproducible de los ejemplos `aggregatewordcount` y `aggregatewordhist` incluidos en Hadoop 3.3.6.

## ¿Qué hacen?

- **`aggregatewordcount`** separa cada línea en tokens y suma cuántas veces aparece cada token. Distingue mayúsculas y minúsculas; no elimina signos de puntuación.
- **`aggregatewordhist`** calcula estadísticas del histograma de conteos: número de palabras distintas, mínimo, mediana, máximo, promedio y desviación estándar de cuántas veces aparece cada palabra.

Un caso real para ambos es obtener estadísticas rápidas de una colección de documentos: primero el conteo por palabra y después la distribución de frecuencias, útil para comparar vocabularios o detectar términos muy repetidos.

## ¿Cómo funciona MapReduce?

El ejemplo aprovecha el agregador `LongValueSum` de Hadoop. En `aggregatewordcount`, por cada token el map emite una clave de suma y el valor `1`; el framework agrupa las claves iguales y el reduce suma sus valores.

```text
Entrada (líneas de texto)
       │
       ▼
Map: tokeniza cada línea
     (LongValueSum:palabra, 1)
       │
       ▼
Shuffle/Sort: junta claves iguales
       │
       ▼
Reduce: suma los valores
       │
       ▼
palabra    total
```

En `aggregatewordhist`, el map emite cada palabra como un valor del agregador `VALUE_HISTOGRAM`. El reduce combina las apariciones por palabra y reporta estadísticas resumidas del histograma.

```text
Entrada (líneas de texto)
       │
       ▼
Map: emite cada token para WORD_HISTOGRAM
       │
       ▼
Shuffle/Sort: agrupa por el ID del histograma
       │
       ▼
Reduce: reúne conteos por palabra y resume su distribución
       │
       ▼
cantidad de palabras distintas, min, mediana, max, promedio y desviación
```

## Requisitos

- Docker instalado en tu computadora.
- El contenedor `hadoop` de la práctica con Hadoop 3.3.6 y Java.
- Los ejemplos se ejecutan dentro del contenedor. Esta guía fuerza **modo local**: usa el motor MapReduce local y el sistema de archivos local del contenedor; no requiere que HDFS/YARN estén levantados.
- El JAR requerido es `/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar`.
- El script pasa explícitamente la clase plugin de cada ejemplo. En esta distribución, si se omite, el agregador genérico puede limitarse a imprimir `record_count` en vez del resultado del ejemplo.
- Si `JAVA_HOME` no está definido, el script intenta obtenerlo desde el ejecutable `java` disponible en el contenedor.

## Paso a paso

### 1. Desde tu computadora: inicia el contenedor y copia el proyecto

Abre una terminal de tu computadora (no dentro del contenedor). Desde la carpeta que contiene este README:

```bash
docker start hadoop
docker cp bda-equipo-3-agregacion hadoop:/home/hadoop/
docker exec hadoop chown -R hadoop:hadoop /home/hadoop/bda-equipo-3-agregacion
```

`docker start` responde que el contenedor ya está iniciado si estaba activo. No uses `docker rm`.

### 2. Dentro del contenedor: verifica Hadoop y ejecuta

Entra como el usuario `hadoop` y carga su entorno:

```bash
docker exec -it -u hadoop hadoop bash
source ~/.bashrc
hadoop version
cd /home/hadoop/bda-equipo-3-agregacion
bash scripts/ejecutar.sh
```

La versión debe indicar Hadoop 3.3.6. El script lee `datos/entrada.txt`, crea las dos salidas bajo `resultados/` y muestra los archivos `part-r-*`.

### 3. Desde tu computadora: copia los resultados al repositorio

Abre una segunda terminal de tu computadora:

```bash
docker cp hadoop:/home/hadoop/bda-equipo-3-agregacion/resultados/salida-aggregatewordcount ./bda-equipo-3-agregacion/resultados/
docker cp hadoop:/home/hadoop/bda-equipo-3-agregacion/resultados/salida-aggregatewordhist ./bda-equipo-3-agregacion/resultados/
```

Los directorios de resultados contienen `_SUCCESS` y `part-r-00000`. Conserva el `part-r-00000` como evidencia; `_SUCCESS` indica que el trabajo terminó correctamente.

## Datos y resultado esperado

El archivo de entrada pequeño está en [`datos/entrada.txt`](./datos/entrada.txt). Contiene 12 tokens en cuatro líneas. `aggregatewordcount` debe contar: `agrupa` 1, `cuenta` 2, `datos` 2, `hadoop` 2, `mapreduce` 2, `palabras` 2 y `procesa` 1. El orden de salida es lexicográfico.

En `aggregatewordhist`, esos conteos tienen siete palabras distintas, mínimo 1, mediana 2, máximo 2, promedio 12/7 y desviación estándar aproximada 0.45175. La línea generada por Hadoop 3.3.6 tiene este formato:

```text
WORD_HISTOGRAM    7    1    2    2    1.7142857142857142    0.45175395145262565
```

## Solución de problemas

- **`hadoop: command not found`**: dentro del contenedor ejecuta `source ~/.bashrc`.
- **`JAVA_HOME is not set`**: carga `~/.bashrc` como arriba; la práctica configura Java allí.
- **`Input path does not exist`**: verifica que el proyecto se copió a `/home/hadoop/bda-equipo-3-agregacion` y que existe `datos/entrada.txt`.
- **`Output directory already exists`**: vuelve a ejecutar `bash scripts/ejecutar.sh`; el script elimina solo las carpetas de salida de esta práctica.
- **No se encuentra el JAR**: verifica que `hadoop version` indique 3.3.6 y que el archivo exista bajo `$HADOOP_HOME/share/hadoop/mapreduce/`.
- Si la clase no acepta `textinputformat`, revisa la sintaxis de esta distribución con `hadoop jar "$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar" aggregatewordcount`; el ejemplo de Hadoop espera entrada, salida, número de reducers y formato de entrada.

## Mini ejercicio

Completa el ejercicio en [`ejercicio/ejercicio.md`](./ejercicio/ejercicio.md) y comprueba después tu respuesta con [`ejercicio/solucion.md`](./ejercicio/solucion.md). El script acepta una carpeta de entrada opcional; al terminar, vuelve a ejecutar `bash scripts/ejecutar.sh` sin argumentos para restaurar la demostración principal.

## Guion sugerido para la exposición (10 minutos)

1. **Problema y caso real (1 min):** contar términos de documentos y resumir su frecuencia.
2. **`aggregatewordcount` (2 min):** explicar tokenización, `LongValueSum` y el diagrama Map → Shuffle/Sort → Reduce.
3. **`aggregatewordhist` (2 min):** mostrar cómo el agregador `VALUE_HISTOGRAM` resume la distribución de conteos.
4. **Demo en vivo (3 min):** copiar el proyecto al contenedor, ejecutar el script y leer los dos `part-r-00000`.
5. **Mini ejercicio (2 min):** pedir que predigan los conteos y las estadísticas del archivo de [`ejercicio/`](./ejercicio/).

## Entrega

Antes de publicar `bda-equipo-3-agregacion` en GitHub:

1. Añade el PDF de la presentación en la raíz.
2. Confirma los resultados reales de tu contenedor dentro de `resultados/`.
3. Prueba los pasos desde una copia limpia del repositorio (o pide a otro equipo que los siga).
4. No subas el tarball de Hadoop ni salidas grandes.

Para subirlo, crea primero un repositorio público vacío en GitHub llamado `bda-equipo-3-agregacion`. Luego, desde tu computadora y dentro de la carpeta de este proyecto:

```bash
git init
git add .
git commit -m "Agrega práctica de agregación en Hadoop"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/bda-equipo-3-agregacion.git
git push -u origin main
```
