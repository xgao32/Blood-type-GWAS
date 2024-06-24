import pandas as pd

from analyze_vcf.vcf import process_vcf

if __name__ == '__main__':
    tsv_file_path = "igsr-human genome structural variation consortium, phase 2.tsv.tsv"
    tsv_data = pd.read_csv(tsv_file_path, sep='\t')
    urls = [
        "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC2/release/v1.0/integrated_callset/freeze3.indel.alt.vcf.gz",
        "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC2/release/v1.0/integrated_callset/freeze3.snv.alt.vcf.gz",
        "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC2/release/v1.0/integrated_callset/freeze3.sv.alt.vcf.gz"
    ]
    n=1
    output_dir = "./output"
    for url in urls:
        process_vcf(url, output_dir,n, tsv_file_path)
        n+=1