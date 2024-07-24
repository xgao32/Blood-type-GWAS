import hail as hl
import pandas as pd


def create_phenotype_file(vcf_file, chrom, pos, ref, alt, output_file):
    hl.init()

    # read vcf
    mt = hl.import_vcf(vcf_file, reference_genome='GRCh37')

    # set variant
    variant = mt.filter_rows(
        (mt.locus.contig == chrom) &
        (mt.locus.position == pos) &
        (mt.alleles[0] == ref) &
        (mt.alleles[1] == alt)
    )

    # find variant
    if variant.count_rows() == 0:
        print("Variant not found in the VCF file.")
        return

    geno = variant.GT.collect()
    sample_ids = variant.s.collect()

    # 0|0: 2 (variant), 0|1, 1|0, 1|1: 1 (control)
    phenotype = [2 if gt.is_hom_ref() else 1 for gt in geno]

    # create data frame
    pheno_data = pd.DataFrame({
        'FID': sample_ids,
        'IID': sample_ids,
        'PHENO': phenotype
    })

    pheno_data.to_csv(output_file, sep='\t', index=False, header=False)
    print(f"Phenotype file saved to {output_file}")
    hl.stop()