#!/bin/bash

# input PSAM file with FID and IID columns
PSAM_FILE="$1"

# add additional columns for each phenotype
# only code homozygotes, 1 for control, 2 for cases, -9 or 0 for no phenotype/hetereozygotes