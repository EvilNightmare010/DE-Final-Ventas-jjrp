#!/usr/bin/env bash
# Guarda como evidencia el estado de la ultima ejecucion del DAG y los logs de cada tarea.
# Uso (desde la raiz de punto2-ventas): bash entregables/capturar_estado.sh actualizada
set -euo pipefail
cd "$(dirname "$0")/.."
nombre="${1:?Indique un nombre, por ejemplo: actualizada o desactualizada}"
salida="entregables/evidencias/${nombre}"
mkdir -p "$salida"

RUN_ID=$(docker compose exec -T airflow airflow dags list-runs -d examen_ventas -o json 2>/dev/null \
  | python3 -c "import sys,json; r=json.load(sys.stdin); r.sort(key=lambda x: x.get('start_date') or ''); print(r[-1]['run_id'])")
echo "RUN_ID: ${RUN_ID}" | tee "${salida}/estados_tareas.txt"

docker compose exec -T airflow airflow dags list-runs -d examen_ventas -o table 2>/dev/null \
  | tee -a "${salida}/estados_tareas.txt"
docker compose exec -T airflow airflow tasks states-for-dag-run examen_ventas "${RUN_ID}" -o table 2>/dev/null \
  | tee -a "${salida}/estados_tareas.txt"

for tarea in verificar_freshness construir_resumen; do
  archivo="${salida}/log_${tarea}.txt"
  docker compose exec -T -e RUN_ID="${RUN_ID}" -e TAREA="${tarea}" airflow bash -c \
    'f=$(find /state/logs -path "*run_id=${RUN_ID}/task_id=${TAREA}/*" -name "*.log" | sort); if [ -z "$f" ]; then echo "SIN LOG: la tarea ${TAREA} no se ejecuto en esta corrida"; else cat $f; fi' \
    > "${archivo}" 2>/dev/null
  echo "--- ${archivo}: lineas con INICIO/FIN dbt, freshness y errores ---"
  grep -E "INICIO dbt|FIN dbt|SIN LOG|WARN|ERROR|freshness|Done|Completed" "${archivo}" || true
done
echo "Evidencias guardadas en ${salida}/"
