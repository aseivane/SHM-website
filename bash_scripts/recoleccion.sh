#!/bin/bash

# Parametros iniciales
broker=$1
port="1883"
usr=$2
pass=$3
nro_medicion=$4

nro_medicion_ext=`printf %03d $nro_medicion`

directorio1="./mediciones/medicion_$nro_medicion_ext"
#archivo1="$directorio1/mensajes_mqtt.log"
archivo2="$directorio1/tabla_nodos_fin.csv"

topic1="control/borrarSD"

# verificar archivos
#--------------------------------------------

confirmados=$(wc -l $archivo2)
k=$(echo $confirmados | awk '{print $1}')  # numero de nodos que confirmaron la medición completa

# carpeta de almacenamiento general (contiene carpetas para cada nodo)
if [ ! -d "$directorio1/datos_$nro_medicion_ext" ]; then
mkdir "$directorio1/datos_$nro_medicion_ext"
fi

IDs=`cat $archivo2 | cut -d ',' -f1` # extraemos la lista de MACs (IDs) de los nodos
IPs=`cat $archivo2 | cut -d ',' -f2` # extraemos la lista de MACs (IDs) de los nodos

# carpeta de almacenamiento para cada nodo
for i in $( seq 1 $k )
do

id_nodo=$(echo $IDs | awk "{print \$$i}") #extrae MAC (ID) de i-esimo nodo

#nro_nodo=`printf %03d $i`
directorio2="$directorio1/datos_$nro_medicion_ext/nodo_$id_nodo" # genera ruta a la carpeta del i-esimo nodo

if [ ! -d $directorio2 ]; then  # si no existe la carpeta del nodo, la crea
mkdir $directorio2
fi

# Extrae la IP del i-esimo nodo
ip_nodo=$(echo $IPs | awk "{print \$$i}") #extrae MAC (ID) de i-esimo nodo
echo $ip_nodo

# Envia comando wqet para descargar los archivos

wget -r -e robots=off $ip_nodo -P $directorio2 -nd
rm $directorio2/index.html  #Borro el archivo index.html porque no me sirve y molesta

echo "Nodo $id_nodo: recepción completa."


mosquitto_pub -t $topic1 -h $broker -p $port -m "$id_nodo" -u $usr -P $pass # Borrar tarjeta de memoria
echo "Nodo $id_nodo: mensaje de borrado enviado."

done

