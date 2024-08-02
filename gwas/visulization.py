import gwaslab as gl
import sys


def main(inputadd, outputadd):
    sumstats = gl.Sumstats(inputadd, fmt="plink2")
    sumstats.get_lead(sig_level=5e-8)

    chrom_9_data = sumstats.data[sumstats.data['CHR'] == '9']

    plot = gl.manhattan(chrom_9_data, p='P', chrom='CHR', pos='POS', highlight=True)

    plot.figure.savefig(outputadd)



if __name__ == '__main__':

    main(sys.argv[1], sys.argv[2])
