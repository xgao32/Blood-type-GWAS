import hail as hl
import pandas as pd


def convert_vcf_to_plink(local_vcf_path, output_prefix):
    """
    Converts a VCF file to PLINK format using Hail.

    :param local_vcf_path: Path to the local VCF file
    :param output_prefix: Prefix for the output PLINK files
    """
    hl.init()

    # Import VCF from the local file system
    mt = hl.import_vcf(local_vcf_path, reference_genome='GRCh37')
    mt = hl.variant_qc(mt)

    # Filter variants with call rate > 0.95
    mt = mt.filter_rows(mt.variant_qc.call_rate > 0.95)

    # Export to PLINK format
    hl.export_plink(mt, output_prefix)

    hl.stop()
    print(f"Plink files generated with prefix '{output_prefix}'")

