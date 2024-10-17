#!/bin/bash
echo ""
echo "===================================================================================="
echo "  A. Rename DCDs"
echo " ----------------------------------------------------------------------------------"
echo "This module renames the DCD files to step_i.dcd (1<=i<=n), which is compatible with other modules. It renames the DCD files present in the path (address) defined by the user. Note that the original files are renamed directly." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo "Enter the address/path of the DCDs and press [ENTER] (Note: if the DCD files are present in the working directory, type '.' and press [ENTER]): "
    read addres

wd=`pwd`
homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
ls -ltr $address | awk '{ print $9 }' | grep -i "\.dcd" > dcd_name.txt
sort -V dcd_name.txt > dcd_name1.txt
chmod 755 *
step=1
while  read  line; do
    a=`echo $line`
    mv $address/$a $address/"step_"$step.dcd
    step=$[$step+1]
done < dcd_name1.txt
rm dcd_name.txt dcd_name1.txt

echo "The renamed files are stored in "$address
echo "1. Continue    2. Back    3. Quit"
echo -n "Enter an option (1, 2, or 3) and press [ENTER]: "
    read option
cd $wd
if [ $option -eq 1 ]; then
    $MDTAPpath/RenameDCDs.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi