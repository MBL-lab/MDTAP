#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 3. Rate of change of molecules"
echo " ----------------------------------------------------------------------------------"
echo "This module calculates the number of water molecules present within the protein or in any user-defined area with respect to time." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo "Enter your molecule of interest (e.g. OH2 TIP for water oxygens) and press [ENTER]: "
    read molecule
echo "Enter the address/path of the PDBs and press [ENTER] (Note: if your PDB files are present in the working directory, just press [ENTER]): "
    read addres
echo "Enter your start PDB (e.g. if step_10.pdb is the starting PDB, then enter '10') and press [ENTER]: "
    read start
echo "Enter your end PDB (e.g. if step_500.pdb is the final PDB, then enter '500') and press [ENTER]: "
    read end
echo  "Enter the PDBs to skip and press [ENTER]: "
    read skip
if ( [ -z $skip ] || [ $skip == 0 ] ) ; then
   echo "Please enter a value greater than zero!
Exiting ..."
   exit;
fi
echo "Enter the difference in time (in picoseconds) between each PDB and [ENTER]:
(e.g. If your PDBs are generated at every 10ps interval, then enter '10')"
    read time
echo  "Enter chain ID and press [ENTER] (Note: chain ID is considered only for the channel. If absent in the PDB files, just press [ENTER]): "
    read chainid
echo  "Enter seg ID and press [ENTER] (Note: seg ID is considered only for the channel. If absent in the PDB files, just press [ENTER]): "
    read segid
echo "Enter the molar volume of your molecule and press [ENTER]: 
(e.g the molar volume of Water = 18.07cm^3, Sodium = 23.78cm^3, and Chlorine = 22.40cm^3. Note: You are free to enter any value specific to your molecule of interest apart from the examples given.)"
    read volume
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
con=`echo "${volume}/6.024" | bc -l`
chmod 755 *
rm -r $address/$filename 2> /dev/null
mkdir $address/$filename
awk -v cid="$chainid" '{ if ($5 ~ cid) print}' "${address}"/step_${start}.pdb | awk '{ if ((($4 ~ /ALA|GLY|LEU|VAL|ASN|ASP|ARG|TRP|SER|ILE|HSD|THR|PRO|GLN|GLU|LYS|TYR|PHE|MET|CYS|ADE|GUA|CYT|THY|URA|URI/) || ($4 == "DA")  || ($4 == "DG") || ($4 == "DC") || ($4 == "DT") || ($4 == "RA")  || ($4 == "RG") || ($4 == "RC") || ($4 == "RT") || ($4 == "RU") || ($4 == "A") || ($4 == "C") || ($4 == "D") || ($4 == "E") || ($4 == "F") || ($4 == "G") || ($4 == "H") || ($4 == "I") || ($4 == "K") || ($4 == "L") || ($4 == "M") || ($4 == "N") || ($4 == "P") || ($4 == "Q") || ($4 == "R") || ($4 == "S") || ($4 == "T") || ($4 == "U") || ($4 == "V") || ($4 == "W") || ($4 == "Y")) && ($1 == "ATOM") && ($3 != $4)) print }' | grep -i " $segid " > $address/$filename/step.pdb
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

rm $address/$filename/step.pdb

if ( [ ${#x[@]} -eq 0 ] || [ ${#y[@]} -eq 0 ] || [ ${#z[@]} -eq 0 ] ); then
   echo "There is a problem with the input PDBs! Ensure that the 4th column of your PDB files has either amino acid (e.g. ALA, GLY, LEU, ... OR A, G, L, ...) or nucleotide residues (e.g ADE, GUA, CYT, ... OR DA, DG, DC, ...).
Exiting ..."
   exit;
fi

echo "Recommended dimensions (Xmax Xmin Ymax Ymin Zmax Zmin) for your channel are:" $a $a1 $b $b1 $c $c1
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
            echo -en "Calculating the rate of change of $molecule... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

touch $address/$filename/${filename}.dat  $address/$filename/${filename}_f.dat
echo "Rate of change of" $molecule "with respect to time Column 1: time(PS); Column 2: No. of molecules; Column 3: Percentage of change; Co" > $address/$filename/${filename}.dat
touch $address/$filename/time.dat
while [ ${start} -le ${end} ]; do
    grep -i "${molecule}" "${address}"/step_${start}.pdb | awk -v xpp="${xp}" -v xnn="${xn}" -v ypp="${yp}" -v ynn="${yn}" -v zpp="${zp}" -v znn="${zn}"  '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn ) print}'| wc -l >> $address/$filename/${filename}.dat
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

echo "This file contains the number of $molecule present within the user-defined space with respect to time. 
Column 1: Time (*${time}ps)     Column 2: Number of ${molecule}     Column 3: Volume occupied by ${molecule} (*10^-23 cm^3)
The mean number of ${molecule} is $avg " > $address/$filename/Rate_output.dat
paste $address/$filename/time.dat $address/$filename/${filename}_f.dat >> $address/$filename/Rate_output.dat

cat << __EOF | gnuplot
set terminal pngcairo size 800,600
set border linewidth 3
set output '$address/$filename/Rate_number.png'
set title 'Number of ${molecule} with respect to time (Mean = $avg)' font "Helvetica-bold, 18"
set xlabel 'Time (*${time}ps)' font "Helvetica-bold, 16"
set ylabel 'Number of ${molecule} molecules' font "Helvetica-bold, 16"
set xtics font "Helvetica-bold, 14"
set ytics font "Helvetica-bold, 14"
set key off
plot '$address/$filename/Rate_output.dat' using 1:2 with linespoints pointsize 1 pointtype 7 lw 3 linecolor rgb "#009900"

set output '$address/$filename/Rate_volume.png'
set title 'Change in volume of ${molecule} with time' font "Helvetica-bold, 18"
set xlabel 'Time (*${time}ps)' font "Helvetica-bold, 16"
set ylabel 'Volume of ${molecule} molecules' font "Helvetica-bold, 16"
set xtics font "Helvetica-bold, 14"
set ytics font "Helvetica-bold, 14"
set key off
plot '$address/$filename/Rate_output.dat' using 1:3 with linespoints pointsize 1 pointtype 7 lw 3 linecolor rgb "#86592d"
__EOF

rm $address/$filename/${filename}_f.dat ${filename}_f1.dat $address/$filename/${filename}.dat $address/$filename/time.dat 2> /dev/null
rm *.png 2> /dev/null
rm *.dat 2> /dev/null

kill -9 $spin_pid
sleep 1
above_line=$(tput cuu1)
erase_line=$(tput el)
echo "$above_line$erase_line"

echo "The output files are stored in "$filename "at" $address/$filename
echo "1. Continue    2. Back    3. Quit"
echo -n "Enter your option (1, 2, or 3) and press [ENTER]: "
    read option
if [ $option -eq 1 ]; then
    $MDTAPpath/Rateofchangeofmolecules.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi