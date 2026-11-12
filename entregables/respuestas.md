# Respuestas conceptuales: Ventas diarias con control de actualidad

**Estudiante:** Juan José R. P. (jjrp) · Ingeniería de Datos · Final 2026-2

## 1. ¿Por qué usar `_loaded_at` y no `fecha_venta` para este control?

`fecha_venta` dice cuándo ocurrió la venta en el negocio, mientras que `_loaded_at` dice cuándo llegó el dato a `raw.ventas`. El control de freshness quiere saber si el proceso de carga está al día, y eso lo mide el instante de carga. Si usara `fecha_venta`, una carga puntual de ventas antiguas (un reproceso o un histórico) parecería "desactualizada" aunque los datos acabaran de llegar. Por el contrario, una tabla sin ventas nuevas porque el negocio no vendió ese día se vería como un fallo del sistema, cuando la carga sí funcionó. En el ejercicio se ve así: con `scenario desactualizada` los datos de negocio son los mismos de siempre y solo cambia `_loaded_at` (hace 30 horas), y freshness falla porque la última carga superó las 24 horas.

## 2. ¿Por qué las pruebas de integridad no garantizan actualidad?

Las pruebas (`unique`, `not_null` y los valores válidos) solo revisan la calidad de las filas que ya existen: que no se repitan, que no falten campos y que los valores sean razonables. No miran cuándo llegó el dato. Una tabla con datos de hace una semana cumple todas esas pruebas, porque los datos viejos siguen siendo únicos y completos. Por eso `dbt build` termina en verde aunque la fuente esté desactualizada. Además, `dbt build` no ejecuta `source freshness`, así que hace falta una tarea aparte (`verificar_freshness`) antes de construir el resumen. En el escenario `desactualizada` el modelo y sus pruebas habrían pasado, pero freshness falla y bloquea `construir_resumen` (`upstream_failed`), con lo que el resumen anterior se conserva.

---

## Hilo de la IA

Para resolver este examen se usó un asistente de IA (Claude). El hilo completo de la conversación está en este enlace: https://claude.ai/share/6c21f893-2e1b-4caf-bf0c-c2350794994c

El enlace también se guardó en `entregables/hilo_IA/enlace_hilo.md`.
