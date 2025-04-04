import numpy as np

# Function to read PDB file and extract atom information
def read(filename):
    atoms = []
    with open(filename, 'r') as f:
        for line in f:
            parts = line.split()
            atnum = int(parts[0])
            atname = parts[1]
            resname = parts[2]
            resnum = int(parts[3])
            x, y, z = map(float, parts[4:7])
            atoms.append((atnum, atname, resname, resnum, x, y, z))
    return np.array(atoms, dtype=object)

# Load data from PDB files
mol_data = read("molecule.dat")
channel_data = read("channel.dat")

# Extract coordinates for fast computation
mol_coords = np.array(mol_data[:, 4:], dtype=float)
channel_coords = np.array(channel_data[:, 4:], dtype=float)

# Compute pairwise distances efficiently
mol_expanded = mol_coords[:, np.newaxis, :]
channel_expanded = channel_coords[np.newaxis, :, :]
distances = np.linalg.norm(mol_expanded - channel_expanded, axis=2)

# Find atom pairs with distance <= 3.5
close_pairs = np.where(distances <= 3.5)

# Write output to file
output_filename = "Distance.dat"
with open(output_filename, "a") as f:   
    for i, j in zip(*close_pairs):
        distance = distances[i, j]
        mol_atnum, mol_atname, mol_resname, mol_resnum, mol_x, mol_y, mol_z = mol_data[i]
        channel_atnum, channel_atname, channel_resname, channel_resnum, channel_x, channel_y, channel_z = channel_data[j]
        f.write(f"{distance:.3f}, {mol_atname}, {mol_atnum}, {mol_resname}, {mol_resnum}, {channel_atname}, {channel_atnum}, {channel_resname}, {channel_resnum}\n")
