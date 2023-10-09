# MDTAP: Molecular Dynamics Trajectory Analysis of Permeation

MDTAP is an MD analysis software that captures and quantifies permeation events across proteins embedded in a membrane. It allows the user to define a molecule of interest and track its permeation across a membrane protein using the PDB structures generated from MD trajectories. A unique scoring method is developed here to detect the permeation events across protein channels irrespective of their shape and size and the type of solute molecules using the MD trajectories. This tool is beneficial in analyzing and calculating the solute/solvent permeations in an automated fashion.


### Prerequisites:
1) Linux/Mac-based system
2) gnuplot


### Getting started:
Download and unpack the MDTAP scripts to any folder in your system. To run MDTAP from any folder, follow the instructions given below:
- Go to the MDTAP folder after unpacking/unzipping <br> ``cd MDTAP``
- Change the permission of all the scripts in the MDTAP folder <br> ``chmod 777 *.sh``
- Open the bashrc file to export the path for the scripts and to create an alias <br> ``vi  ~/.bashrc``   OR   ``emacs ~/.bashrc``
- Paste the following lines in bashrc <br> ``export MDTAPpath=/path/to/folder/MDTAP`` <br> ``alias mdtap='/path/to/folder/MDTAP/mdtap.sh'``
- Save the bashrc file and run it by executing the following command <br> ``source ~/.bashrc``

After you install MDTAP in your system, you can just run the following command to call MDTAP and follow the on-screen instructions to analyze your MD trajectories.
``mdtap``
