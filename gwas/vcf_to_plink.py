import hail as hl
import pandas as pd


def convert_vcf_to_plink(vcf_url, output_prefix):

    hl.init()
    mt = hl.import_vcf(vcf_url, reference_genome='GRCh37')
    mt = hl.variant_qc(mt)

    # filter
    mt = mt.filter_rows(mt.variant_qc.call_rate > 0.95)

    hl.export_plink(mt, output_prefix)

    hl.stop()
    print(f"Plink files generated with prefix '{output_prefix}'")


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