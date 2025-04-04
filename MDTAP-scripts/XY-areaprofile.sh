#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 2. XY-area profile"
echo " ----------------------------------------------------------------------------------"
echo "This module identifies the distribution of molecules in the user-defined space. The extremities in the X and Y directions are used to calculate the accessible area for the molecule of interest." | fold -sw 80 | sed "s/^/  /g"
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
awk -v cid="$chainid" '{ if ($5 ~ cid) print}' "${address}"/step_${start}.pdb | awk '{ if ((($4 ~ /ALA|GLY|LEU|VAL|ASN|ASP|ARG|TRP|SER|ILE|HSD|THR|PRO|GLN|GLU|LYS|TYR|PHE|MET|CYS|ADE|GUA|CYT|THY|URA|URI/) || ($4 == "DA")  || ($4 == "DG") || ($4 == "DC") || ($4 == "DT") || ($4 == "RA")  || ($4 == "RG") || ($4 == "RC") || ($4 == "RT") || ($4 == "RU") || ($4 == "A") || ($4 == "C") || ($4 == "D") || ($4 == "E") || ($4 == "F") || ($4 == "G") || ($4 == "H") || ($4 == "I") || ($4 == "K") || ($4 == "L") || ($4 == "M") || ($4 == "N") || ($4 == "P") || ($4 == "Q") || ($4 == "R") || ($4 == "S") || ($4 == "T") || ($4 == "U") || ($4 == "V") || ($4 == "W") || ($4 == "Y")) && ($1 == "ATOM") && ($3 != $4)) print }' | grep -i " $segid" > $address/$filename/step.pdb
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
   echo "There is a problem with the input PDBs! Ensure that the 4th column of the PDB files has either amino acid (e.g. ALA, GLY, LEU, ... OR A, G, L, ...) or nucleotide residues (e.g ADE, GUA, CYT, ... OR DA, DG, DC, ...).
Exiting ..."
   exit;
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
            echo -en "Calculating the XY-area profile of $molecule... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

start1=$start
start2=$start
echo "This file contains the area accessible by $molecule with respect to time. 
Column 1: Time (*${time}ps)     Column 2: Area (A^2)" > $address/$filename/XY-areaprofile.dat
touch $address/$filename/time.dat

while [ ${start} -le ${end} ]; do
    echo "Distribution of molecules between -Z < Z < +Z; Column 1: X-Coordinate; Column 2: Y-Coordinate " > $address/$filename/plot_${start}
    grep -i "${molecule}" "${address}"/step_${start}.pdb | awk -v xpp="${xp}" -v xnn="${xn}" -v ypp="${yp}" -v ynn="${yn}" -v zpp="${zp}" -v znn="${zn}" '{if ( $6<=xpp && $6>=xnn && $7<=ypp && $7>=ynn && $8<=zpp && $8>=znn ) print $6,$7,$8}' > $address/$filename/plot_${start}
    x=( $(awk '{print $1}' $address/$filename/plot_${start}) )
    y=( $(awk '{print $2}' $address/$filename/plot_${start}) )
    IFS=$'\n'
    a=`echo "${x[*]}" | sort -nr | head -n1`
    a1=`echo "${x[*]}" | sort -nr | tail -n1`
    xmax=`echo "$a-($a1)" | bc -l`
    IFS=$'\n'
    b=`echo "${y[*]}" | sort -nr | head -n1`
    b1=`echo "${y[*]}" | sort -nr | tail -n1`
    ymax=`echo "$b-($b1)" | bc -l`
    area1=`echo "($xmax)*($ymax)" | bc -l`
    area=`printf "%.3f\n" ${area1}` 
    echo  $start"   "$area >> $address/$filename/XY-areaprofile.dat
    echo $start >> $address/$filename/time.dat
    start=$[${start}+${skip}]
done

arr=( $(awk '{print $2}' ./$address/$filename/XY-areaprofile.dat) )
avg=`echo ${arr[@]} | awk ' {sum=0;for (i=1;i<=NF;i++) sum+=$i; print sum / NF; }'`
sd=`echo ${arr[@]} | awk -v M="${avg}" '{for(i=1;i<=NF;i++) {sum+=($i-M)*($i-M)}; print sqrt(sum/NF)}'`
echo "
The mean area accessible by $molecule is $avg A^2, and the standard deviation is $sd" >> $address/$filename/XY-areaprofile.dat

temp=`printf '%.f' $xp`
temp2=`echo $(($temp / 10))`
temp=`printf '%.f' $temp2`
Xr2=`echo $((($temp + 1 ) * 10))`
temp=`printf '%.f' $xn`
Xr1=`echo $(($temp - ($temp % 10)))`
temp=`printf '%.f' $yp`
temp2=`echo $(($temp / 10))`
temp=`printf '%.f' $temp2`
Yr2=`echo $((($temp + 1 ) * 10))`
temp=`printf '%.f' $yn`
Yr1=`echo $(($temp - ($temp % 10)))`
temp=`printf '%.f' $zp`
temp2=`echo $(($temp / 10))`
temp=`printf '%.f' $temp2`
Zr2=`echo $((($temp + 1 ) * 10))`
temp=`printf '%.f' $zn`
Zr1=`echo $(($temp - ($temp % 10)))`

wd=`pwd`
cd $address/$filename

cat plot_* > densityplot-XYZ.txt

for i in plot_*; do
    cat << __EOF | gnuplot 2> /dev/null
    set xrange [$Xr1:$Xr2]
    set yrange [$Yr1:$Yr2]
    set terminal png
    set border linewidth 2
    set output "XY-$i.png"
    set xlabel "X-Coordinate (Å)" rotate parallel offset 0,-1.0
    set ylabel "Y-Coordinate (Å)" rotate parallel offset 3.0, 0.75
    set multiplot layout 1,2 columns
    set origin -0.13, 0.0
    set size 0.6,1
    set view 0, 0, 1, 1
    set key off
    unset ztics
    unset colorbox
    set title "XY-projection of ${molecule}"
    splot '$i' using 1:2:3 with points palette pointsize 1 pointtype 7
    set key off
    set zrange [$Zr1:$Zr2]
    set ztics
    set xlabel "X-Coordinate (Å)" rotate parallel offset 0,-1.7
    set ylabel "Y-Coordinate (Å)" rotate parallel offset 1.0, -2.0
    set zlabel "Z-Coordinate (Å)" rotate parallel offset 2.5,0
    set view 75, 45, 1, 1
    set size 0.55,1
    set origin 0.44, 0.0
    set ztics
    set xtics center offset 0,-0.8
    set ytics center offset 1,-0.8
    set colorbox
    set title "Spatial distribution of ${molecule}"
    splot '$i' using 1:2:3 with points palette pointsize 1 pointtype 7
    unset multiplot
__EOF
done
cd $wd

#Rounding up the Zmax and rounding down the Zmin values
z1=$(awk -v num="$zp" 'BEGIN { rounded = int(num + 0.5); print (num > rounded) ? rounded + 1 : rounded }')
z2=$(awk -v num="$zn" 'BEGIN { rounded = int(num); print rounded }')
for ((a=$z1; a>=$z2; a--)); do
{
    z2new=`echo "$a-1" | bc -l | tr -d '\n\r'`
    awk -v zup="${a}" -v zdown="${z2new}" '{if ( $3<=zup && $3>zdown ) print $1,$2}' $address/$filename/densityplot-XYZ.txt > $address/$filename/Z-$a-$z2new
    num_data=`cat $address/$filename/Z-$a-$z2new | wc -l | tr -d '\n\r'`
    num_root=`echo "sqrt($num_data)" | bc -l | tr -d '\n\r'`
    bin=`printf "%.f" $num_root`
    # Number of bins in X and Y directions (these values can be adjusted)
    awk -v num_bins_x="$bin" -v num_bins_y="$bin" -v max_bins_x="100" -v max_bins_y="100" 'BEGIN {
        minX = maxX = minY = maxY = 0;
    }
    {
        x[NR] = $1;
        y[NR] = $2;
        if (NR == 1) {
        minX = maxX = $1;
        minY = maxY = $2;
        }
        else {
        minX = ($1 < minX) ? $1 : minX;
        maxX = ($1 > maxX) ? $1 : maxX;
        minY = ($2 < minY) ? $2 : minY;
        maxY = ($2 > maxY) ? $2 : maxY;
        }
    }
    END {
        # Calculate the range of the data
        range_x = maxX - minX;
        range_y = maxY - minY;

        # Adjust the number of bins based on data range and maximum bins
        num_bins_x = (num_bins_x > max_bins_x) ? max_bins_x : num_bins_x;
        num_bins_y = (num_bins_y > max_bins_y) ? max_bins_y : num_bins_y;

        # Ensure non-zero bin width
        bin_width_x = (range_x > 0) ? range_x / num_bins_x : 1;
        bin_width_y = (range_y > 0) ? range_y / num_bins_y : 1;

        for (i = 1; i <= NR; i++) {
        bin_x = int((x[i] - minX) / bin_width_x) + 1;
        bin_y = int((y[i] - minY) / bin_width_y) + 1;
        density[bin_x, bin_y]++;
        }

        for (i = 1; i <= NR; i++) {
        bin_x = int((x[i] - minX) / bin_width_x) + 1;
        bin_y = int((y[i] - minY) / bin_width_y) + 1;
        print x[i], y[i], density[bin_x, bin_y];
        }
    }' "$address/$filename/Z-$a-$z2new" > "$address/$filename/Z-$a-$z2new--density"
    rm $address/$filename/Z-$a-$z2new
}
done

#Finding the scale used to plot the plot the complete density plot, so that the same can be used for the other plots as well
scale=`awk '{print $3}' $address/$filename/Z-*--density | sort -n | head -1 | tr -d '\n\r'`
scale_max=`echo "$scale-1" | bc -l | tr -d '\n\r'`
scale=`awk '{print $3}' $address/$filename/Z-*--density | sort -n | tail -1 | tr -d '\n\r'`
scale_min=`echo "$scale+1" | bc -l | tr -d '\n\r'`

no=1
for ((a=$z1; a>=$z2; a--)); do
{
    z2new=`echo "$a-1" | bc -l | tr -d '\n\r'`
    cat << __EOF | gnuplot
    set terminal pngcairo size 800,600
    set border linewidth 3
    set output '$address/$filename/XY-density-Z-section_$no-$a-$z2new.png'
    set title 'Density of ${molecule} between $a-$z2new Å (Z-axis)' font "Helvetica-bold, 18"
    set xlabel 'X-Coordinate (Å)' font "Helvetica-bold, 16"
    set ylabel 'Y-Coordinate (Å)' font "Helvetica-bold, 16"
    set xrange [$Xr1:$Xr2]
    set yrange [$Yr1:$Yr2]
    set xtics font "Helvetica-bold, 14"
    set ytics font "Helvetica-bold, 14"
    set cbrange [$scale_max:$scale_min]
    set key off
    plot '$address/$filename/Z-$a-$z2new--density' using 1:2:3 with points palette pointsize 1 pointtype 7
    set colorbox
    replot
__EOF
    rm $address/$filename/Z-$a-$z2new--density
    no=$((no+1))
}
done

wd=`pwd`
cd $address/$filename
gif_sort=($(ls -v XY-density-Z-*.png))
convert -delay 100 -loop 0 "${gif_sort[@]}" XYZ-density.gif
cd $wd

rm $address/$filename/time.dat
rm *.dat 2> /dev/null
rm *.png 2> /dev/null
rm $address/$filename/plot* 2> /dev/null
rm $address/$filename/density*.txt 2> /dev/null
rm $address/$filename/data_with_density.txt 2> /dev/null

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
    $MDTAPpath/XY-areaprofile.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi