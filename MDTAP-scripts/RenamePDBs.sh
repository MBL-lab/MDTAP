#!/bin/bash
echo ""
echo "===================================================================================="
echo "  A. Rename PDBs"
echo " ----------------------------------------------------------------------------------"
echo "This module renames the PDB files to step_i.pdb (1<=i<=n), which is compatible with other modules. It takes two inputs: the path (address) where all PDBs are stored and the output folder name where all the renamed PDBs will be stored. All the renamed PDBs will be stored in the path (address) defined by the user." | fold -sw 80 | sed "s/^/  /g"
echo "===================================================================================="
echo ""
echo "Enter the address/path of the PDBs and press [ENTER] (Note: if your PDB files are present in the working directory, just press [ENTER]): "
    read addres
echo "Enter the output path along with the folder name and press [ENTER]: "
    read output

wd=`pwd`
mkdir $output
homepath=`echo ~ | sed -e 's/\//\\\\\//g'`
address=`echo ${addres} | sed -e "s/\~/$homepath/g"`
ls -ltr $address | awk '{ print $9 }' | grep -i "\.pdb" > pdb_name.txt
sort -V pdb_name.txt > pdb_name1.txt
chmod 755 *
step=1
while  read  line; do
    a=`echo $line`
    cp $address/$a $output/"step_"$step.pdb
    step=$[$step+1]
done < pdb_name1.txt
rm  pdb_name.txt pdb_name1.txt

echo "The output files are stored in "$output
echo "1. Continue    2. Back    3. Quit"
echo -n "Enter your option (1, 2, or 3) and press [ENTER]: "
    read option
cd $wd
if [ $option -eq 1 ]; then
    $MDTAPpath/RenamePDBs.sh
elif [ $option -eq 2 ]; then
    $MDTAPpath/mdtap.sh
elif [ $option -eq 3 ]; then
    exit;
else
    echo "Invalid option entered!"
    exit;
fi