import gwaslab as gl



def main():
    sumstats = gl.Sumstats("1kgeas.Phenotype.glm.logistic.hybrid", fmt="plink2")
    sumstats.get_lead(sig_level=5e-8)

    sumstats.basic_check()

    sumstats.plot_mqq(mode="r", anno=True, region=(9, 0, 1000000000), region_grid=True, build="19")




if __name__ == '__main__':
    main()
