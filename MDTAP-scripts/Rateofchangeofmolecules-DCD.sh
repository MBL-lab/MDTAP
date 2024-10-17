#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 3. Rate of change of molecules"
echo " ----------------------------------------------------------------------------------"
echo "This module calculates the number of water molecules present within the protein or in any user-defined area with respect to time." | fold -sw 80 | sed "s/^/  /g"
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
echo  "Enter seg ID of the channel and press [ENTER] (Note: seg ID is considered only for the channel. If absent in the dcd files, just press [ENTER]): "
    read segid
echo  "Enter the name of the psf file (Note: the psf file should be stored in the folder where the dcds are present) and press [ENTER]: "
    read psfname
echo "Enter the molar volume of the molecule and press [ENTER]: 
(e.g the molar volume of Water = 18.07cm^3, Sodium = 23.78cm^3, and Chlorine = 22.40cm^3. Note: The user is free to enter any value specific to the molecule of interest apart from the examples given.)"
    read volume
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

echo -e "\nRate of change of molecules calculation is going on. Please wait, as this could take a while.\n"

atname=$(echo $atname | tr '[a-z]' '[A-Z]')
resname=$(echo $resname | tr '[a-z]' '[A-Z]')
segid=$(echo $segid | tr '[a-z]' '[A-Z]')

homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
con=`echo "${volume}/6.024" | bc -l`
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

awk '{ if ((($4 ~ /ALA|GLY|LEU|VAL|ASN|ASP|ARG|TRP|SER|ILE|HSD|THR|PRO|GLN|GLU|LYS|TYR|PHE|MET|CYS|ADE|GUA|CYT|THY|URA|URI/) || ($4 == "DA")  || ($4 == "DG") || ($4 == "DC") || ($4 == "DT") || ($4 == "RA")  || ($4 == "RG") || ($4 == "RC") || ($4 == "RT") || ($4 == "RU") || ($4 == "A") || ($4 == "C") || ($4 == "D") || ($4 == "E") || ($4 == "F") || ($4 == "G") || ($4 == "H") || ($4 == "I") || ($4 == "K") || ($4 == "L") || ($4 == "M") || ($4 == "N") || ($4 == "P") || ($4 == "Q") || ($4 == "R") || ($4 == "S") || ($4 == "T") || ($4 == "U") || ($4 == "V") || ($4 == "W") || ($4 == "Y")) && ($1 == "ATOM") && ($3 != $4)) print }' "${address}"/"${filename}"/step_1.pdb | grep -i " $segid" > $address/$filename/step.pdb
a=0
a1=0
b=0
b1=0
c=0
c1=0
x=0
y=0
z=0
if [ -z $chainid ]; then
    x=( $(awk '{print $6}' $address/$filename/step.pdb) )
    IFS=$'\n'
    a=`echo "${x[*]}" | sort -nr | head -n1`
    a1=`echo "${x[*]}" | sort -nr | tail -n1`
    y=( $(awk '{print $7}' $address/$filename/step.pdb) )
    IFS=$'\n'
    b=`echo "${y[*]}" | sort -nr | head -n1`
    b1=`echo "${y[*]}" | sort -nr | tail -n1`
    z=( $(awk '{print $8}' $address/$filename/step.pdb) )
    IFS=$'\n'
    c=`echo "${z[*]}" | sort -nr | head -n1`
    c1=`echo "${z[*]}" | sort -nr | tail -n1`
else
    x=( $(awk '{print $7}' $address/$filename/step.pdb) )
    IFS=$'\n'
    a=`echo "${x[*]}" | sort -nr | head -n1`
    a1=`echo "${x[*]}" | sort -nr | tail -n1`
    y=( $(awk '{print $8}' $address/$filename/step.pdb) )
    IFS=$'\n'
    b=`echo "${y[*]}" | sort -nr | head -n1`
    b1=`echo "${y[*]}" | sort -nr | tail -n1`
    z=( $(awk '{print $9}' $address/$filename/step.pdb) )
    IFS=$'\n'
    c=`echo "${z[*]}" | sort -nr | head -n1`
    c1=`echo "${z[*]}" | sort -nr | tail -n1`
fi

rm $address/$filename/step*.pdb

if ( [ ${#x[@]} -eq 0 ] || [ ${#y[@]} -eq 0 ] || [ ${#z[@]} -eq 0 ] ); then
   echo "There is a problem with the input DCDs or PSF file.
Exiting ..."
   exit;
fi

echo "Recommended dimensions (Xmax Xmin Ymax Ymin Zmax Zmin) for the channel are:" $a $a1 $b $b1 $c $c1
echo "Enter the channel limits (Xmax Xmin Ymax Ymin Zmax Zmin) and press [ENTER]: "
    read limits

echo $limits > $address/$filename/limit.dat 
lim=`awk "{print $1}" $address/$filename/limit.dat`
rm $address/$filename/limit.dat
xp=`echo $lim | awk '{print $1}'`
xn=`echo $lim | awk '{print $2}'`
yp=`echo $lim | awk '{print $3}'`
yn=`echo $lim | awk '{print $4}'`
zp=`echo $lim | awk '{print $5}'`
zn=`echo $lim | awk '{print $6}'`

if ( [ `printf %.f ${xp}` -lt `printf %.f ${xn}` ] || [ `printf %.f ${yp}` -lt `printf %.f ${yn}` ] || [ `printf %.f ${zp}` -lt `printf %.f ${zn}` ] ); then
    echo "Please ensure that the Xmax, Ymax, and Zmax values are greater than their corresponding Xmin, Ymin, and Zmin values!!
Exiting ..."
    exit;
fi

spin()
{
    t=1
    load="/-\|"
    while [ $t -eq 1 ]; do
        for (( s=0; s<${#load}; s++ )); do
            sleep 0.75
            echo -en "Calculating the rate of change of $atname... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

touch $address/$filename/${filename}.dat  $address/$filename/${filename}_f.dat
echo "Rate of change of" $atname "with respect to time Column 1: time(PS); Column 2: No. of molecules; Column 3: Percentage of change; Co" > $address/$filename/${filename}.dat
touch $address/$filename/time.dat
while [ ${start} -le ${end} ]; do
    awk -v xpp="${xp}" -v xnn="${xn}" -v ypp="${yp}" -v ynn="${yn}" -v zpp="${zp}" -v znn="${zn}"  '{if ( $3<=xpp && $3>=xnn && $4<=ypp && $4>=ynn && $5<=zpp && $5>=znn ) print}' "${address}"/"${filename}"/coord_${start}.dat | wc -l >> $address/$filename/${filename}.dat
    # The above command captures and counts all the water molecules present in user defined space 
    echo ${start} >> $address/$filename/time.dat
    start=$[${start}+${skip}]
done

v=( $(awk '{print $1}' $address/$filename/${filename}.dat) )
avg=`echo ${v[@]} | awk ' {sum=0;for (i=1;i<=NF;i++) sum+=$i; print sum / NF; }'`

# Below piece of code is for calculating volume accessible, it is just multiplication of number of water molecules and molar volume (intrinsic property of sovent moleclecule i.e. water will have differnt molar volume from potassium)

ar=( $(awk '{print $1}' $address/$filename/${filename}.dat) )
IFS=$'\n'
 
tail -n +2  $address/$filename/${filename}.dat | awk  -v cons="${con}" -v m="${max}" '{printf "%i    %4.2f\n",$1,     cons*$1 }'>> $address/$filename/${filename}_f.dat

echo "This file contains the number of $atname present within the user-defined space with respect to time. 
Column 1: Time (*${time}ps)     Column 2: Number of ${atname}     Column 3: Volume occupied by ${atname} (*10^-23 cm^3)
The mean number of ${atname} is $avg " > $address/$filename/Rate_output.dat
paste $address/$filename/time.dat $address/$filename/${filename}_f.dat >> $address/$filename/Rate_output.dat

cat << __EOF | gnuplot
set terminal pngcairo size 800,600
set border linewidth 3
set output '$address/$filename/Rate_number.png'
set title 'Number of ${atname} with respect to time (Mean = $avg)' font "Helvetica-bold, 18"
set xlabel 'Time (*${time}ps)' font "Helvetica-bold, 16"
set ylabel 'Number of ${atname} molecules' font "Helvetica-bold, 16"
set xtics font "Helvetica-bold, 14"
set ytics font "Helvetica-bold, 14"
set key off
plot '$address/$filename/Rate_output.dat' using 1:2 with linespoints pointsize 1 pointtype 7 lw 3 linecolor rgb "#009900"

set output '$address/$filename/Rate_volume.png'
set title 'Change in volume of ${atname} with time' font "Helvetica-bold, 18"
set xlabel 'Time (*${time}ps)' font "Helvetica-bold, 16"
set ylabel 'Volume of ${atname} molecules' font "Helvetica-bold, 16"
set xtics font "Helvetica-bold, 14"
set ytics font "Helvetica-bold, 14"
set key off
plot '$address/$filename/Rate_output.dat' using 1:3 with linespoints pointsize 1 pointtype 7 lw 3 linecolor rgb "#86592d"
__EOF

rm $address/$filename/${filename}_f.dat ${filename}_f1.dat $address/$filename/${filename}.dat $address/$filename/time.dat 2> /dev/null
rm *.png 2> /dev/null
rm *.dat 2> /dev/null
rm $address/$filename/coord*.dat 2> /dev/null
rm $address/$filename/atmlist.dat 2> /dev/null

kill -9 $spin_pid
sleep 1
above_line=$(tput cuu1)
erase_line=$(tput el)
echo "$above_line$erase_line"

echo "The output files are stored in "$filename "at" $address/$filename
echo "1. Continue    2. Back    3. Quit"
echo -n "Enter an option (1, 2, or 3) and press [ENTER]: "
    read option
if [ $option -eq 1 ]; then
    $MDTAPpath/Rateofchangeofmolecules-DCD.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi