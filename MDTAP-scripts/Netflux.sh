#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 5. Net flux and Permeability coefficient (Pd)"
echo " ----------------------------------------------------------------------------------"
echo "This module calculates the net flux and permeability coefficient Pd of the permeating molecules." | fold -sw 80 | sed "s/^/  /g"
echo "Note: Outputs from the permeation module provide atom numbers of molecules that completely permeate (influx/efflux). This gives an idea of the number of molecules permeating in each direction and can be used as inputs for this module." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo "Enter the number of influx molecules and press [ENTER]: "
    read influx
echo "Enter the number of efflux molecules and press [ENTER]: "
    read efflux
echo  "Enter the time frame (ns) over which the above influx/efflux is to be calculated and press [ENTER]: "
    read time

spin()
{
    t=1
    load="/-\|"
    while [ $t -eq 1 ]; do
        for (( s=0; s<${#load}; s++ )); do
            sleep 0.75
            echo -en "Calculating the net flux and permeability coefficient (Pd)... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

i=${influx}
e=${efflux}
number=`echo "(${e}+${i})/2" | bc -l`
q=`echo "(${e}-${i})/${time}" | bc -l`

q1=`echo "${number}/(2*${time})"| bc -l`
flux=`printf "%.3f\n" ${q}`

if ( [ -z $influx ] || [ $influx == 0 ] || [ -z $efflux ] || [ $efflux == 0 ]) ; then
{
    echo -e "\nSince your membrane channel is unidirectional (i.e. either influx/efflux is zero), the diffusion permeability coefficient will be calculated only for one direction."
    d=`echo "2.98*${q1}" | bc -l`
}
else
{
    echo -e "\nSince your membrane channel is bidirectional (i.e. both influx and efflux are greater than zero), the diffusion permeability coefficient will be calculated for both directions."
    d=`echo "2.98*${q1}*2" | bc -l`
}
fi
dif=`printf "%.3f\n" ${d}`

chmod 755 *
rm *.png 2>/dev/null

kill -9 $spin_pid
sleep 1
above_line=$(tput cuu1)
erase_line=$(tput el)
echo "$above_line$erase_line"

echo "-----------------------------------------------------------------------------------"
echo " The diffusion permeability coefficient is $dif x 10^-14 cm^3/s" 
echo " The net flux is $flux molecules/ns" 
echo "-----------------------------------------------------------------------------------"
echo "1. Continue    2. Back    3. Quit"
echo -n "Enter your option (1, 2, or 3) and press [ENTER]: "
    read option
if [ $option -eq 1 ]; then
    $MDTAPpath/Netflux.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi