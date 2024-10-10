# MDTAP: Molecular Dynamics Trajectory Analysis of Permeation

MDTAP is an MD analysis software that captures and quantifies permeation events across proteins and nucleic acid channels. It allows the user to define a molecule of interest and track its permeation across the channel using the PDB structures or CHARMM and NAMD DCD files generated from MD trajectories. Using the MD trajectories, a methodology is developed here to detect the permeation events across the channel irrespective of their shape, size, and the type of solute molecules permeating. This tool is beneficial in analyzing and calculating the solute/solvent permeations in an automated fashion.


### Prerequisites:
1) Linux/Mac-based system
2) Gnuplot
3) Fortran


### Getting started:
Download and unpack the MDTAP scripts to any folder. <br> ``unzip MDTAP-main.zip`` OR ``gzip MDTAP-main.zip`` <br>

To run MDTAP from any folder, follow the instructions given below:
- Go to the MDTAP scripts folder after unpacking/unzipping <br> ``cd MDTAP-main/MDTAP-scripts/``
- Change the permission of all the scripts in the MDTAP folder <br> ``chmod 777 *.sh``
- Open the ~/.bashrc file to export the path to the scripts and create an alias by pasting the following lines <br> ``export MDTAPpath=/path/to/folder/MDTAP-main/MDTAP-scripts`` <br> ``alias mdtap='/path/to/folder/MDTAP-main/MDTAP-scripts/mdtap.sh'``
- Save the bashrc file and run it by executing the following command <br> ``source ~/.bashrc``

<br>After installing MDTAP, it can be run using the following command to call MDTAP and follow the on-screen instructions to analyze the MD trajectories.<br>

``mdtap``
