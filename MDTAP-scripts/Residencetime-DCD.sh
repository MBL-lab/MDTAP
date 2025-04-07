#!/bin/bash
echo ""
echo "===================================================================================="
echo "  B. 6. Residence time"
echo " ----------------------------------------------------------------------------------"
echo "This module takes atom numbers (as defined in the PSF files) in the form of a text file as an input and captures its initial and final DCD frames in the specific region and calculates time spent in that region." | fold -sw 80 | sed "s/^/  /g"
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
echo  "Enter the name of the input file having the atom IDs (Note: the input file should be stored in the folder where the DCDs are present) and press [ENTER]: "
    read inputfile
echo "Enter the output folder name and press [ENTER] (Note: if the folder already exists, it will be overwritten): "
    read filename

echo -e "\nResidence time calculation is going on. Please wait, as this could take a while.\n"

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
            echo -en "Calculating the residence time of the provided atom numbers in the channel... ${load:$s:1}" "\r"
        done
    done
}
spin &
spin_pid=`echo -n $!`

echo " " > $address/$filename/${filename}.dat
id=( $(awk '{print $1}' "${address}"/${inputfile}) )
xi=`echo ${#id[@]}`
start1=${start}

for ((k=0; k<$xi; k++)); do
    idchk=`grep ${id[${k}]} "${address}"/"${filename}"/coord_${start}.dat | wc -l`
    idchk1=`grep ${id[${k}]} "${address}"/"${filename}"/coord_${start}.dat`
    if [ $idchk -le 0 ] ; then
        echo "Atom number/id " ${id[${k}]} " not present - check trajectory"
        kill -9 $spin_pid
        sleep 1
        exit
    fi
    touch $address/$filename/${id[${k}]}.dat
    chmod 755 *
    f=${id[${k}]}
    while [ ${start1} -le ${end} ]; do
        awk -v s="${id[${k}]}" -v t="${start1}" -v xpp="${xp}" -v xnn="${xn}" -v ypp="${yp}" -v ynn="${yn}" -v zpp="${zp}" -v znn="${zn}"  '{if ( $3<=xpp && $3>=xnn && $4<=ypp && $4>=ynn && $5<=zpp && $5>=znn && $1==s) print t}' "${address}"/"${filename}"/coord_${start1}.dat >> $address/$filename/${id[${k}]}.dat
        start1=$[${start1}+${skip}]
    done
    start1=${start}
done

touch $address/$filename/${filename}_user.dat


for (( a=0; a<$xi; a++ )); do
  if [ -s $address/$filename/${id[${a}]}.dat ] ; then
    w=( $(awk '{print $1}' $address/$filename/${id[${a}]}.dat) )
    t=`echo "(${#w[@]}-1) * ${time} * ${skip}" | bc -l`
    printf "%i   %i \n" ${id[${a}]}   ${t}  >> $address/$filename/${filename}_user.dat
    rm $address/$filename/${id[${a}]}.dat
  else
    printf "%i   %i \n" ${id[${a}]}   0  >> $address/$filename/${filename}_user.dat
    rm $address/$filename/${id[${a}]}.dat
  fi
done

echo "This file contains the residence time of the provided atom numbers.
Column 1: Atom number     Column 2: Residence time (*${time}ps)" > $address/$filename/Residence_time.dat 
paste $address/$filename/${filename}_user.dat >> $address/$filename/Residence_time.dat 

rm $address/$filename/${filename}.dat $address/$filename/${filename}_user.dat 
rm *.png 2> /dev/null
rm *.dat 2> /dev/null
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
    $MDTAPpath/Residencetime-DCD.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi
