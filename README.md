# Proyecto 4 – Monitoreo de Procesos en Límite de Recursos

## 🎯 Objetivo
Crear un script que verifique procesos en ejecución que estén consumiendo **más CPU o memoria** de un umbral dado y registrar esa información.

## 📌 Requisitos mínimos
- El script debe recibir **dos parámetros**:
  1) Umbral de uso de **CPU (%)**  
  2) Umbral de uso de **memoria (%)**
- Validar que ambos parámetros estén presentes y sean números válidos.
- Usar herramientas de CLI (`ps`, `top`, `awk`, etc.) para obtener el consumo por proceso.
- Si **algún proceso** supera **uno** de los umbrales, registrar en `/var/log/process_alerts.log` una línea con:
  - `fecha | PID | nombre_proceso | %CPU | %MEM | ESTADO: ALERTADO`
- Si **todos** los procesos están por debajo de los umbrales, registrar en el mismo log una **línea resumen**:
  - `fecha | MAX_CPU <proceso> <valor%> | MAX_MEM <proceso> <valor%> | ESTADO: OK`
- Códigos de salida:
  - `0` → todo dentro de los límites  
  - `2` → al menos un proceso supera los umbrales

## ✨ Extra (opcional)
- Tercer parámetro para elegir el recurso a monitorear: `cpu`, `mem` o `all` (por defecto).
- Ordenar la salida (y/o el log) por el recurso monitoreado en orden descendente.
- Permitir excluir procesos por nombre o por usuario mediante una lista (p. ej. `--exclude=systemd,journal`).

## 🚀 Entregables
- Script funcional: `monitor_procesos_recursos.sh`.
- Evidencia de ejecución (capturas o salida de terminal) en:
  - Escenario **OK** (umbrales altos).
  - Escenario **ALERTADO** (umbrales bajos).
- Archivo de log: `/var/log/process_alerts.log` con registros de prueba.
