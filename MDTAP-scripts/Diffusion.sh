#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 9. Diffusion entry/exit"
echo " ----------------------------------------------------------------------------------"
echo "This module calculates the number of solvent molecules that enter or exit through an entry point defined by three amino acid residues." | fold -sw 80 | sed "s/^/  /g"
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
echo "Enter 3 amino acid residue numbers (e.g. GLN 102 TYR 380 PHE 427) and press [ENTER]: "
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
            echo -en "Calculating the number of $molecule crossing the plane defined by three amino acid residues... ${load:$s:1}" "\r"
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
z=`awk "{print $1}" $address/$filename/amino.dat`	
aa1=`echo $z | awk '{print $1}'`
a1=`echo $z | awk '{print $2}'`
aa2=`echo $z | awk '{print $3}'`
a2=`echo $z | awk '{print $4}'`
aa3=`echo $z | awk '{print $5}'`
a3=`echo $z | awk '{print $6}'`
rm $address/$filename/amino.dat

start10=$start
start11=$start
start1=$start
touch $address/$filename/result1.dat $address/$filename/result2.dat $address/$filename/result3.dat $address/$filename/resultfinal.dat

while [ $start -lt $end ]; do
    grep -i "${aa1}" "${address}"/step_$start.pdb | awk -v u="${a1}" '{if ( $5==u ) print}'  > $address/$filename/test1.pdb
    X=0
    Y=0
    Z=0
    c=0
    while read -r line; do
        a4=`echo $line | awk '{if (($3 ~ /C[A-Z]|C[1-9]/) || ($3 == "C"))  m=12.011 ; else if (($3 ~ /N[A-Z]|N[1-9]/) || ($3 == "N")) m=14.006; else if (($3 ~ /O[A-Z]|O[1-9]/)|| ($3 == "O")) m=15.999; else if (($3 ~ /H[A-Z]|[1-9]H|H[1-9]/) || ($3 == "H"))  m=1.008 ; else if (($3 ~ /P[A-Z]|P[1-9]/) || ($3 == "P"))  m=30.974 ; else if (($3 ~ /S[A-Z]|S[ ]|S[1-9]/) || ($3 == "S"))  m=32.065 ; else m=0; print m}'` 
        
        if [ $a4 == 0 ] ; then
            echo "Warning: It seems like your PDBs have atoms other than C, H, O, N, P, or S !!" 
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
        x=`echo "$a4*$x1" | bc -l`
        y=`echo "$a4*$y1" | bc -l`
        z=`echo "$a4*$z1" | bc -l`
        X=`echo "$X+$x" | bc -l`
        Y=`echo "$Y+$y" | bc -l`
        Z=`echo "$Z+$z" | bc -l`
        c=`echo "$c+$a4" | bc -l`
    done < $address/$filename/test1.pdb

    xm1a=`echo "$X/$c" | bc -l`
    ym1a=`echo "$Y/$c" | bc -l`
    zm1a=`echo "$Z/$c" | bc -l`
    echo "cof asn1a" $xm1a $ym1a $zm1a >> $address/$filename/result1.dat
    grep -i "${aa2}" "${address}"/step_$start.pdb| awk -v v="${a2}" '{if ( $5==v ) print}' > $address/$filename/test2.pdb
    X=0
    Y=0
    Z=0
    b=0
    while read -r line; do
        a4=`echo $line | awk '{if (($3 ~ /C[A-Z]|C[1-9]/) || ($3 == "C"))  m=12.01 ; else if (($3 ~ /N[A-Z]|N[1-9]/) || ($3 == "N")) m=14.006; else if (($3 ~ /O[A-Z]|O[1-9]/)|| ($3 == "O")) m=15.99; else if (($3 ~ /H[A-Z]|[1-9]H|H[1-9]/) || ($3 == "H"))  m=1.007 ; else if (($3 ~ /P[A-Z]|P[1-9]/) || ($3 == "P"))  m=30.974 ; else if (($3 ~ /S[A-Z]|S[ ]|S[1-9]/) || ($3 == "S"))  m=31.97 ; else m=0; print m}'` 
        if [ $a4 == 0 ] ; then
            echo "Warning: It seems like your PDBs have atoms other than C, H, O, N, P, or S !!" 
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
        x=`echo "$a4*$x1" | bc -l`
        y=`echo "$a4*$y1" | bc -l`
        z=`echo "$a4*$z1" | bc -l`
        X=`echo "$X+$x" | bc -l`
        Y=`echo "$Y+$y" | bc -l`
        Z=`echo "$Z+$z" | bc -l`
        b=`echo "$b+$a4" | bc -l`
    done < $address/$filename/test2.pdb

    xn1a=`echo "$X/$b"| bc -l`
    yn1a=`echo "$Y/$b"| bc -l`
    zn1a=`echo "$Z/$b"| bc -l`
    echo "cof arg1a" $xn1a $yn1a $zn1a >> $address/$filename/result2.dat
    grep -i "${aa3}" "${address}"/step_$start.pdb |awk -v w1="${a3}" '{if ( $5==w1 ) print}' > $address/$filename/test3.pdb
    X=0
    Y=0
    Z=0
    d=0
    while read -r line; do
        a4=`echo $line | awk '{if (($3 ~ /C[A-Z]|C[1-9]/) || ($3 == "C"))  m=12.01 ; else if (($3 ~ /N[A-Z]|N[1-9]/) || ($3 == "N")) m=14.006; else if (($3 ~ /O[A-Z]|O[1-9]/)|| ($3 == "O")) m=15.99; else if (($3 ~ /H[A-Z]|[1-9]H|H[1-9]/) || ($3 == "H"))  m=1.007 ; else if (($3 ~ /P[A-Z]|P[1-9]/) || ($3 == "P"))  m=30.974 ; else if (($3 ~ /S[A-Z]|S[ ]|S[1-9]/) || ($3 == "S"))  m=31.97 ; else m=0; print m}'` 
        if [ $a4 == 0 ] ; then
            echo "Warning: It seems like your PDBs have atoms other than C, H, O, N, P, or S !!" 
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
        x=`echo "$a4*$x1" | bc -l`
        y=`echo "$a4*$y1" | bc -l`
        z=`echo "$a4*$z1" | bc -l`
        X=`echo "$X+$x" | bc -l`
        Y=`echo "$Y+$y" | bc -l`
        Z=`echo "$Z+$z" | bc -l`
        d=`echo "$d+$a4"| bc -l`
    done <$address/$filename/test3.pdb

    xo1a=`echo "$X/$d" | bc -l`
    yo1a=`echo "$Y/$d" | bc -l`
    zo1a=`echo "$Z/$d" | bc -l`
    echo "cof pro1a" $xo1a $yo1a $zo1a >> $address/$filename/result3.dat

    tm1a=`bc  -l <<< "$c+$b+$d"`
    xm1=`echo "$c*$xm1a" | bc -l`
    xn1=`echo "$b*$xn1a" | bc -l`
    xo1=`echo "$d*$xo1a" | bc -l`

    ym1=`echo "$c*$ym1a" | bc -l`
    yn1=`echo "$b*$yn1a" | bc -l`
    yo1=`echo "$d*$yo1a" | bc -l`

    zm1=`echo "$c*$zm1a" | bc -l`
    zn1=`echo "$b*$zn1a" | bc -l`
    zo1=`echo "$d*$zo1a" | bc -l`

    tx=`bc -l <<< "$xo1+$xn1+$xm1"`
    ty=`bc -l <<< "$yo1+$yn1+$ym1"`
    tz=`bc -l <<< "$zo1+$zn1+$zm1"`
    cox1a=`echo "$tx/$tm1a" | bc -l`
    coy1a=`echo "$ty/$tm1a" | bc -l`
    coz1a=`echo "$tz/$tm1a" | bc -l`
    echo "cof 1a" $cox1a $coy1a $coz1a >> $address/$filename/resultfinal.dat
    start=$[${start}+${skip}]   
done

aa=`awk -F ' '  '{sumx += $3} END {print sumx}' $address/$filename/resultfinal.dat`
bb=`awk -F ' '  '{sumy += $4} END {print sumy}' $address/$filename/resultfinal.dat`
cc=`awk -F ' '  '{sumz += $5} END {print sumz}' $address/$filename/resultfinal.dat`
nr=`awk 'END{print NR}' $address/$filename/resultfinal.dat`

comx=`echo "$aa/$nr" | bc -l`
comy=`echo "$bb/$nr" | bc -l`
comz=`echo "$cc/$nr" | bc -l`

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

##### To identify whether the molecule is entering from extracellular to intar or vise-versa #####
for ((k=0; k<${x}; k++)); do
    f=${name[${k}]}
    while [ ${start10} -le ${end} ]; do
        touch $address/$filename/${name[${k}]}_1.dat  $address/$filename/${name[${k}]}_2.dat
        grep -i "${molecule}" "${address}"/step_${start10}.pdb | awk -v s="${name[${k}]}" -v t="${start10}" -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zpu}" -v znn="${zpl}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn && $2==s ) print t}'>> $address/$filename/${name[${k}]}_1.dat
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

##########

rm $address/$filename/result*.dat  $address/$filename/block*.dat $address/$filename/permeate.dat $address/$filename/${filename}_residence_time.dat $address/$filename/This_* $address/$filename/*_1.dat $address/$filename/*_2.dat $address/$filename/Diffusion.dat 2> /dev/null
rm $address/$filename/test*.pdb
kill -9 $spin_pid
sleep 1
above_line=$(tput cuu1)
erase_line=$(tput el)
echo "$above_line$erase_line"

echo "The output files are stored in " $filename "at" $address/$filename
echo -n "Enter your option (1, 2, or 3) and press [ENTER]: "
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