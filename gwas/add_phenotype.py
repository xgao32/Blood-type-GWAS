import hail as hl
import pandas as pd
import sys


def update_plink_phenotype(fam_file, phenotype_file, output_fam_file):
    # Read the .fam file
    fam_data = pd.read_csv(fam_file, delim_whitespace=True, header=None)
    fam_data.columns = ['FID', 'IID', 'PID', 'MID', 'Sex', 'Phenotype']

    # Read the phenotype file
    phenotype_data = pd.read_csv(phenotype_file, delim_whitespace=True, header=None)
    phenotype_data.columns = ['FID', 'IID', 'NewPhenotype']

    # Ensure the FID and IID columns are of the same type in both dataframes
    fam_data['FID'] = fam_data['FID'].astype(str)
    fam_data['IID'] = fam_data['IID'].astype(str)
    phenotype_data['FID'] = phenotype_data['FID'].astype(str)
    phenotype_data['IID'] = phenotype_data['IID'].astype(str)

    # Merge the dataframes on FID and IID
    updated_fam_data = fam_data.merge(phenotype_data[['FID', 'IID', 'NewPhenotype']], on=['FID', 'IID'], how='left')

    # Update the phenotype column
    updated_fam_data['Phenotype'] = updated_fam_data['NewPhenotype']
    updated_fam_data = updated_fam_data.drop(columns=['NewPhenotype'])

    # Write the updated .fam file
    updated_fam_data.to_csv(output_fam_file, sep=' ', header=False, index=False)
    print(f"Updated .fam file saved to {output_fam_file}")

if __name__ == "__main__":
    fam_file = sys.argv[1]
    phenotype_file = sys.argv[2]
    output_fam_file = sys.argv[3]
    update_plink_phenotype(fam_file, phenotype_file, output_fam_file)
