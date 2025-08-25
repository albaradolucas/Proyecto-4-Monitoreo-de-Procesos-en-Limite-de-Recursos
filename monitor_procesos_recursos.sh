#!/bin/bash

exit_code=0
frmdate=$(date '+%F %T')
max_use_cpu=0
max_cpu_cmd=""
max_cpu_pid=""

max_use_mem=0
max_mem_cmd=""
max_mem_pid=""
logdir=/var/log/process_alerts.log

if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Debes ingresar un valor umbral para CPU (%) y MEM (%)"
        exit 1
fi

if [[ "$1" =~ ^[0-9]+$ ]] && [[ "$2" =~ ^[0-9]+$ ]]; then
        #if [[ ( $(echo "$1 >= 0") && $(echo "$2 >= 0") ) && ( $(echo "$1 <= 100") && $(echo "$2 <= 100") ) ]]; then
        if [ "$1" -ge 0 ] && [ "$1" -le 100 ] && [ "$2" -ge 0 ] && [ "$2" -le 100 ]; then
                #if values=$(ps -eo pid,pcpu,pmem,comm --no-headers | awk '{pid=$1; cpu=$2; mem=$3; cmd=$0; print pid":"cpu":"mem":"cmd}'); then
                #if values=$(ps -eo pid,pcpu,pmem,comm --no-headers | awk '{print $0; print pid":"cpu":"mem":"cmd}'); then
                if values=$(ps -eo pid,pcpu,pmem,comm --no-headers | awk '{printf "%s:%s:%s:%s\n",$1,$2,$3,$4}'); then
                        if [ -z "$values" ]; then
                                echo "No se pudieron registrar los valores con el filtro"
                                exit 1
                        fi

                        for val in $values; do
                                pid=$(echo $val | cut -d: -f1)
                                cpu=$(echo $val | cut -d: -f2)
                                mem=$(echo $val | cut -d: -f3)
                                cmd=$(echo $val | cut -d: -f4)
                                #echo "$frmdate | $pid | $cmd | $cpu | $mem | ESTADO: ALERTADO"

                                if [ "$(echo "$cpu < $1" | bc -l)" -eq 1 ] && [ "$(echo "$cpu > $max_use_cpu" | bc -l)" -eq 1 ]; then
                                        max_use_cpu=$cpu
                                        max_cpu_cmd=$cmd
                                        max_cpu_pid=$pid
                                fi
                                if [ "$(echo "$mem < $2" | bc -l)" -eq 1 ] && [ "$(echo "$mem > $max_use_mem" | bc -l)" -eq 1 ]; then
                                        max_use_mem=$mem
                                        max_mem_cmd=$cmd
                                        max_mem_pid=$pid
                                fi
                                if [[ ( $(echo "$cpu > $1" | bc -l) -eq 1 && $(echo "$cpu > $max_use_cpu" | bc -l) -eq 1 ) ]]; then
                                        max_use_cpu=$cpu
                                        max_cpu_cmd=$cmd
                                        max_cpu_pid=$pid
                                        echo "$frmdate | $pid | $cmd | $cpu% | $mem% | ESTADO: ALERTADO" >> $logdir
                                        exit_code=2
                                fi
                                if [[ ( $(echo "$mem > $2" | bc -l) -eq 1 && $(echo "$mem > $max_use_mem" | bc -l) -eq 1 ) ]]; then
                                        max_use_mem=$mem
                                        max_mem_cmd=$cmd
                                        max_mem_pid=$pid
                                        echo "$frmdate | $pid | $cmd | $cpu% | $mem% | ESTADO: ALERTADO" >> $logdir
                                        exit_code=2
                                fi
                        done

                        if [ "$exit_code" -eq 0 ]; then
                                echo "$frmdate | MAX_CPU $max_cpu_cmd $max_use_cpu% | MAX_MEM $max_mem_cmd $max_use_mem% | ESTADO: OK" >> $logdir
                        fi

                        if test -e "$logdir" ; then
                                tail -n 5 "$logdir" 2>/dev/null
                                exit $exit_code
                        else
                                echo "El archivo de log no existe o no hay nada para mostrar"
                                exit 1
                        fi
                else
                        echo "No hay procesos para mostrar"
                        exit 1
                fi
        else
                echo "Debes ingresar un valor válido entre 0 y 100"
        fi
else
        echo "Debes ingresar dos valor numéricos válidos"
fi
