#!/bin/bash

# plink2 website phase 3 1KG GRCh37 data with singleton variants filtered out
wget https://www.dropbox.com/s/dps1kvlq338ukz8/all_phase3_ns.pgen.zst?dl=1
wget https://www.dropbox.com/s/brkchmursq4vqwr/all_phase3_ns.pvar.zst?dl=1
wget https://www.dropbox.com/scl/fi/haqvrumpuzfutklstazwk/phase3_corrected.psam?rlkey=0yyifzj2fb863ddbmsv4jkeq6&dl=1

# manually rename and unzip files after download