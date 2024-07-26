from cyvcf2 import VCF


def get_variant_info(vcf_file, position):
    # 打开VCF文件
    vcf = VCF(vcf_file)

    # 查找特定位置的变异信息
    for record in vcf(f'1:{position}-{position}'):
        print(f"Chromosome: {record.CHROM}")
        print(f"Position: {record.POS}")
        print(f"ID: {record.ID}")
        print(f"Reference allele: {record.REF}")
        print(f"Alternate alleles: {record.ALT}")
        print(f"Quality: {record.QUAL}")
        print(f"Filter: {record.FILTER}")
        print(f"Info: {record.INFO}")


# 设置VCF文件路径和感兴趣的位点位置
vcf_file_path = "your_vcf_file.vcf.gz"
positions = [136132908, 136132909]

for pos in positions:
    get_variant_info(vcf_file_path, pos)
