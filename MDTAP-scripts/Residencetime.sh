#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 7. Residence time"
echo " ----------------------------------------------------------------------------------"
echo "This module takes atom numbers (as defined in the PDB files) in the form of a text file as an input and captures its initial and final PDB files in the specific region and calculates time spent in that region." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
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
echo  "Enter the name of the input file having the atom IDs (Note: the input file should be stored in the folder where the PDBs are present) and press [ENTER]: "
    read input
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
gap=`echo "${time}*${skip}"| bc -l`
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
            echo -en "Calculating the residence time of the provided atom numbers in the channel... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

echo " " > $address/$filename/${filename}.dat
id=( $(awk '{print $1}' "${address}"/${input}) )
xi=`echo ${#id[@]}`
start1=${start}

for ((k=0; k<$xi; k++)); do
    idchk=`grep ${id[${k}]} "${address}"/step_${start1}.pdb | wc -l`
    idchk1=`grep ${id[${k}]} "${address}"/step_${start1}.pdb`
    if [ $idchk -le 0 ] ; then
      echo "Atom number/id " ${id[${k}]} " not present - check PDB"
      rm -rf "${address}"/$filename/
      exit
    fi
    touch $address/$filename/${id[${k}]}.dat
    chmod 755 *
    f=${id[${k}]}
    while [ ${start1} -le ${end} ]; do
        if [ -z $chainid ]; then
            cat "${address}"/step_${start1}.pdb | grep -i " $chainid " | grep -i " $segid " | awk -v s="${id[${k}]}" -v t="${start1}" -v xpp="${xp}" -v xnn="${xn}" -v ypp="${yp}" -v ynn="${yn}" -v zpp="${zp}" -v znn="${zn}"  '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn && $2==s) print t}' >> $address/$filename/${id[${k}]}.dat
        else
            cat "${address}"/step_${start1}.pdb | grep -i " $chainid " | grep -i " $segid " | awk -v s="${id[${k}]}" -v t="${start1}" -v xpp="${xp}" -v xnn="${xn}" -v ypp="${yp}" -v ynn="${yn}" -v zpp="${zp}" -v znn="${zn}"  '{if ( $7<=xpp && $7>=xnn && $8<=ypp && $8>=ynn && $9<=zpp && $9>=znn && $2==s) print t}' >> $address/$filename/${id[${k}]}.dat
        fi
        start1=$[${start1}+${skip}]
    done
    start1=${start}
done

touch $address/$filename/${filename}_time.dat


for (( a=0; a<$xi; a++ )); do
  if [ -s $address/$filename/${id[${a}]}.dat ] ; then
    w=( $(awk '{print $1}' $address/$filename/${id[${a}]}.dat) )
    t=`echo ${#w[@]}-1 | bc -l`
    printf "%i   %i \n" ${id[${a}]}   ${t}  >> $address/$filename/${filename}_time.dat
    rm $address/$filename/${id[${a}]}.dat
  else
    printf "%i   %i \n" ${id[${a}]}   0  >> $address/$filename/${filename}_time.dat
    rm $address/$filename/${id[${a}]}.dat
  fi
done

echo "This file contains the residence time of the provided atom numbers.
Column 1: Atom number     Column 2: Residence time (*${time}ps)" > $address/$filename/Residence_time.dat 
paste $address/$filename/${filename}_time.dat >> $address/$filename/Residence_time.dat 

rm $address/$filename/${filename}.dat $address/$filename/${filename}_time.dat 
rm *.png 2> /dev/null
rm *.dat 2> /dev/null

kill -9 $spin_pid
sleep 1
above_line=$(tput cuu1)
erase_line=$(tput el)
echo "$above_line$erase_line"

echo "The output files are stored in" $filename "at" $address/$filename
echo -n "Enter your option (1, 2, or 3) and press [ENTER]: "
    read option
if [ $option -eq 1 ]; then
    $MDTAPpath/Residencetime.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi