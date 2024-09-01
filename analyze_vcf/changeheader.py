import os

def modify_vcf_header(vcf_path):
    with open(vcf_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    with open(vcf_path, 'w', encoding='utf-8') as file:
        for line in lines:
            if line.startswith('#CHROM'):
                parts = line.strip().split('\t')
                new_header = parts[:9] + ['genotype']
                file.write('\t'.join(new_header) + '\n')
            else:
                file.write(line)

def process_vcf_files_in_directory(directory):
    for filename in os.listdir(directory):
        if filename.endswith('.vcf'):
            vcf_path = os.path.join(directory, filename)
            modify_vcf_header(vcf_path)
            print(f"Processed {vcf_path}")

if __name__ == "__main__":
    directory = 'output'
    process_vcf_files_in_directory(directory)
