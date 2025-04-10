#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 9. Distance calculation"
echo " ----------------------------------------------------------------------------------"
echo "This module calculates the distance between the electronegative atoms of the molecule(s) of interest and the channel residues, and reports atoms that are within 3.5 Å of each other, along with the frequency of occurrence." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo "Enter the residue name of the molecule of interest (e.g. TIP for water) and press [ENTER]: "
    read resname
if ( [ -z $resname ] ) ; then
   echo "Please enter the resname of the molecule of interest, this is required to fetch the molecule residues!
Exiting ..."
   exit;
fi
echo "Enter the address/path of the PDBs and press [ENTER] (Note: if the PDB files are present in the working directory, type '.' and press [ENTER]): "
    read addres
echo "Enter the start PDB (e.g. if step_10.pdb is the starting PDB, then enter '10') and press [ENTER]: "
    read start
echo "Enter the end PDB (e.g. if step_500.pdb is the final PDB, then enter '500') and press [ENTER]: "
    read end
echo  "Enter the PDBs to skip and press [ENTER]: "
    read skip
if ( [ -z $skip ] || [ $skip == 0 ] ) ; then
   echo "Please enter a value greater than zero!
Exiting ..."
   exit;
fi
echo  "Enter chain ID and press [ENTER] (Note: chain ID is considered only for the channel. If absent in the PDB files, just press [ENTER]): "
    read chainid
echo  "Enter seg ID and press [ENTER] (Note: seg ID is considered only for the channel. If absent in the PDB files, just press [ENTER]): "
    read segid
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
gap=`echo "${time}*${skip}"| bc -l`
chmod 755 *
rm -r $address/$filename 2> /dev/null
mkdir $address/$filename

awk -v cid="$chainid" '{ if ($5 ~ cid) print}' "${address}"/step_${start}.pdb | awk '{ if ((($4 ~ /ALA|GLY|LEU|VAL|ASN|ASP|ARG|TRP|SER|ILE|HIS|THR|PRO|GLN|GLU|LYS|TYR|PHE|MET|CYS|ADE|GUA|CYT|THY|URA|URI/) || ($4 == "DA")  || ($4 == "DG") || ($4 == "DC") || ($4 == "DT") || ($4 == "RA")  || ($4 == "RG") || ($4 == "RC") || ($4 == "RT") || ($4 == "RU") || ($4 == "A") || ($4 == "C") || ($4 == "D") || ($4 == "E") || ($4 == "F") || ($4 == "G") || ($4 == "H") || ($4 == "I") || ($4 == "K") || ($4 == "L") || ($4 == "M") || ($4 == "N") || ($4 == "P") || ($4 == "Q") || ($4 == "R") || ($4 == "S") || ($4 == "T") || ($4 == "U") || ($4 == "V") || ($4 == "W") || ($4 == "Y")) && ($1 == "ATOM") && ($3 != $4)) print }' | grep -i " $segid " > $address/$filename/step.pdb
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

if ( [ ${#x[@]} -eq 0 ] || [ ${#y[@]} -eq 0 ] || [ ${#z[@]} -eq 0 ] ); then
    echo "WARNING: The 4th column of input the PDB files do not have amino acid (e.g. ALA, GLY, LEU, ... OR A, G, L, ...) or nucleotide residues (e.g ADE, GUA, CYT, ... OR DA, DG, DC, ...)."
    echo "Do you want to continue by considering all atoms in the system? (type yes/no and press [ENTER]): "
        read choice
    if [[ "$choice" == "yes" || "$choice" == "y" || "$choice" == "Y" || "$choice" == "Yes" || "$choice" == "YES" ]]; then
        echo "Continuing with all atoms..."
        awk -v cid="$chainid" '{ if ($5 ~ cid) print}' "${address}"/step_${start}.pdb | grep -i " $segid" > $address/$filename/step.pdb
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
    elif [[ "$choice" == "no" || "$choice" == "n" || "$choice" == "N" || "$choice" == "No" || "$choice" == "NO" ]]; then
        echo "Exiting ..."
        exit;
    else
        echo "Invalid input. Exiting ..."
        exit;
    fi
fi

echo "Based on the results generated by the 'Z-density profile' and 'XY-area profile' modules, it is recommended to choose suitable X, Y, and Z limits with relaxations (as required) for accurate calculations.
Recommended dimensions (Xmax Xmin Ymax Ymin Zmax Zmin) for the channel are:" $a $a1 $b $b1 $c $c1
echo "Enter the channel limits (Xmax Xmin Ymax Ymin Zmax Zmin) and press [ENTER]: "
    read limits

if ( [ -z $limits ] ) ; then
   echo "Please enter the channel limits!
Exiting ..."
   exit;
fi

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

wd=`pwd`

echo -e "\nDistance calculation is going on. Please wait, as this could take a while."

echo -e "This file contains the details of the atoms that are in close proximity (< 3.5 Å) with each other.\n
Column 1: Distance (Å), Column 2: Atom name of permeating molecule, Column 3: Atom number of permeating molecule, Column 4: Residue name of permeating molecule, Column 5: Residue number of permeating molecule, Column 6: Atom name of channel residue, Column 7: Atom number of channel residue, Column 8: Residue name of channel residue, Column 9: Residue number of channel residue\n" > $address/$filename/Distance.dat 


while [ ${start} -le ${end} ]; do
    awk -v cid="$chainid" '{ if ($5 ~ cid) print}' "${address}"/step_${start}.pdb | awk '{ if ((($4 ~ /ALA|GLY|LEU|VAL|ASN|ASP|ARG|TRP|SER|ILE|HIS|THR|PRO|GLN|GLU|LYS|TYR|PHE|MET|CYS|ADE|GUA|CYT|THY|URA|URI/) || ($4 == "DA")  || ($4 == "DG") || ($4 == "DC") || ($4 == "DT") || ($4 == "RA")  || ($4 == "RG") || ($4 == "RC") || ($4 == "RT") || ($4 == "RU") || ($4 == "A") || ($4 == "C") || ($4 == "D") || ($4 == "E") || ($4 == "F") || ($4 == "G") || ($4 == "H") || ($4 == "I") || ($4 == "K") || ($4 == "L") || ($4 == "M") || ($4 == "N") || ($4 == "P") || ($4 == "Q") || ($4 == "R") || ($4 == "S") || ($4 == "T") || ($4 == "U") || ($4 == "V") || ($4 == "W") || ($4 == "Y")) && ($1 == "ATOM") && ($3 != $4)) print }' | grep -i " $segid" | grep -E "^(ATOM|HETATM)" | awk '($3 ~ /^[NOSF]/) {print $2, $3, $4, $5, $6, $7, $8}' > $address/$filename/channel.dat
    awk -v res="$resname" -v xpp="$xp" -v xnn="$xn" -v ypp="$yp" -v ynn="$yn" -v zpp="$zp" -v znn="$zn" '($1 == "ATOM" || $1 == "HETATM") && $4 == res && $6 <= xpp && $6 >= xnn && $7 <= ypp && $7 >= ynn && $8 <= zpp && $8 >= znn && $3 ~ /^[NOSF]/ {print $2, $3, $4, $5, $6, $7, $8}' "${address}/step_${start}.pdb" > ${address}/${filename}/molecule.dat
    echo "====================================================================================" >> $address/$filename/Distance.dat 
    echo "    File name: "${address}"/step_${start}.pdb" >> $address/$filename/Distance.dat 
    echo "====================================================================================" >> $address/$filename/Distance.dat 
    cd $address/$filename/
    python $MDTAPpath/Distance_calculator.py
    cd $wd
    start=$[${start}+${skip}]
done

echo "This file contains the list of channel residues that are in close proximity (< 3.5 Å) to the molecule(s) of interest ($resname) in each PDB file.
Column 1: PDB file name, Column 2: Residue name, Column 3: Residue number" > $address/$filename/Residues.dat
awk '/File name:/ {split($0, a, ": "); file=a[2]; next} /^[0-9]/ {print file, $8, $9}' $address/$filename/Distance.dat | sort -u | tr -d ',' >> $address/$filename/Residues.dat
echo "This file contains the frequency of the channel residues that are in close proximity (< 3.5 Å) to the molecule(s) of interest ($resname) across all PDB files.
Column 1: Frequency, Column 2: Residue name, Column 3: Residue number" > $address/$filename/Frequency.dat
awk '{print $2, $3}' $address/$filename/Residues.dat | sort -nk2 | uniq -c | sort -nr >> $address/$filename/Frequency.dat

rm ${address}/${filename}/molecule.dat ${address}/${filename}/channel.dat ${address}/${filename}/step.pdb

echo "The output files are stored in" $filename "at" $address/$filename
echo "1. Continue    2. Back    3. Quit"
echo -n "Enter an option (1, 2, or 3) and press [ENTER]: "
    read option
if [ $option -eq 1 ]; then
    $MDTAPpath/Distance.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi
