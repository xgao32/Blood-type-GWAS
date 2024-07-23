
import gzip
import urllib.request
from io import BytesIO

def print_vcf_header(url):
    """
    show the vcf header for url
    :param url:
    """
    try:
        if url.endswith('.gz'):
            with urllib.request.urlopen(url) as response:
                compressed_file = BytesIO(response.read())
                compressed_file.seek(0)
                with gzip.open(compressed_file, 'rt') as f:
                    for line in f:
                        if line.startswith('#'):
                            print(line.strip())
                        else:
                            break
        else:
            with urllib.request.urlopen(url) as response:
                for line in response:
                    line = line.decode('utf-8')
                    if line.startswith('#'):
                        print(line.strip())
                    else:
                        break
    except Exception as e:
        print(f"Error accessing URL {url}: {e}")


print_vcf_header("	ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot/20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr12.recalibrated_variants.vcf.gz")