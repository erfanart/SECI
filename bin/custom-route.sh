#!/bin/bash
FILES=(
	"custom_ips" 
	"iran_ips.txt"
)

for File in ${FILES[@]}
do 
        echo $CONF_DIR/$File
        if [[ -f $CONF_DIR/$FILES ]];then
                j=0
                o=0
                c=0

        for i in $(cat $CONF_DIR/$File)
        do
                o=$(($o+1))
        done
                echo $o
        for i in $(cat $CONF_DIR/$File)
        do
                printf "%s\n" "$c"'%'" done"
                j=$(($j+1))
                c=$(echo "scale=5; ($j / $o)*100"| bc)
                c=$(echo "scale=0; $c / 1" | bc)
                tput cuu 0
                ip route add $i via $LOCAL_GATEWAY
                sleep 0.001
        done
        else
                echo "####--- There is no $CONF_DIR/$File file to make custom route form them ---####"
        fi
done



