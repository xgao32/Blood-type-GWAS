import hail as hl
import pandas as pd
import sys


def update_fam_phenotype(fam_file, phenotype_file, output_fam_file):
    # Read the .fam file
    fam_data = pd.read_csv(fam_file, delim_whitespace=True, header=None)

    # Read the phenotype file, assuming it has 'FID', 'IID', and 'Phenotype' columns
    phenotype_data = pd.read_csv(phenotype_file, delim_whitespace=True, header=None, names=['FID', 'IID', 'Phenotype'])

    # Merge the two datasets on 'FID' and 'IID' to align the phenotypes with the fam file entries
    merged_data = pd.merge(fam_data, phenotype_data, left_on=[0, 1], right_on=['FID', 'IID'], how='left')

    # If no phenotype is found, keep the existing one in the fam file
    merged_data['Phenotype'] = merged_data['Phenotype'].fillna(merged_data[5])

    # Update the phenotype column (column index 5 in the fam file)
    fam_data[5] = merged_data['Phenotype']

    # Write the updated fam file
    fam_data.to_csv(output_fam_file, sep=' ', header=False, index=False)

if __name__ == "__main__":
    fam_file = sys.argv[1]
    phenotype_file = sys.argv[2]
    output_fam_file = sys.argv[3]
    update_fam_phenotype(fam_file, phenotype_file, output_fam_file)
