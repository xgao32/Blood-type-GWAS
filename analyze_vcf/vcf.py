import os
import gzip
import urllib.request
from io import BytesIO


def process_vcf(url, output_dir,n, tsv_data):
    """
    Parses a multi-individual genome file into individual vcf files, saved in output_dir
    :param url: multi-individual genome file
    :param output_dir: output_dir
    :param n: if individual vcf already exist(we want to add information), n = 0. else n could be any number except 0.
    :param tsv_data: tsv_data of multi-individual genome file
    :return:
    """
    print("starting access "+ url)
    try:
        if url.endswith('.gz'):
            with urllib.request.urlopen(url) as response:
                compressed_file = BytesIO(response.read())
                compressed_file.seek(0)
                with gzip.open(compressed_file, 'rt') as f:
                    file_content = f.read()
        else:
            with urllib.request.urlopen(url) as response:
                file_content = response.read().decode('utf-8')
    except Exception as e:
        print(f"Error accessing URL {url}: {e}")
        return
    print("finish get url: " + url)
    lines = file_content.splitlines()
    header = []
    sample_ids = []
    for line in lines:
        if line.startswith('##'):
            header.append(line)
        elif line.startswith('#CHROM'):
            header.append(line)
            sample_ids = line.strip().split('\t')[9:]
            break

    sample_vcfs = {sample_id: [] for sample_id in sample_ids}

    for line in lines:
        if not line.startswith('#'):
            fields = line.strip().split('\t')
            for i, sample_id in enumerate(sample_ids):
                genotype = fields[9 + i]
                if genotype.startswith('1|0') or genotype.startswith('1|1'):
                    sample_vcfs[sample_id].append(fields[:9] + [genotype])
    print("process data: " + url)
    os.makedirs(output_dir, exist_ok=True)

    for sample_id, entries in sample_vcfs.items():
        sample_file_path = os.path.join(output_dir, f"{sample_id}.vcf")
        with open(sample_file_path, 'a') as f:
            if(n==1):
                sample_info = tsv_data[tsv_data['Sample name'] == sample_id]
                if not sample_info.empty:
                    sample_info_str = sample_info.to_string(index=False, header=False).strip().replace('\n', '')
                    sample_info_header = f"##Sample={sample_info_str}\n"
                else:
                    sample_info_header = f"##Sample={sample_id},Information not found in TSV\n"
                f.write(sample_info_header)
            for line in header:
                if(n!=1): break
                f.write(line + '\n')
            for entry in entries:
                f.write('\t'.join(entry) + '\n')
        print(f"File saved for sample {sample_id} at {sample_file_path}" + " for " + url)

