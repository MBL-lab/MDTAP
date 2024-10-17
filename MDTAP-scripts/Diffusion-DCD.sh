#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 8. Diffusion entry/exit"
echo " ----------------------------------------------------------------------------------"
echo "This module calculates the number of solvent molecules that enter or exit through an entry point defined by three amino acid residues." | fold -sw 80 | sed "s/^/  /g"
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
echo  "Enter the name of the psf file (Note: the psf file should be stored in the folder where the dcds are present) and press [ENTER]: "
    read psfname
echo "Enter channel residues along with the residue numbers (e.g. GLN 102 TYR 380 PHE 427) and press [ENTER]: "
    read amino
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

echo -e "\nDiffusion calculation is going on. Please wait, as this could take a while.\n"

<<Sruthi
start=1           #starting frame
end=2000          #ending frame
skip=5           #frames to be skipped
stdcd=1           #starting of the dcd file
endcd=2           #ending of the dcd file
atname=OH2           #atom name of interest
atnum=            #atom number of interest
resname=          #residue name of interest
resid=            #residue number of interest
segid=proa        #segid of the channel of interest
psfname=dcd.psf   #psf file
filename=Diffusion
addres=dcd
time=1
#amino="ASP 30 GLY 120 GLY 472"
amino="GLN 102 TYR 380 PHE 427"
Sruthi

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

spin()
{
    t=1
    load="/-\|"
    while [ $t -eq 1 ]; do
        for (( s=0; s<${#load}; s++ )); do
            sleep 0.75
            echo -en "Calculating the number of $atname crossing the plane defined by the channel residues... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

echo $amino > $address/$filename/amino.dat

num=`cat $address/$filename/amino.dat | wc -w`

if (( $num == 0 || $num % 2 != 0 )); then
    echo "Please check the entered channel residues and their respective positions"
    kill -9 $spin_pid
    sleep 1
    exit
else
    for ((i=1; i<= $num/2 ; i=$[${i}+1])); do
        col1=$(((i * 2) - 1))
        col2=$((i * 2))
        aa[$i]=`cat $address/$filename/amino.dat | awk -v col="$col1" '{print $col}'`
        a[$i]=`cat $address/$filename/amino.dat | awk -v col="$col2" '{print $col}'`
    done
fi

#z=`awk "{print $1}" $address/$filename/amino.dat`	
#aa1=`echo $z | awk '{print $1}'`
#a1=`echo $z | awk '{print $2}'`
#aa2=`echo $z | awk '{print $3}'`
#a2=`echo $z | awk '{print $4}'`
#aa3=`echo $z | awk '{print $5}'`
#a3=`echo $z | awk '{print $6}'`
rm $address/$filename/amino.dat

start10=$start
start11=$start
start1=$start
#touch $address/$filename/result1.dat $address/$filename/result2.dat $address/$filename/result3.dat $address/$filename/resultfinal.dat

rm $location/coord_*.dat $location/step_1.pdb $location/atmlist.dat $address/temp.psf 2> /dev/null
sed -n '/NATOM/,$p' $address/$psfname > $address/temp.psf

for ((i=1; i<= $num/2 ; i=$[${i}+1])); do
    rm $location/coord_*.dat $location/step_1.pdb $location/atmlist.dat 2> /dev/null
    
#    echo "atnumber=$atnum senm=$segid renum=${a[$i]} atnm=$atname resnm=${aa[$i]}"
    awk -v atnumber="" -v senm=$segid -v renum=${a[$i]} -v atnm="" -v resnm=${aa[$i]} 'BEGIN { str1 = "^"; str2 = "$"; 
    if (length(atnumber) == 0) {atnumber1=atnumber;} else {atnumber1 = str1 atnumber str2;}
    if (length(senm)     == 0) {senm1=senm;        } else {senm1     = str1 senm str2;}
    if (length(renum)    == 0) {renum1=renum;      } else {renum1    = str1 renum str2;}
    if (length(atnm)     == 0) {atnm1=atnm;        } else {atnm1     = str1 atnm str2;}
    if (length(resnm)    == 0) {resnm1=resnm;      } else {resnm1    = str1 resnm str2;}}
    $5 ~ atnm1 && $4 ~ resnm1 && $3 ~ renum1 && $2 ~ senm1 && $1 ~ atnumber1 {print }' $address/temp.psf > $location/atmlist.dat
    touch ./input 
    echo $stdcd $endcd $start $end $skip $atname ${aa[$i]} ${a[$i]} \"temp.psf\" \"$location\" \"$address\" > ./input
    #generates the first frame in PDB format
    gfortran $MDTAPpath/dcd-psf.for
    ./a.out < input  
    rm ./a.out input
   
    #Added segid in next line
    cat "${address}"/"${filename}"/coord_*.dat  | grep -i " $segid" > $address/$filename/test-$i.pdb
    X=()
    Y=()
    Z=()
    c=()
    
    while read -r line; do
        m=`echo $line | awk '{if (($2 ~ /C[A-Z]|C[1-9]/) || ($2 == "C"))  m=12.011 ; else if (($2 ~ /N[A-Z]|N[1-9]/) || ($2 == "N")) m=14.006; else if (($2 ~ /O[A-Z]|O[1-9]/)|| ($2 == "O")) m=15.999; else if (($2 ~ /H[A-Z]|[1-9]H|H[1-9]/) || ($2 == "H"))  m=1.008 ; else if (($2 ~ /P[A-Z]|P[1-9]/) || ($2 == "P"))  m=30.974 ; else if (($2 ~ /S[A-Z]|S[ ]|S[1-9]/) || ($2 == "S"))  m=32.065 ; else m=0; print m}'` 
        if [ $m == 0 ] ; then
            echo "Warning: It seems like the trajectories have atoms other than C, H, O, N, P, or S !!" 
        fi
        x1=`echo $line | awk '{print $3}'`
        y1=`echo $line | awk '{print $4}'`
        z1=`echo $line | awk '{print $5}'`

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

echo "tx=$tx, ty=$ty, tz=$tz, tm=$tm"

comx=`echo "$tx/$tm" | bc -l`
comy=`echo "$ty/$tm" | bc -l`
comz=`echo "$tz/$tm" | bc -l`

echo "comx=$comx, comy=$comy, comz=$comz"

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

echo "xu=$xu, xl=$xl, yu=$yu, yl=$yl, zu=$zu, zl=$zl, zpu=$zpu, zpl=$zpl"

rm $location/coord_*.dat $location/step_1.pdb $location/atmlist.dat 2> /dev/null
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


while [ ${start1} -le ${end} ]; do
    awk -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zpu}" -v znn="${zu}" '{if ( $3<=xpp && $3>=xnn && $4<=ypp && $4>=ynn && $5<=zpp && $5>=znn ) print $1}' "${address}"/"${filename}"/coord_${start1}.dat >> $address/$filename/block_1.dat
    awk -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zu}" -v znn="${comz}" '{if ( $3<=xpp && $3>=xnn && $4<=ypp && $4>=ynn && $5<=zpp && $5>=znn ) print $1}' "${address}"/"${filename}"/coord_${start1}.dat >> $address/$filename/block_2.dat
    awk -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${comz}" -v znn="${zl}" '{if ( $3<=xpp && $3>=xnn && $4<=ypp && $4>=ynn && $5<=zpp && $5>=znn ) print $1}' "${address}"/"${filename}"/coord_${start1}.dat >> $address/$filename/block_3.dat
    awk -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zl}" -v znn="${zpl}" '{if ( $3<=xpp && $3>=xnn && $4<=ypp && $4>=ynn && $5<=zpp && $5>=znn ) print $1}' "${address}"/"${filename}"/coord_${start1}.dat >> $address/$filename/block_4.dat
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
echo "This file contains the atom number(s) of $atname that diffuse through the user-defined amino acid entry/exit points ($amino)" > $address/$filename/Diffusion.dat
grep -i " 4" $address/$filename/permeate.dat >> $address/$filename/Diffusion.dat

name=( $(awk '{print $1}' $address/$filename/Diffusion.dat) )
x=`echo ${#name[@]}`

# To identify whether the molecule is entering from extracellular to intracellular or vise-versa
for ((k=0; k<${x}; k++)); do
    f=${name[${k}]}
    while [ ${start10} -le ${end} ]; do
        touch $address/$filename/${name[${k}]}_1.dat  $address/$filename/${name[${k}]}_2.dat
        awk -v s="${name[${k}]}" -v t="${start10}" -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zpu}" -v znn="${zu}" '{if ( $3<=xpp && $3>=xnn && $4<=ypp && $4>=ynn && $5<=zpp && $5>=znn && $1==s ) print t}' "${address}"/"${filename}"/coord_${start10}.dat >> $address/$filename/${name[${k}]}_1.dat
        awk -v s="${name[${k}]}" -v t="${start10}" -v xpp="${xu}" -v xnn="${xl}" -v ypp="${yu}" -v ynn="${yl}" -v zpp="${zl}" -v znn="${zpl}" '{if ( $3<=xpp && $3>=xnn && $4<=ypp && $4>=ynn && $5<=zpp && $5>=znn && $1==s ) print t}' "${address}"/"${filename}"/coord_${start10}.dat >> $address/$filename/${name[${k}]}_2.dat
        start10=$[${start10}+${skip}]
    done
    start10=${start11}
done

echo "This file contains the atom number(s) of $atname that diffuse through the user-defined amino acid entry/exit points ($amino) in direction 1"> $address/$filename/Diffusion_direction1.dat
echo "This file contains the atom number(s) of $atname that diffuse through the user-defined amino acid entry/exit points ($amino) in direction 2"> $address/$filename/Diffusion_direction2.dat

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

rm $address/$filename/block*.dat $address/$filename/step*pdb $address/$filename/resultfinal.dat $address/$filename/permeate.dat $address/$filename/${filename}_residence_time.dat $address/$filename/This_* $address/$filename/*_1.dat $address/$filename/*_2.dat $address/$filename/Diffusion.dat 2> /dev/null
rm $address/$filename/test*.pdb
rm $address/$filename/coord*.dat 2> /dev/null
rm $address/$filename/atmlist.dat 2> /dev/null
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
    $MDTAPpath/Diffusion-DCD.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi