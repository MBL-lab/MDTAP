#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 7. Track molecule"
echo " ----------------------------------------------------------------------------------"
echo "This module takes atom numbers (as defined in the PDB files) in the form of a text file as an input and captures the molecule's Z-coordinate position (Å) with respect to time and generates a plot. This gives an idea of the migration of the molecule with respect to time." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo "Enter the address/path of the PDBs and press [ENTER] (Note: if the PDB files are present in the working directory, type '.' and press [ENTER]): "
    read addres
echo "Enter the start PDB (e.g. if step_10.pdb is the starting PDB, then enter '10') and press [ENTER]: "
    read start
echo "Enter the end PDB (e.g. if step_500.pdb is the final PDB, then enter '500') and press [ENTER]: "
    read end
echo "Enter the PDBs to skip and press [ENTER]: "
    read skip
if ( [ -z $skip ] || [ $skip == 0 ] ) ; then
   echo "Please enter a value greater than zero!
Exiting ..."
   exit;
fi
echo "Enter the difference in time (in picoseconds) between each PDB and [ENTER]:
(e.g. If the PDBs are generated at every 10ps interval, then enter '10')"
    read time
echo  "Enter the name of the input file having the atom IDs (Note: the input file should be stored in the folder where the PDBs are present) and press [ENTER]: "
    read input
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

spin()
{
    t=1
    load="/-\|"
    while [ $t -eq 1 ]; do
        for (( s=0; s<${#load}; s++ )); do
            sleep 0.75
            echo -en "Tracing the path followed by the provided atom numbers... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
gap=`echo "${time}*${skip}"| bc -l`
c=0
name=( $(awk '{print $1}' "${address}"/${input}) )
x=`echo ${#name[@]}`

rm -r $address/$filename 2> /dev/null
mkdir $address/$filename

for (( i=0; i<${x}; i++ ));do
    idchk=`grep ${name[${i}]} "${address}"/step_${start}.pdb | wc -l`
    idchk1=`grep ${name[${i}]} "${address}"/step_${start}.pdb`
    if [ $idchk -le 0 ] ; then
      echo "Atom number/id " ${name[${i}]} " not present - check PDB"
      rm -rf "${address}"/$filename/
      exit
    fi
    touch $address/$filename/Track-${name[$i]}.dat
    echo "This file contains the Z-coordinates (Å) with respect to time.
Column 1: Time (*${time}ps)     Column 2: Z-coordinate (Å)" > $address/$filename/Track-${name[$i]}.dat
    
    while [ ${start} -le ${end} ];do
        awk   -v id="${name[$i]}" -v t="${start}" '{if ( $2==id ) printf"%i   %0.4f \n", t,  $8}' "${address}"/step_${start}.pdb  >> $address/$filename/Track-${name[$i]}.dat
        start=$[${start}+${skip}]
        c=$[${c}+1]
    done
    r=`echo "$c*${skip}" | bc -l` 
    start=`echo "$start-(${r})" | bc -l`
    c=0
done

chmod 755 *
wd=`pwd`
cd $address/$filename

#Rounding off Y axis limits --> Lower round off to nearest 10 for the lower limit and upper round off for the upper limit
temp1=`cat *dat | grep -v [A-Z] | awk '{print $2}' | sort -n | head -1`
temp=`printf '%.f' $temp1`
Yr1=`echo $(($temp - ($temp % 10)))`
temp1=`cat *dat | grep -v [A-Z] | awk '{print $2}' | sort -n | tail -1`
temp=`printf '%.f' $temp1`
temp2=`echo $(($temp / 10))`
temp=`printf '%.f' $temp2`
Yr2=`echo $((($temp + 1 ) * 10))`

for i in *.dat; do
    j=$(echo "$i" | sed 's/.dat//g' | tr -d '\n\r')
    k=$(echo "$j" | sed 's/Track-//g' | tr -d '\n\r')
    cat << __EOF | gnuplot 2> /dev/null
    set terminal pngcairo size 800,600
    set border linewidth 3
    set output '$j.png'
    set yrange [$Yr1:$Yr2]
    set title 'Path traced by atom number: $k' font "Helvetica-bold, 18"
    set xlabel 'Time (*${time}ps)' font "Helvetica-bold, 16"
    set ylabel 'Z-coordinate (Å)' font "Helvetica-bold, 16"
    set xtics font "Helvetica-bold, 14"
    set ytics font "Helvetica-bold, 14"
    set key off
    plot '$i' using 1:2 with linespoints pointsize 1 pointtype 7 lw 3 linecolor rgb "#19AADE"
__EOF
done
cd $wd

kill -9 $spin_pid
sleep 1
above_line=$(tput cuu1)
erase_line=$(tput el)
echo "$above_line$erase_line"

echo "The output files are stored in" $filename "at" $address/$filename
echo "1. Continue    2. Back    3. Quit"
echo -n "Enter an option (1, 2, or 3) and press [ENTER]: "
    read option
if [ $option -eq 1 ]; then
    $MDTAPpath/Track.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi
