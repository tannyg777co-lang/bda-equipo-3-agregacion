#!/usr/bin/env bash
set -euo pipefail

HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
HADOOP="$HADOOP_HOME/bin/hadoop"
EXAMPLES_JAR="$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INPUT_DIR="${1:-$PROJECT_DIR/datos}"
if [[ "$INPUT_DIR" != /* ]]; then
  INPUT_DIR="$PROJECT_DIR/$INPUT_DIR"
fi
INPUT="$INPUT_DIR"
RESULTS_DIR="$PROJECT_DIR/resultados"
WORDCOUNT_OUT="$RESULTS_DIR/salida-aggregatewordcount"
HIST_OUT="$RESULTS_DIR/salida-aggregatewordhist"
WORDCOUNT_DESCRIPTOR='-Dmapreduce.aggregate.descriptor.0=UserDefined,org.apache.hadoop.examples.AggregateWordCount$WordCountPlugInClass'
HIST_DESCRIPTOR='-Dmapreduce.aggregate.descriptor.0=UserDefined,org.apache.hadoop.examples.AggregateWordHistogram$AggregateWordHistogramPlugin'

# Non-interactive shells may skip ~/.bashrc, where the course container sets JAVA_HOME.
if [[ -z "${JAVA_HOME:-}" ]]; then
  JAVA_BIN="$(command -v java || true)"
  if [[ -n "$JAVA_BIN" ]]; then
    JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$JAVA_BIN")")")"
    export JAVA_HOME
  fi
fi

if [[ -z "${JAVA_HOME:-}" || ! -x "$JAVA_HOME/bin/java" ]]; then
  echo "No se encontró Java; define JAVA_HOME o carga el entorno del usuario hadoop." >&2
  exit 1
fi

if [[ ! -x "$HADOOP" ]]; then
  echo "No se encontró Hadoop ejecutable en: $HADOOP" >&2
  exit 1
fi

if [[ ! -f "$EXAMPLES_JAR" ]]; then
  echo "No se encontró el JAR de ejemplos en: $EXAMPLES_JAR" >&2
  exit 1
fi

if [[ ! -f "$INPUT/entrada.txt" ]]; then
  echo "No se encontró el archivo de entrada: $INPUT/entrada.txt" >&2
  exit 1
fi

mkdir -p "$RESULTS_DIR"
rm -rf "$WORDCOUNT_OUT" "$HIST_OUT"

echo "Ejecutando AggregateWordCount..."
"$HADOOP" jar "$EXAMPLES_JAR" aggregatewordcount \
  -Dmapreduce.framework.name=local -fs file:/// \
  -Dmapreduce.aggregate.descriptor.num=1 "$WORDCOUNT_DESCRIPTOR" \
  "$INPUT" "$WORDCOUNT_OUT" 1 textinputformat

echo "Ejecutando AggregateWordHist..."
"$HADOOP" jar "$EXAMPLES_JAR" aggregatewordhist \
  -Dmapreduce.framework.name=local -fs file:/// \
  -Dmapreduce.aggregate.descriptor.num=1 "$HIST_DESCRIPTOR" \
  "$INPUT" "$HIST_OUT" 1 textinputformat

echo
echo "Resultado de AggregateWordCount:"
cat "$WORDCOUNT_OUT"/part-r-*

echo
echo "Resultado de AggregateWordHist:"
cat "$HIST_OUT"/part-r-*
