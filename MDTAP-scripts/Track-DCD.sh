#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 7. Track molecule"
echo " ----------------------------------------------------------------------------------"
echo "This module takes atom numbers (as defined in the PSF files) in the form of a text file as an input and captures the molecule's Z-coordinate position (Å) with respect to time and generates a plot. This gives an idea of the migration of the molecule with respect to time." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo "Enter the molecule of interest (e.g. OH2 for water oxygens) and press [ENTER]: "
    read atname
echo "Enter the address/path of the dcds and press [ENTER] (Note: if the DCD files are present in the working directory, just press [ENTER]): "
    read addres
echo "Enter the start dcd (e.g. if step_10.dcd is the starting dcd, then enter '10') and press [ENTER]: "
    read stdcd
echo "Enter the end dcd (e.g. if step_500.dcd is the final dcd, then enter '500') and press [ENTER]: "
    read endcd
echo "Enter the starting frame of the dcd and press [ENTER]: "
    read start
echo "Enter the ending frame of the dcd and press [ENTER]: "
    read end
echo  "Enter the number of frames in the dcds to skip and press [ENTER]: "
    read skip
if ( [ -z $skip ] || [ $skip == 0 ] ) ; then
   echo "Please enter a value greater than zero!
Exiting ..."
   exit;
fi
echo "Enter the difference in time (in picoseconds) between each frame and press [ENTER]:
(e.g. If the frames are generated at every 10ps interval, then enter '10')"
    read time
echo  "Enter the name of the psf file (Note: the psf file should be stored in the folder where the dcds are present) and press [ENTER]: "
    read psfname
echo  "Enter the name of the input file having the atom IDs (Note: the input file should be stored in the folder where the DCDs are present) and press [ENTER]: "
    read inputfile
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

echo -e "\nTrack molecule calculation is going on. Please wait, as this could take a while.\n"

atname=$(echo $atname | tr '[a-z]' '[A-Z]')
resname=$(echo $resname | tr '[a-z]' '[A-Z]')
segid=$(echo $segid | tr '[a-z]' '[A-Z]')

homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
chmod 755 *
rm -r $address/$filename 2> /dev/null
mkdir $address/$filename

location=$address/$filename

if  [ -z $atname  ] ; then atname='" "'  ; fi
if  [ -z $resname ] ; then resname='" "' ; fi
if  [ -z $resid   ] ; then resid='" "'   ; fi

rm $location/coord_*.dat $location/step_1.pdb $location/atmlist.dat $address/temp.psf 2> /dev/null

sed -n '/NATOM/,$p' $address/$psfname > $address/temp.psf

awk -v atnumber="" -v senm="" -v renum="" -v atnm=$atname -v resnm="" 'BEGIN { str1 = "^"; str2 = "$"; 
if (length(atnumber) == 0) {atnumber1=atnumber;} else {atnumber1 = str1 atnumber str2;}
if (length(senm)     == 0) {senm1=senm;        } else {senm1     = str1 senm str2;}
if (length(renum)    == 0) {renum1=renum;      } else {renum1    = str1 renum str2;}
if (length(atnm)     == 0) {atnm1=atnm;        } else {atnm1     = str1 atnm str2;}
if (length(resnm)    == 0) {resnm1=resnm;      } else {resnm1    = str1 resnm str2;}}
$5 ~ atnm1 && $4 ~ resnm1 && $3 ~ renum1 && $2 ~ senm1 && $1 ~ atnumber1 {print }' $address/temp.psf > $location/atmlist.dat
touch ./input
rname='" "'
rid='" "'
echo $stdcd $endcd $start $end $skip $atname $rname $rid \"temp.psf\" \"$location\" \"$address\" > ./input
#generates the first frame in PDB format
gfortran $MDTAPpath/dcd-psf.for 
./a.out < input  
rm ./a.out input $address/temp.psf

spin()
{
    t=1
    load="/-\|"
    while [ $t -eq 1 ]; do
        for (( s=0; s<${#load}; s++ )); do
            sleep 0.75
            echo -en "Tracing the path followed by the provided atom numbers of $atname... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

gap=`echo "${time}*${skip}"| bc -l`
c=0
name=( $(awk '{print $1}' "${address}"/${inputfile}) )
x=`echo ${#name[@]}`


for (( i=0; i<${x}; i++ ));do
    idchk=`grep ${name[${i}]} "${address}"/"${filename}"/coord_${start}.dat | wc -l`
    idchk1=`grep ${name[${i}]} "${address}"/"${filename}"/coord_${start}.dat`
    if [ $idchk -le 0 ] ; then
      echo "Atom number/id " ${name[${i}]} " not present - check dcds"
      rm -rf "${address}"/$filename/
      exit
    fi
    touch $address/$filename/Track-${name[$i]}.dat
    echo "This file contains the Z-coordinates (Å) with respect to time.
Column 1: Time (*${time}ps)     Column 2: Z-coordinate (Å)" > $address/$filename/Track-${name[$i]}.dat
    
    while [ ${start} -le ${end} ];do
        awk   -v id="${name[$i]}" -v t="${start}" '{if ( $1==id ) printf"%i   %0.4f \n", t,  $5}' "${address}"/"${filename}"/coord_${start}.dat  >> $address/$filename/Track-${name[$i]}.dat
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
    j=$(echo "$i" | grep -v coord  | grep -v atmlist | sed 's/.dat//g' | tr -d '\n\r')
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

rm $location/coord_*.dat $location/step_1.pdb $location/atmlist.dat 2> /dev/null

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
    $MDTAPpath/Track-DCD.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi