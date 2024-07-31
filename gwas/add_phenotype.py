import hail as hl
import pandas as pd

def update_plink_phenotype(fam_file, phenotype_file, output_fam_file):
    fam_data = pd.read_csv(fam_file, delim_whitespace=True, header=None)
    fam_data.columns = ['FID', 'IID', 'PID', 'MID', 'Sex', 'Phenotype']

    phenotype_data = pd.read_csv(phenotype_file, delim_whitespace=True, header=None)
    phenotype_data.columns = ['FID', 'IID', 'NewPhenotype']

    updated_fam_data = fam_data.merge(phenotype_data[['FID', 'IID', 'NewPhenotype']], on=['FID', 'IID'], how='left')

    updated_fam_data['Phenotype'] = updated_fam_data['NewPhenotype']

    updated_fam_data = updated_fam_data.drop(columns=['NewPhenotype'])

    updated_fam_data.to_csv(output_fam_file, sep=' ', header=False, index=False)
    print(f"Updated .fam file saved to {output_fam_file}")


if __name__ == "__main__":
    fam_file = sys.argv[1]
    phenotype_file = sys.argv[2]
    output_fam_file = sys.argv[3]
    update_plink_phenotype(fam_file, phenotype_file, output_fam_file)