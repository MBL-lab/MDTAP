#!/bin/bash
echo "===================================================================================="
echo "            Molecular Dynamics Trajectory Analysis of Permeation (MDTAP)"
echo "===================================================================================="
echo "Modules: 
A. Rename PDBs
B. Analyze Permeation 
C. Quit"
echo -n "Enter an option (A, B, or C) and press [ENTER]: "
    read module
if [[ $module == A ]] || [[ $module == a ]]; then
    $MDTAPpath/RenamePDBs.sh
elif [[ $module == B ]] || [[ $module == b ]]; then
    echo "Submodules under analyze permeation:
1. Z-density profile
2. XY-area profile
3. Rate of change of molecules
4. Permeation
5. Net flux and Permeability coefficient (Pd)
6. Ion conductance
7. Residence time
8. Track molecule
9. Diffusion entry/exit"
    echo -n "Enter an option (1, 2, or .... 9) and press [ENTER]: "
        read submodule
    
    if [ $submodule -eq 1 ]; then
        $MDTAPpath/Z-densityprofile.sh
    elif [ $submodule -eq 2 ]; then
        $MDTAPpath/XY-areaprofile.sh
    elif [ $submodule -eq 3 ]; then
        $MDTAPpath/Rateofchangeofmolecules.sh
    elif [ $submodule -eq 4 ]; then
        $MDTAPpath/Permeation.sh
    elif [ $submodule -eq 5 ]; then
        $MDTAPpath/Netflux.sh
    elif [ $submodule -eq 6 ]; then
        $MDTAPpath/Ionconductance.sh
    elif [ $submodule -eq 7 ]; then
        $MDTAPpath/Residencetime.sh
    elif [ $submodule -eq 8 ]; then
        $MDTAPpath/Track.sh
    elif [ $submodule -eq 9 ]; then
        $MDTAPpath/Diffusion.sh
    fi
elif [[ $module == C ]] || [[ $module == c ]]; then
    exit;
else
    echo "Invalid option entered!"
    $MDTAPpath/mdtap.sh
fi
