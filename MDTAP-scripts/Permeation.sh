#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 4. Permeation"
echo " ----------------------------------------------------------------------------------"
echo "This module captures the molecules that permeate through the channel across either direction and lists the atom numbers of the permeating and non-permeating molecules." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
starttime=`date`
echo "Enter the molecule of interest (e.g. OH2 TIP for water oxygens) and press [ENTER]: "
    read molecule
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
echo "Enter the difference in time (in picoseconds) between each PDB and [ENTER]:
(e.g. If the PDBs are generated at every 10ps interval, then enter '10')"
    read time
echo  "Enter chain ID and press [ENTER] (Note: chain ID is considered only for the channel. If absent in the PDB files, just press [ENTER]): "
    read chainid
echo  "Enter seg ID and press [ENTER] (Note: seg ID is considered only for the channel. If absent in the PDB files, just press [ENTER]): "
    read segid
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
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

echo -e "\nPermeation calculation is going on. Please wait, as this could take a while."

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

Zmax=$zp
Zmin=$zn

zhh=`printf %.0f $zp`
zll=`printf %.0f $zn`

touch $address/$filename/all-atoms.dat

start1=`echo ${start}`

while [ ${start} -le  ${end} ]; do
    grep -i "${molecule}" "${address}"/step_${start}.pdb | awk -v xpp="${xp}" -v xnn="${xn}" -v ypp="${yp}" -v ynn="${yn}" -v zpp="${zhh}" -v znn="${zll}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn ) printf " %5i \n", $2}' >> $address/$filename/all-atoms.dat
    start=$[${start}+${skip}]
done

start=`echo ${start1}`

echo "This file contains the list of atom numbers of $molecule that were found within the channel limits (Xmax=$xp, Xmin=$xn, Ymax=$yp, Ymin=$yn, Zmax=$zp, and Zmin=$zn)." > $address/$filename/Atom_list.dat

sort -u $address/$filename/all-atoms.dat >> $address/$filename/Atom_list.dat

name=( $(awk '{print $1}' ./$address/$filename/Atom_list.dat) )  # uniq atom array
x=`echo ${#name[@]}`  # number of uniq atoms to be used in for loop for score calculation
score=0
echo "This file contains the frequency of occurrence of the permeating molecule: $molecule
Column 1: atom numbers of $molecule in the user-defined area     Column 2: Permeation frequency" > $address/$filename/Atom_frequency.dat

for ((k=1; k<$x; k=$[${k}+1])); do
    if grep -Fxq " ${name[${k}]} " $address/$filename/all-atoms.dat
    then
        score=`grep " ${name[${k}]} " $address/$filename/all-atoms.dat | wc -l`
    fi
    echo ${name[${k}]}"   "${score} >> $address/$filename/Atom_frequency.dat
    score=0
done

rm $address/$filename/all-atoms.dat

lines=`wc -l $address/$filename/Atom_frequency.dat | awk '{print $1}'`
lines=$[${lines}-2]
allscore=(`tail -$lines $address/$filename/Atom_frequency.dat | awk '{print $2}' | sort -nk1 -u`)
testscore=0

echo "-----------------------------------------------------------------------------"
for ((i=0; i<${#allscore[@]}; i++)) ; do
    indscore=`tail -$lines $address/$filename/Atom_frequency.dat | awk -v inscore=${allscore[i]} '{if ( $2 == inscore ) print $1}' | wc -l`
    echo "   The number of atoms that occurred ${allscore[$i]} times within the given limits =" $indscore
done
echo "-----------------------------------------------------------------------------"

echo "Based on the frequency of occurrence of the atoms ($molecule) in the PDBs as shown above, enter the minimum frequency that should be considered for the calculation and press [ENTER]:
(e.g. if the entered value is 3, all the atoms ($molecule) that occurred a minimum of 3 times within the defined limits will be taken for the calculation)"
    read maxscore
if [ -z $maxscore ]; then
    maxscore=`tail -$lines  $address/$filename/Atom_frequency.dat | sort -nk2 | tail -1 | awk '{print $2}'`
fi
maxatom=( $(tail -$lines  $address/$filename/Atom_frequency.dat | awk -v max1="$maxscore" '{if ( $2 >= max1 ) print $1}'))

touch $address/$filename/Permeation_max.dat
echo "This file contains the list of atom numbers of $molecule that have a occurred at least $maxscore times within the user-defined limits." >> $address/$filename/Permeation_max.dat
tail -$lines  $address/$filename/Atom_frequency.dat | awk -v max1="$maxscore" '{if ( $2 >= max1 ) print $1}' >> $address/$filename/Permeation_max.dat

x=`echo ${#maxatom[@]}`

echo "The number of atoms that acquired a score greater than or equal to $maxscore is $x"
score=0
maxzdim=$[${zhh}-${zll}]
echo "The height of the channel (Z-axis) as per the Z-coordinates defined is (Zmax=$Zmax and Zmin=$Zmin) is ${maxzdim#-}"

Zmax=${zhh}
Zmin=${zll}

echo "
******************************************************************************
   The following are the parameters used for the calculation of permeation:
------------------------------------------------------------------------------
      Molecule of interest = ${molecule}
      Start PDB file = ${start}
      End PDB file = ${end}
      PDBs to skip = ${skip}
      Chain ID = ${chainid}
      Seg ID = ${segid}
      Maximum Z-coordinate = ${zhh}
      Minimum Z-coordinate = ${zll}
      Height of the channel (Z-dimension) for permeation = ${maxzdim#-}
      Minimum frequency of occurrence considered = $maxscore
      Number of atoms above the minimum cut-off frequency = $x
******************************************************************************
"

touch $address/$filename/Permeation-dir1.dat $address/$filename/Permeation-dir2.dat $address/$filename/Non-permeating.dat

echo "This file contains the list of atom numbers of the molecules that are permeating across the channel in direction 1." > $address/$filename/Permeation-dir1.dat
echo "This file contains the list of atom numbers of the molecules that are permeating across the channel in direction 2." > $address/$filename/Permeation-dir2.dat
echo "This file contains the list of atom numbers of the molecules that do not permeate across the channel." > $address/$filename/Non-permeating.dat

mkdir $address/$filename/Permeation-dir1 $address/$filename/Permeation-dir2 $address/$filename/Non-permeating $address/$filename/tempPDBs

for ((pdb=${start}; pdb<=${end}; pdb=pdb+${skip})); do
    cp $address/step_${pdb}.pdb $address/$filename/tempPDBs/step_${pdb}.pdb
done

for ((i=0; i<${#maxatom[@]}; i=i+1)); do
    touch $address/$filename/temp.pdb  $address/$filename/${maxatom[$i]}.pdb $address/$filename/temp.dat
    grep "${maxatom[$i]}" $address/$filename/tempPDBs/step_*.pdb | awk  -v xpp="${xp}" -v xnn="${xn}" -v ypp="${yp}" -v ynn="${yn}" -v zpp="${zp}" -v znn="${zn}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn ) print}' | sort -Vk1 > $address/$filename/temp.pdb
    cat $address/$filename/step.pdb > $address/$filename/${maxatom[$i]}.pdb
    echo "TER" >> $address/$filename/${maxatom[$i]}.pdb
    awk -F ':' '{print $2}' $address/$filename/temp.pdb >> $address/$filename/${maxatom[$i]}.pdb   # creating the coordinate of the molecule inside the channel
    echo "END" >> $address/$filename/${maxatom[$i]}.pdb
    cat $address/$filename/temp.pdb | awk -F ':' '{print $1}' | awk -F 'step_' '{print $2}' | awk -F '.pdb' '{print $1}'   | awk -v skip=$skip '{ for (j = 1; j <= NF; j++) {
        lin[i++] = $j;
        }
    }

END {
    start = lin[0];
    j = 1;
    while (j <= i) {
        end = start
        while (lin[j] == (lin[j-1]+skip)) {
            end = lin[j++];
             }
        if ((end+0) > (start+0)) {
                printf "%d-%d ",start,end
                printf "\n"
            } else {
                printf "%d ",start
                printf "\n"
            }
        start = lin[j++];
        }
    } '   > $address/$filename/temp.dat
    perm=( `grep '-' $address/$filename/temp.dat` )

    echo "================================================================================"
    echo -e "   ATOM number = "${maxatom[$i]}"\n--------------------------------------------------------------------------------\n   Number of permeating events = "${#perm[@]}"\n   PDB ranges for permeation = "${perm[@]}"\n" 
    
    for ((ii=0 ; ii<${#perm[@]}; ii=ii+1)); do
        enPDB=`echo ${perm[$ii]} | cut -d"-" -f1 | tr -d ' '`  # subtracted by 1 to find next PDB; required for channel dimension
        exPDB=`echo ${perm[$ii]} | cut -d"-" -f2 | tr -d ' '`  # added by 1 to find previous PDB; required for channel dimension
        entryZ=`awk -v atm=${maxatom[i]} '{if ( $2 == atm ) print $8}' $address/step_$enPDB.pdb` # Z-coordinate of the exiting PDB
        exitZ=`awk -v atm=${maxatom[i]} '{if ( $2 == atm ) print $8}' $address/step_$exPDB.pdb` # Z-coordinate of the exiting PDB

        tempEnZ0=`printf %0.f $entryZ`
        tempEnZ1=$[${tempEnZ0}-${zhh}]
        tempEnZ2=$[${tempEnZ0}-${zll}]

        tempExZ0=`printf %0.f $exitZ`
        tempExZ1=$[${tempExZ0}-${zhh}]
        tempExZ2=$[${tempExZ0}-${zll}]

        if [ $enPDB -ge $[${start}+${skip}] ]; then
            entryPDB=$[${enPDB}-${skip}]   # required to see the previous position of the molecule
        else
            entryPDB=${enPDB}
        fi

        if [ $exPDB -le $[${end}-${skip}] ]; then
            exitPDB=$[${exPDB}+${skip}]    # required to see the next position of the molecule
        else
            exitPDB=${exPDB}
        fi

        entryZ1=`awk -v atm=${maxatom[i]} '{if ( $2 == atm ) print $8}' $address/step_$entryPDB.pdb` # Z-coordinate of previous PDB; required for directionality
        exitZ1=`awk -v atm=${maxatom[i]} '{if ( $2 == atm ) print $8}' $address/step_$exitPDB.pdb` # Z-coordinate of exiting PDB; required for directionality 

        tempEnZ0=`printf %0.f $entryZ1`
        tempExZ0=`printf %0.f $exitZ1`
        actdim=$[${tempEnZ0}-${tempExZ0}] # required to see if the molecule has crossed the channel    

        echo -e "     Entry PDB = step_$enPDB.pdb \n     Exit PDB  = step_$exPDB.pdb \n     Entry Z-coordinate = $entryZ \n     Exit Z-coordinate  = $exitZ \n\n   Using the Z-coordinates of PDBs before and after entry & exit respectively:\n     Current dimension = ${actdim#-} \n     Channel dimension = ${maxzdim#-}\n"
        if ( [ ${entryPDB} == ${enPDB} ] || [ ${exitPDB} == ${exPDB} ] ); then
            if ( [ $tempEnZ0 -lt $zhh ] || [ $tempExZ0 -gt $zll ] ); then    # if the molecule is already inside the channel
                echo -e "   Atom number ${maxatom[$i]} is Non-permeating\n"
                cp $address/$filename/${maxatom[$i]}.pdb $address/$filename/Non-permeating/${maxatom[$i]}_Non-permeating.pdb
                echo ${maxatom[$i]} >> $address/$filename/Non-permeating.dat
                continue
            fi
        fi
        
        if  [ ${actdim#-} -lt ${maxzdim#-} ] ;  then
            echo -e "   Atom number ${maxatom[$i]} is Non-permeating\n"
            cp $address/$filename/${maxatom[$i]}.pdb $address/$filename/Non-permeating/${maxatom[$i]}_Non-permeating.pdb
            echo ${maxatom[$i]} >> $address/$filename/Non-permeating.dat
        else
            if ( [ ${tempEnZ1#-} -lt ${tempEnZ2#-} ] && [ ${tempExZ1#-} -gt ${tempExZ2#-} ]  ); then
                echo -e "   Atom number ${maxatom[$i]} is permeating in Direction 1\n"
                cp $address/$filename/${maxatom[$i]}.pdb $address/$filename/Permeation-dir1/${maxatom[$i]}_Direction-1.pdb
                echo ${maxatom[$i]} >> $address/$filename/Permeation-dir1.dat
            elif ( [ ${tempEnZ1#-} -gt ${tempEnZ2#-} ] && [ ${tempExZ1#-} -lt ${tempExZ2#-} ]  ); then
                echo -e "   Atom number ${maxatom[$i]} is permeating in Direction 2\n"
                cp $address/$filename/${maxatom[$i]}.pdb $address/$filename/Permeation-dir2/${maxatom[$i]}_Direction-2.pdb
                echo ${maxatom[$i]} >> $address/$filename/Permeation-dir2.dat
            else
                echo -e "   Atom number ${maxatom[$i]} is Non-permeating. Directionality issue!\n"
                cp $address/$filename/${maxatom[$i]}.pdb $address/$filename/Non-permeating/${maxatom[$i]}_Non-permeating.pdb
                echo ${maxatom[$i]} >> $address/$filename/Non-permeating.dat
            fi
        fi
    done
    rm $address/$filename/${maxatom[$i]}.pdb  $address/$filename/temp.pdb $address/$filename/temp.dat
done

echo "================================================================================"

rm -rf $address/$filename/step.pdb $address/$filename/tempPDBs
endtime=`date`
echo "Permeation calculation start time :" $starttime
echo "Permeation calculation end time   :" $endtime

echo -e "\nThe output files are stored in" $filename "at" $address/$filename
echo "The user can verify the PDBs generated by this module (under Permeation-dir1/Permeation-dir2/Non-permeating folders) and further track the path traced by the atom numbers listed using the 'Track molecule' (APM #7)"
echo "1. Continue    2. Back    3. Quit"
echo -n "Enter an option (1, 2, or 3) and press [ENTER]: "
    read option
if [ $option -eq 1 ]; then
    $MDTAPpath/Permeation.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi
