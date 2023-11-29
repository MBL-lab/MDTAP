#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 6. Ion conductance"
echo " ----------------------------------------------------------------------------------"
echo "This module calculates the ion conductance by capturing the positive and negative ions that flow across the channel." | fold -sw 80 | sed "s/^/  /g"
echo "Note: Outputs from the permeation module provide atom numbers of molecules that completely permeate (influx/efflux). This gives an idea of the number of molecules permeating in each direction and can be used as inputs for this module." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo  "Enter the number of influx/efflux molecules, Q1 (e.g. K) and press [ENTER]: "
    read influx
echo  "Enter the number of influx/efflux molecules, Q2 (e.g. Cl) and press [ENTER]: "
    read efflux
echo  "Enter the valency of the permeating ion (e.g. '1' for monovalent, '2' for divalent ions, etc.) and press [ENTER]: "
    read val
echo  "Enter the time frame (ns) over which the above influx/efflux is to be calculated and press [ENTER]: "
    read time
echo  "Enter the voltage applied across the membrane (Vmp) and press [ENTER]: "
    read vmp

spin()
{
    t=1
    load="/-\|"
    while [ $t -eq 1 ]; do
        for (( s=0; s<${#load}; s++ )); do
            sleep 0.75
            echo -en "Calculating the ion conductance... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

chmod 755 *
i=${influx}
e=${efflux}
q=`echo "(${i}-${e})/(${time}*${vmp})" | bc -l`
d=`echo "${val}*${q}" | bc -l`
ion=`printf "%.3f\n" ${d}`

kill -9 $spin_pid
sleep 1
above_line=$(tput cuu1)
erase_line=$(tput el)
echo "$above_line$erase_line"

echo "-----------------------------------------------------------------------------------"
echo " The conductance is $ion nS"
echo "-----------------------------------------------------------------------------------"
echo "1. Continue    2. Back    3. Quit"
echo -n "Enter your option (1, 2, or 3) and press [ENTER]: "
    read option
if [ $option -eq 1 ]; then
    $MDTAPpath/Ionconductance.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi