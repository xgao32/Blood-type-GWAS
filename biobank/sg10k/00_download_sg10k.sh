#!/bin/bash

# does not work, sg10k only allow point and click download directly from CHORUS website

# download sg10k data 9,770 genomes - 179,418,917 sites
# The NPM SG10K_Health aggregated variant dataset (SG10K_Health_r5.3) is available for download as bgzip-compressed VCF formatted files.
# Release-wide, as well as ancestry (Chinese, Indian, Malay) 
# and/or sex (Male, Female), aggregated Allele Frequencies (AF),
# Allele Counts (AC) and Allele Numbers (AN) information are embedded in the VCF’s INFO fields (Annex A). 
# The minor allele counts smaller than 5 are clipped to 5 (and cognate allele frequencies are calculated accordingly).
:'
for chr in {1..22}; do
    # Example URL for chromosome 1, replace with actual URL pattern
        echo "Processing number $chr"
        wget -c https://sg10k-health-releases-lambdaobjectaccesspoint-046503905558.s3-object-lambda.ap-southeast-1.amazonaws.com/SG10K_Health_r5.3/n9770/vcf/SG10K_Health_r5.3.2.sites.chr${chr}.vcf.bgz
        wget -c https://sg10k-health-releases-lambdaobjectaccesspoint-046503905558.s3-object-lambda.ap-southeast-1.amazonaws.com/SG10K_Health_r5.3/n9770/vcf/SG10K_Health_r5.3.2.sites.chr${chr}.vcf.bgz.tbi
done

#wget -c https://sg10k-health-releases-lambdaobjectaccesspoint-046503905558.s3-object-lambda.ap-southeast-1.amazonaws.com/SG10K_Health_r5.3/n9770/vcf/SG10K_Health_r5.3.2.sites.chrX.vcf.bgz
#wget -c https://sg10k-health-releases-lambdaobjectaccesspoint-046503905558.s3-object-lambda.ap-southeast-1.amazonaws.com/SG10K_Health_r5.3/n9770/vcf/SG10K_Health_r5.3.2.sites.chrX.vcf.bgz.tbi
'

echo -e "\n downloading \n"
#USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
#AUTH_TOKEN="jfxzqud9q4ksdb42lsl75kftztkbbwnai4uzstpyoi5jvazyqe"

#wget -v -c --header "Authorization: Bearer $AUTH_TOKEN" --max-redirect=20 https://sg10k-health-releases-lambdaobjectaccesspoint-046503905558.s3-object-lambda.ap-southeast-1.amazonaws.com/SG10K_Health_r5.3/n9770/vcf/SG10K_Health_r5.3.2.sites.chrX.vcf.bgz.tbi
#wget -v -c https://sg10k-health-releases.s3.ap-southeast-1.amazonaws.com/SG10K_Health_r5.3/n9770/vcf/SG10K_Health_r5.3.2.sites.chr16.vcf.bgz.tbi?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAQVU6ZJELL4BCOJFQ%2F20240816%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20240816T055816Z&X-Amz-Expires=60&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEO7%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDmFwLXNvdXRoZWFzdC0xIkgwRgIhAJFiKV5u2%2Fpbsew8LOfhih0pe%2FF%2BdmUaLdoeLpbDTcbpAiEAlRMISSgb6W4rqx3kw4PlOFKBzFgrSk7ekqY7ZfspU6YqhgMI5%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARADGgwwNDY1MDM5MDU1NTgiDBoqGNxY%2BohyOTHK5yraAjiJ0QQnQRe83Wc%2BvjEAcJYaTvOpK1ABQNhwzgUG3Ll7CXFMlhI3ZPiMhqKpI8fZF5WaWucyLr%2FZoFpDITmTAvN3FB7qTJRMxuhFkKZbxCfKu9ilKv%2BIR6cpw7LM0CzjoHQUCpV3Me3rCGYdW%2FeilfFR4rqsmJr88Z92Qae%2FB6R5XEJyumAQD3ZThRp6vZH6HpR%2BAUo7AouJSYZPBtgUCu%2FQcbJ6uzzjOLaeRXtOuKxH%2FpJbCIhCbNncxmhIsrJs3KsjXrLbBfTXb5EIdIsJApcWt1Dzg6kxZrPWKD0ptNZVSa5d7PYdDgsgNmbhgrW8vrhnj%2FCkmdbJNWzucVq2Esp3GoGa59JFZyT72zm5cjdrU5gtC3Yqqe6DVYZ1Chv8SFzQlwp9d7UhPPjNiCLPFHho1EvZabnAeMk86gjR61BlSGASlFFyo%2B4Egk5PGhEHLhUgdhkkt5fvQ8EwtNP7tQY6nQGIZRgA4VZ3w5TwEbmEEDWWT6TXCVI7PDuo7%2FXdj6lw8OORB8wKqUcTQBPF7KXFF9vkbi3OrzL8MujT1dbHkUMU3c6Q51LZ0teKmFcp4OVwFE37%2B7so8eCzyXUOhuNb6rGEeyUaTmWMsAsI81BQQbmaXVhuYC5HYut7HoNv3qeoqlpgJcT0mHLtabI%2BhUogH%2BC8ZLKCNHYAjE0rKKLB&X-Amz-Signature=e4f0c08a2f9732958a45c7138cc07f00deacfa6121d5a2eea796ec9bc05ee754&X-Amz-SignedHeaders=host
