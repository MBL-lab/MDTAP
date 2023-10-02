Molecular Dynamics Trajectory Analysis of Permeation (MDTAP)
Welcome to MDTAP!
This is a software that ........ (Write some brief intro in 2 lines later)

Prerequisites
1) Linux/Mac-based system
2) gnuplot

Getting started
Write how to export the path and alias
export MDTAPpath=/home/trlab8/sruthi/sruthi-mdtapscripts/

Download and unpack the MDTAP scripts to any folder in your system. To run MDTAP from any folder, follow the instructions given below:
- Go to the MDTAP folder after unpacking/unzipping
cd MDTAP
- Change the permission of all the scripts in the MDTAP folder
chmod 777 *.sh
- Open the bashrc file to export the path for the scripts and to create an alias
vi  ~/.bashrc
- Paste the following lines in bashrc
export MDTAPpath=/path/to/folder/MDTAP/
alias mdtap='/path/to/folder/MDTAP/mdtap.sh'
- Save the bashrc file and run it by executing the following command
source ~/.bashrc

After installing MDTAP in your system, run the following command to call MDTAP and follow the on-screen instructions for the analysis of your MD trajectories.
mdtap

Analysis modules
Write one line about each submodule
