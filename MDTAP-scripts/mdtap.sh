#!/bin/bash
echo "===================================================================================="
echo "            Molecular Dynamics Trajectory Analysis of Permeation (MDTAP)"
echo "===================================================================================="
echo "Format of MD trajectories:
    1. PDB
    2. CHARMM/NAMD DCD"
echo -n "Enter an option (1 or 2) and press [ENTER]: "
    read filetype
if [[ $filetype == 1 ]]; then
    echo ""
    echo "Modules: 
    A. Rename PDBs
    B. Analyze Permeation 
    C. Quit"
    echo -n "Enter an option (A, B, or C) and press [ENTER]: "
        read module
    if [[ $module == A || $module == a || $module == 1 ]]; then
        $MDTAPpath/RenamePDBs.sh
    elif [[ $module == B || $module == b || $module == 2 ]]; then
        echo ""
        echo "Submodules under analyze permeation:
    1. Z-density profile
    2. XY-area profile
    3. Rate of change of molecules
    4. Permeation
    5. Net flux and Permeability coefficient (Pd)
    6. Residence time
    7. Track molecule
    8. Diffusion entry/exit
    9. Distance calculation"
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
            $MDTAPpath/Residencetime.sh
        elif [ $submodule -eq 7 ]; then
            $MDTAPpath/Track.sh
        elif [ $submodule -eq 8 ]; then
            $MDTAPpath/Diffusion.sh
        elif [ $submodule -eq 9 ]; then
            $MDTAPpath/Distance.sh
        else
            echo "Invalid option entered!"
            exit;
        fi
    elif [[ $module == C || $module == c || $module == 3 ]]; then
        exit;
    else
        echo "Invalid option entered!"
        exit;
    fi
elif [[ $filetype == 2 ]]; then
    echo ""
    echo "Modules: 
    A. Rename DCDs
    B. Analyze Permeation 
    C. Quit"
    echo -n "Enter an option (A, B, or C) and press [ENTER]: "
        read module
    if [[ $module == A || $module == a || $module == 1 ]]; then
        $MDTAPpath/RenameDCDs.sh
    elif [[ $module == B || $module == b || $module == 2 ]]; then
        echo ""
        echo "Submodules under analyze permeation:
    1. Z-density profile
    2. XY-area profile
    3. Rate of change of molecules
    4. Permeation
    5. Net flux and Permeability coefficient (Pd)
    6. Residence time
    7. Track molecule
    8. Diffusion entry/exit
    9. Distance calculation"
        echo -n "Enter an option (1, 2, or .... 9) and press [ENTER]: "
            read submodule
        if [ $submodule -eq 1 ]; then
            $MDTAPpath/Z-densityprofile-DCD.sh
        elif [ $submodule -eq 2 ]; then
            $MDTAPpath/XY-areaprofile-DCD.sh
        elif [ $submodule -eq 3 ]; then
            $MDTAPpath/Rateofchangeofmolecules-DCD.sh
        elif [ $submodule -eq 4 ]; then
            $MDTAPpath/Permeation-DCD.sh
        elif [ $submodule -eq 5 ]; then
            $MDTAPpath/Netflux.sh
        elif [ $submodule -eq 6 ]; then
            $MDTAPpath/Residencetime-DCD.sh
        elif [ $submodule -eq 7 ]; then
            $MDTAPpath/Track-DCD.sh
        elif [ $submodule -eq 8 ]; then
            $MDTAPpath/Diffusion-DCD.sh
        elif [ $submodule -eq 9 ]; then
            $MDTAPpath/Distance-DCD.sh
        else
            echo "Invalid option entered!"
            exit;
        fi
    elif [[ $module == C || $module == c || $module == 3 ]]; then
        exit;
    else
        echo "Invalid option entered!"
        exit;
    fi
else
    echo "Invalid option entered!"
    $MDTAPpath/mdtap.sh
fi
