# MDTAP: Molecular Dynamics Trajectory Analysis of Permeation

MDTAP is an MD analysis software that captures and quantifies permeation events across proteins and nucleic acid channels. It allows the user to define a molecule of interest and track its permeation across the channel using the PDB structures generated from MD trajectories. Using the MD trajectories, a methodology is developed here to detect the permeation events across the channel irrespective of their shape, size, and the type of solute molecules permeating. This tool is beneficial in analyzing and calculating the solute/solvent permeations in an automated fashion.


### Prerequisites:
1) Linux/Mac-based system
2) Gnuplot


### Getting started:
Download and unpack the MDTAP scripts to any folder in your system. <br> ``unzip MDTAP-main.zip`` <br>

To run MDTAP from any folder, follow the instructions given below:
- Go to the MDTAP folder after unpacking/unzipping <br> ``cd MDTAP``
- Change the permission of all the scripts in the MDTAP folder <br> ``chmod 777 *.sh``
- Open the ~/.bashrc file to export the path to the scripts and to create an alias by pasting the following lines <br> ``export MDTAPpath=/path/to/folder/MDTAP`` <br> ``alias mdtap='/path/to/folder/MDTAP/mdtap.sh'``
- Save the bashrc file and run it by executing the following command <br> ``source ~/.bashrc``

<br>After you install MDTAP in your system, you can just run the following command to call MDTAP and follow the on-screen instructions to analyze your MD trajectories.<br>

``mdtap``
