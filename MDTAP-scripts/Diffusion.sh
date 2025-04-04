#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 8. Diffusion entry/exit"
echo " ----------------------------------------------------------------------------------"
echo "This module calculates the number of solvent molecules that enter or exit through an entry point defined by three amino acid residues." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo "Enter the molecule of interest (e.g. OH2 TIP for water oxygens) and press [ENTER]: "
    read molecule
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
echo  "Enter chain ID and press [ENTER] (Note: chain ID is considered only for the channel. If absent in the PDB files, just press [ENTER]): "
    read chainid
echo  "Enter seg ID and press [ENTER] (Note: seg ID is considered only for the channel. If absent in the PDB files, just press [ENTER]): "
    read segid
echo "Enter channel residues along with the residue numbers (e.g. GLN 102 TYR 380 PHE 427) and press [ENTER]: "
    read amino
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

spin()
{
    t=1
    load="/-\|"
    while [ $t -eq 1 ]; do
        for (( s=0; s<${#load}; s++ )); do
            sleep 0.75
            echo -en "Calculating the number of $molecule crossing the plane defined by the channel residues... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

chmod 755 *
homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
rm -r $address/$filename 2> /dev/null
mkdir $address/$filename
echo $amino > $address/$filename/amino.dat

num=`cat $address/$filename/amino.dat | wc -w`

if (( $num == 0 || $num % 2 != 0 )); then
    echo "Please check the entered channel residues and their respective positions"
    exit
else
    for ((i=1; i<= $num/2 ; i=$[${i}+1])); do
        col1=$(((i * 2) - 1))
        col2=$((i * 2))
        aa[$i]=`cat $address/$filename/amino.dat | awk -v col="$col1" '{print $col}'`
        a[$i]=`cat $address/$filename/amino.dat | awk -v col="$col2" '{print $col}'`
    done
fi

rm $address/$filename/amino.dat

start10=$start
start11=$start
start1=$start

for ((i=1; i<= $num/2 ; i=$[${i}+1])); do
    grep -i "${aa[$i]}" "${address}"/step_*.pdb | grep -i " $segid" | awk -v u="${a[$i]}" '{if ( $5 == u || $6 == u ) print}'  > $address/$filename/test-$i.pdb
    X=()
    Y=()
    Z=()
    c=()
    while read -r line; do
        m=`echo $line | awk '{if (($3 ~ /C[A-Z]|C[1-9]/) || ($3 == "C"))  m=12.011 ; else if (($3 ~ /N[A-Z]|N[1-9]/) || ($3 == "N")) m=14.006; else if (($3 ~ /O[A-Z]|O[1-9]/)|| ($3 == "O")) m=15.999; else if (($3 ~ /H[A-Z]|[1-9]H|H[1-9]/) || ($3 == "H"))  m=1.008 ; else if (($3 ~ /P[A-Z]|P[1-9]/) || ($3 == "P"))  m=30.974 ; else if (($3 ~ /S[A-Z]|S[ ]|S[1-9]/) || ($3 == "S"))  m=32.065 ; else m=0; print m}'` 
        if [ $m == 0 ] ; then
            echo "Warning: It seems like the PDBs have atoms other than C, H, O, N, P, or S !!" 
        fi
        if [ -z $chainid ]; then
            x1=`echo $line | awk '{print $6}'`
            y1=`echo $line | awk '{print $7}'`
            z1=`echo $line | awk '{print $8}'`
        else
            x1=`echo $line | awk '{print $7}'`
            y1=`echo $line | awk '{print $8}'`
            z1=`echo $line | awk '{print $9}'`
        fi
        x=`echo "$m*$x1" | bc -l`
        y=`echo "$m*$y1" | bc -l`
        z=`echo "$m*$z1" | bc -l`
        
        X[$i]=0
        X[$i]=$(echo "${X[$i]}+$x" | bc -l)
        Y[$i]=0
        Y[$i]=$(echo "${Y[$i]}+$y" | bc -l)
        Z[$i]=0
        Z[$i]=$(echo "${Z[$i]}+$z" | bc -l)
        c[$i]=0
        c[$i]=$(echo "${c[$i]}+$m" | bc -l)
    done < $address/$filename/test-$i.pdb
done
tx=$(IFS=+; echo "${X[*]}" | bc -l)
ty=$(IFS=+; echo "${Y[*]}" | bc -l)
tz=$(IFS=+; echo "${Z[*]}" | bc -l)
tm=$(IFS=+; echo "${c[*]}" | bc -l)

comx=`echo "$tx/$tm" | bc -l`
comy=`echo "$ty/$tm" | bc -l`
comz=`echo "$tz/$tm" | bc -l`


echo "Average COM:" $comx $comy $comz >> $address/$filename/resultfinal.dat 
xu=`echo "$comx+5" | bc -l`
xl=`echo "$comx-5" | bc -l`
yu=`echo "$comy+5" | bc -l`
yl=`echo "$comy-5" | bc -l`
zu=`echo "$comz+3.5" | bc -l`
zl=`echo "$comz-3.5" | bc -l`
zpu=`echo "$zu+3.5" | bc -l`
zpl=`echo "$zl-3.5" | bc -l`
touch $address/$filename/block_1.dat $address/$filename/block_2.dat  $address/$filename/block_3.dat  $address/$filename/block_4.dat

while [ ${start1} -le ${end} ]; do
    grep -i "${molecule}" "${address}"/step_${start1}.pdb | awk -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zpu}" -v znn="${zu}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn ) print $2}'>> $address/$filename/block_1.dat
    grep -i "${molecule}" "${address}"/step_${start1}.pdb | awk -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zu}" -v znn="${comz}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn ) print $2}'>> $address/$filename/block_2.dat
    grep -i "${molecule}" "${address}"/step_${start1}.pdb | awk -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${comz}" -v znn="${zl}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn ) print $2}'>> $address/$filename/block_3.dat
    grep -i "${molecule}" "${address}"/step_${start1}.pdb | awk -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zl}" -v znn="${zpl}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn ) print $2}'>> $address/$filename/block_4.dat
    start1=$[${start1}+${skip}]
done

sort -u $address/$filename/block_1.dat > $address/$filename/block_nr_1.dat
sort -u $address/$filename/block_2.dat > $address/$filename/block_nr_2.dat
sort -u $address/$filename/block_3.dat > $address/$filename/block_nr_3.dat
sort -u $address/$filename/block_4.dat > $address/$filename/block_nr_4.dat

name=( $(awk '{print $1}' ./$address/$filename/block_nr_1.dat) )
x=`echo ${#name[@]}`

score=1
touch $address/$filename/permeate.dat
for ((k=0; k<=$x; k=$[${k}+1])); do
    for (( i=2; i<=4; i=$[${i}+1] )); do
        if grep -Fxq "${name[${k}]}" $address/$filename/block_nr_${i}.dat
        then
            score=$[${score}+1]
            echo ${name[${k}]}   ${score} >> $address/$filename/permeate.dat
        else
            break
        fi
    done
    score=1
done
echo "This file contains the atom number(s) of $molecule that diffuse through the user-defined amino acid entry/exit points ($amino)" > $address/$filename/Diffusion.dat
grep -i " 4" $address/$filename/permeate.dat >> $address/$filename/Diffusion.dat

name=( $(awk '{print $1}' $address/$filename/Diffusion.dat) )
x=`echo ${#name[@]}`

# To identify whether the molecule is entering from extracellular to intracellular or vise-versa
for ((k=0; k<${x}; k++)); do
    f=${name[${k}]}
    while [ ${start10} -le ${end} ]; do
        touch $address/$filename/${name[${k}]}_1.dat  $address/$filename/${name[${k}]}_2.dat
        grep -i "${molecule}" "${address}"/step_${start10}.pdb | awk -v s="${name[${k}]}" -v t="${start10}" -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zpu}" -v znn="${zu}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn && $2==s ) print t}'>> $address/$filename/${name[${k}]}_1.dat
        grep -i "${molecule}" "${address}"/step_${start10}.pdb | awk -v s="${name[${k}]}" -v t="${start10}" -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zl}" -v znn="${zpl}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn && $2==s ) print t}'>> $address/$filename/${name[${k}]}_2.dat
        start10=$[${start10}+${skip}]
    done
    start10=${start11}
done

echo "This file contains the atom number(s) of $molecule that diffuse through the user-defined amino acid entry/exit points ($amino) in direction 1"> $address/$filename/Diffusion_direction1.dat
echo "This file contains the atom number(s) of $molecule that diffuse through the user-defined amino acid entry/exit points ($amino) in direction 2"> $address/$filename/Diffusion_direction2.dat

for ((a=1; a<${x}; a++)); do
    w1=`cat $address/$filename/${name[${a}]}_1.dat | tail -1` 2> /dev/null
    b1=`cat $address/$filename/${name[${a}]}_2.dat | tail -1` 2> /dev/null
    echo ${name[${a}]}          $restime >> $address/$filename/${filename}_residence_time.dat
    if [ ${w1} -gt ${b1} ]; then
        echo ${name[${a}]} >> $address/$filename/Diffusion_direction1.dat
    else
        echo ${name[${a}]} >> $address/$filename/Diffusion_direction2.dat
    fi
    rm ${name[${a}]}.dat 2> /dev/null
done

rm $address/$filename/result*.dat  $address/$filename/block*.dat $address/$filename/permeate.dat $address/$filename/${filename}_residence_time.dat $address/$filename/This_* $address/$filename/*_1.dat $address/$filename/*_2.dat $address/$filename/Diffusion.dat 2> /dev/null
rm $address/$filename/test*.pdb
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
    $MDTAPpath/Diffusion.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi
