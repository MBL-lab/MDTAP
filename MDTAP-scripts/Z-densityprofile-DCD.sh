#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 1. Z-density profile"
echo " ----------------------------------------------------------------------------------"
echo "This module calculates the number of molecules present along the protein axis (Z-axis). The user-defined space is divided into slices of 1 Å thickness, and the number of molecules in each slice is calculated." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo "Enter the molecule of interest (e.g. OH2 for water oxygens) and press [ENTER]: "
    read atname
echo "Enter the address/path of the dcds and press [ENTER] (Note: if the DCD files are present in the working directory, type '.' and press [ENTER]): "
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
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

echo -e "\nZ-density profile calculation is going on. Please wait, as this could take a while.\n"

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

rm $location/coord_*.dat $location/step_1.pdb $location/atmlist.dat 2> /dev/null

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

awk '{ if ((($4 ~ /ALA|GLY|LEU|VAL|ASN|ASP|ARG|TRP|SER|ILE|HIS|THR|PRO|GLN|GLU|LYS|TYR|PHE|MET|CYS|ADE|GUA|CYT|THY|URA|URI/) || ($4 == "DA")  || ($4 == "DG") || ($4 == "DC") || ($4 == "DT") || ($4 == "RA")  || ($4 == "RG") || ($4 == "RC") || ($4 == "RT") || ($4 == "RU") || ($4 == "A") || ($4 == "C") || ($4 == "D") || ($4 == "E") || ($4 == "F") || ($4 == "G") || ($4 == "H") || ($4 == "I") || ($4 == "K") || ($4 == "L") || ($4 == "M") || ($4 == "N") || ($4 == "P") || ($4 == "Q") || ($4 == "R") || ($4 == "S") || ($4 == "T") || ($4 == "U") || ($4 == "V") || ($4 == "W") || ($4 == "Y")) && ($1 == "ATOM") && ($3 != $4)) print }' "${address}"/"${filename}"/step_1.pdb | grep -i " $segid" > $address/$filename/step.pdb
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
    awk '{print $8}' $address/$filename/step_1.pdb | grep -Eo '[-]?[0-9]+(\.[0-9]+)?' > $address/$filename/z.txt
    z=( $(cat $address/$filename/z.txt) )
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
    awk '{print $9}' $address/$filename/step_1.pdb > $address/$filename/z.txt
    awk '{ if (!(($4 ~ /ALA|GLY|LEU|VAL|ASN|ASP|ARG|TRP|SER|ILE|HIS|THR|PRO|GLN|GLU|LYS|TYR|PHE|MET|CYS|ADE|GUA|CYT|THY|URA|URI/) || ($4 == "DA")  || ($4 == "DG") || ($4 == "DC") || ($4 == "DT") || ($4 == "RA")  || ($4 == "RG") || ($4 == "RC") || ($4 == "RT") || ($4 == "RU") || ($4 == "A") || ($4 == "C") || ($4 == "D") || ($4 == "E") || ($4 == "F") || ($4 == "G") || ($4 == "H") || ($4 == "I") || ($4 == "K") || ($4 == "L") || ($4 == "M") || ($4 == "N") || ($4 == "P") || ($4 == "Q") || ($4 == "R") || ($4 == "S") || ($4 == "T") || ($4 == "U") || ($4 == "V") || ($4 == "W") || ($4 == "Y"))) print $8 }' "${address}"/step_${start}.pdb | grep -Eo '[-]?[0-9]+(\.[0-9]+)?' >> $address/$filename/z.txt # The grep command fetches only numerical values including negative values and fractions
    z=( $(cat $address/$filename/z.txt) )
    IFS=$'\n'
    c=`echo "${z[*]}" | sort -nr | head -n1`
    c1=`echo "${z[*]}" | sort -nr | tail -n1`
fi

rm $address/$filename/step*.pdb $address/$filename/z.txt

if ( [ ${#x[@]} -eq 0 ] || [ ${#y[@]} -eq 0 ] || [ ${#z[@]} -eq 0 ] ); then
    echo "WARNING: The input the DCD and PSF files do not have amino acid (e.g. ALA, GLY, LEU, ... OR A, G, L, ...) or nucleotide residues (e.g ADE, GUA, CYT, ... OR DA, DG, DC, ...)."
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
            awk '{print $8}' $address/step_${start}.pdb | grep -Eo '[-]?[0-9]+(\.[0-9]+)?' > $address/$filename/z.txt
            z=( $(cat $address/$filename/z.txt) )
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
            awk '{print $9}' $address/step_${start}.pdb | grep -Eo '[-]?[0-9]+(\.[0-9]+)?' > $address/$filename/z.txt
            z=( $(cat $address/$filename/z.txt) )
            IFS=$'\n'
            c=`echo "${z[*]}" | sort -nr | head -n1`
            c1=`echo "${z[*]}" | sort -nr | tail -n1`
        fi
        rm $address/$filename/step.pdb $address/$filename/z.txt
    elif [[ "$choice" == "no" || "$choice" == "n" || "$choice" == "N" || "$choice" == "No" || "$choice" == "NO" ]]; then
        echo "Exiting ..."
        exit;
    else
        echo "Invalid input. Exiting ..."
        exit;
    fi
fi

echo "Recommended dimensions (Xmax Xmin Ymax Ymin Zmax Zmin) for the channel are:" $a $a1 $b $b1 $c $c1
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

spin()
{
    t=1
    load="/-\|"
    while [ $t -eq 1 ]; do
        for (( s=0; s<${#load}; s++ )); do
            sleep 0.75
            echo -en "Calculating the Z-density profile of $atname... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

zscale=$zp

p=`echo "$zp-($zn)"| bc -l`
p=`printf %.0f $p`

start1=${start}
start2=${start}
start3=${start}
start4=${start}
start5=${start} 
zx=${zp}
touch $address/$filename/time1.dat

while [ ${start} -le ${end} ]; do
    zp=${zx}
    touch $address/$filename/density_num${start}.dat
    for ((o=1; o<=$p; o++)); do
        znew=`echo "$zp-1" | bc -l`
        lo=`echo "${zp}-(${znew})" | bc -l`
        awk -v xpp="${xp}" -v xnn="${xn}" -v ypp="${yp}" -v ynn="${yn}" -v zpp="${zp}" -v znn="${znew}" -v lot="${lo}" '{if ( $3<=xpp && $3>=xnn && $4<=ypp && $4>=ynn && $5<=zpp && $5>=znn ) print  }' "${address}"/"${filename}"/coord_${start}.dat | wc -l >> $address/$filename/density_num${start}.dat
        zp=`echo "$zp-1" | bc -l`
    done
    echo ${start} >> $address/$filename/time1.dat
    start=$[${start}+${skip}]
done

touch $address/$filename/time.dat
zx2=`printf %.0f $zx`
zx3=`printf %.0f $zn`

while [ ${zx2} -gt ${zx3} ]; do
    zxx=`echo "$zx2-1" | bc -l`
    echo "$zx2-$zxx" >> $address/$filename/time.dat 
    zx2=$[${zx2}-1]
done

paste $address/$filename/density_num*.dat > $address/$filename/${filename}.dat
ex -s +'v/\S/d' -cwq $address/$filename/${filename}.dat

last=`wc -l < $address/$filename/time.dat`
la=`echo "$last-1" | bc -l` 
touch $address/$filename/meansd.dat
for ((k=1; k<${la}; k++)); do
    while  read -r line; do
    a=`echo $line` 
    echo $a >$address/$filename/val.dat
    awk '{OFS=RS;$1=$1}1' $address/$filename/val.dat > $address/$filename/val_$k.dat
    arr=( $(awk '{print $1}' ./$address/$filename/val_$k.dat) )
    avg1=`echo ${arr[@]} | awk ' {sum=0;for (i=1;i<=NF;i++) sum+=$i; print sum / NF;}'`
    avg=`printf "%.3f\n" ${avg1}`
    sd1=`echo ${arr[@]} | awk -v M="${avg}" '{for(i=1;i<=NF;i++) {sum+=($i-M)*($i-M)}; print sqrt(sum/NF)}'`
    sd=`printf "%.3f\n" ${sd1}`
    echo "$avg   $sd" >> $address/$filename/meansd.dat
    k=$[$k+1]
    done < $address/$filename/${filename}.dat
done

while [ ${start5} -le ${end} ]; do
    echo "This file contains the variation in the number of $atname within the channel along the Z-axis.
Column 1: Sections along Z-axis (Å)     Column 2: Number of $atname" > $address/$filename/Z-densityprofile-${start5}.dat
    paste $address/$filename/time.dat     $address/$filename/density_num${start5}.dat >> $address/$filename/Z-densityprofile-${start5}.dat
    rm $address/$filename/density_num${start5}.dat 2> /dev/null
    start5=$[${start5}+${skip}]
done

rm $address/$filename/density_num${start}.dat 2> /dev/null
echo "This file contains the variation in the number of ${atname} with respect to the channel along the Z-axis.
Column 1: Sections along Z-axis in (Å)
Column 2: Mean number of ${atname} in each section at every *${time}ps
Column 3: Standard deviation of the mean in each section at every *${time}ps" > $address/$filename/Z-densityprofile-mean_sd.dat
paste $address/$filename/time.dat $address/$filename/meansd.dat >> $address/$filename/Z-densityprofile-mean_sd.dat

temp=`printf '%.f' $zscale`
temp2=`echo $(($temp / 10))`
temp=`printf '%.f' $temp2`
Zr2=`echo $((($temp + 1 ) * 10))`
temp=`printf '%.f' $zn`
Zr1=`echo $(($temp - ($temp % 10)))`
n=`cat $address/$filename/Z-densityprofile-*.dat | awk '{print $2}' | grep -Eo '[-]?[0-9]+(\.[0-9]+)?' | sort -nr | head -n1 | tr -d '\n\r'`
temp=`printf '%.f' $n`
temp2=`echo $(($temp / 10))`
temp=`printf '%.f' $temp2`
n=`echo $((($temp + 1 ) * 10))`

wd=`pwd`
cd $address/$filename
for i in Z-densityprofile-*.dat; do
    j=`echo $i | sed 's/.dat//g' | tr -d '\n\r'`
    k=`echo $j | sed 's/Z-densityprofile-//g' | tr -d '\n\r'`
    cat << __EOF | gnuplot
    set terminal pngcairo size 800,600
    set border linewidth 3
    set xrange [0:$n]
    set yrange [$Zr1:$Zr2]
    set output '$j.png'
    set title 'Z-density profile - $k' font "Helvetica-bold, 18"
    set xlabel 'Number of ${atname} in every 1Å block' font "Helvetica-bold, 16"
    set ylabel 'Position along Z-Coordinate (Å)' font "Helvetica-bold, 16"
    set xtics font "Helvetica-bold, 14"
    set ytics font "Helvetica-bold, 14"
    set key off
    plot '$i' using 2:1 with linespoints pointsize 1 pointtype 7 lw 3 linecolor rgb "#EB548C"
__EOF
done
cd $wd

cat << __EOF | gnuplot
set terminal pngcairo size 800,600
set border linewidth 3
set xrange [0:$n]
set yrange [$Zr1:$Zr2]
set output '$address/$filename/Z-densityprofile-mean-plot.png'
set title 'Mean Z-density profile with standard deviation' font "Helvetica-bold, 18"
set xlabel 'Number of ${atname} in every 1Å block' font "Helvetica-bold, 16"
set ylabel 'Position along Z-Coordinate (Å)' font "Helvetica-bold, 16"
set xtics font "Helvetica-bold, 14"
set ytics font "Helvetica-bold, 14"
set key off
plot '$address/$filename/Z-densityprofile-mean_sd.dat' using 2:1:3 with xerrorbars lw 3 linecolor rgb "#7D3AC1"
__EOF

chmod 755 *
mv $address/$filename/Z-densityprofile-mean-plot.png $address/$filename/Z-densityprofile-mean_sd.png
rm $address/$filename/val.dat $address/$filename/meansd.dat $address/$filename/time.dat $address/$filename/time1.dat 2> /dev/null
rm $address/$filename/${filename}.dat 2> /dev/null
rm *.png 2> /dev/null
rm $address/$filename/val*.dat 2> /dev/null
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
    cd $wd
    $MDTAPpath/Z-densityprofile-DCD.sh
elif [ $option -eq 2 ]; then
    cd $wd
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi
