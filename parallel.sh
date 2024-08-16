#!/bin/bash

set -e

DEFAULTRELEASE=7.4.0
while getopts r:s:a:k: option
do
case "${option}"
in
#r) 
#  RELEASE=${OPTARG}
#  ;;
s) 
  SPECIES=${OPTARG}
  ;;
a)
  AWSACCESS=${OPTARG}
  ;;
k)
  AWSSECRET=${OPTARG}
  ;;
esac
done

#if [ -z "$RELEASE" ]
#then
#    RELEASE=${ALLIANCE_RELEASE}
#fi
#if [ -z "$RELEASE" ]
#then
    RELEASE=${DEFAULTRELEASE}
#fi

if [ -z "$AWSACCESS" ]
then
    AWSACCESS=${AWS_ACCESS_KEY}
fi

if [ -z "$AWSSECRET" ]
then
    AWSSECRET=${AWS_SECRET_KEY}
fi

if [ -z "$AWSBUCKET" ]
then
    if [ -z "${AWS_S3_BUCKET}" ]
    then
        AWSBUCKET=agrjbrowse
    else
        AWSBUCKET=${AWS_S3_BUCKET}
    fi
fi

echo "awsbucket:"
echo $AWSBUCKET
echo "release"
echo $RELEASE

VCFMOD=(
'WBcel235'
'R6'
'GRCm39'
'mRatBN7.2'
'GRCz11'
)

HTMOD=(
'FB'
'RGD'
'WB'
'ZFIN'
'SGD'
)

VCFBASENAME=(
'VCF_WBcel235'
'VCF_R6'
'VCF_GRCm39'
'VCF_mRatBN7.2'
'VCF_GRCz11'
)

HTBASENAME=(
'HTPOSTVEPVCF_FB'
'HTPOSTVEPVCF_RGD'
'HTPOSTVEPVCF_WB'
'HTPOSTVEPVCF_ZFIN'
'HTPOSTVEPVCF_SGD'
)

VCFGENERICLIST=(
'worm-latest.vcf'
'fly-latest.vcf'
'mouse-latest.vcf'
'rat-latest.vcf'
'zebrafish-latest.vcf'
)

HTGENERICLIST=(
'HTPOSTVEPVCF_FB_latest.vcf'
'HTPOSTVEPVCF_RGD_latest.vcf'
'HTPOSTVEPVCF_WB_latest.vcf'
'HTPOSTVEPVCF_ZFIN_latest.vcf'
'HTPOSTVEPVCF_SGD_latest.vcf'
)

GENERICLIST=( "${VCFGENERICLIST[@]}" "${HTGENERICLIST[@]}")

#HTPONLY=(
#'human'
#'mouse'
#)

#parallel wget -q https://fms.alliancegenome.org/download/{}.gz ::: "${FILELIST[@]}"

#gets phenotypic vcf files

for mod in "${VCFMOD[@]}"; do
	curl https://fms.alliancegenome.org/api/datafile/by/$RELEASE/VCF/$mod?latest=true   | python3 get_vcf_urls.py | bash
done 

for mod in "${HTMOD[@]}"; do
        curl https://fms.alliancegenome.org/api/datafile/by/$RELEASE/HTPOSTVEPVCF/$mod?latest=true | python3 get_vcf_urls.py | bash
done

#parallel ( curl https://fms.alliancegenome.org/api/datafile/by/$RELEASE/VCF/{}?latest=true   | python3 get_vcf_urls.py | bash ) ::: "${VCFMOD[@]}"
#parallel ( curl https://fms.alliancegenome.org/api/datafile/by/$RELEASE/HTVCF/{}?latest=true | python3 get_vcf_urls.py | bash ) ::: "${HTMOD[@]}"
#curl https://fms.alliancegenome.org/api/datafile/by/VCF?latest=true | python3 get_vcf_urls.py | parallel

#get high throughput vcf
#curl https://fms.alliancegenome.org/api/datafile/by/HTPOSTVEPVCF?latest=true | python3 get_vcf_urls.py | parallel

#get rid of vcf for old assemblies
#rm VCF_Rnor60*
#rm VCF_GRCm38*

#parallel gzip -d {}.gz ::: "${FILELIST[@]}"
#un parallel this to make life easier
#gzip -d *.gz
ls *.vcf.gz | xargs -P 14 -n 1 gzip -d


parallel --link mv {1}*.vcf {2} ::: "${VCFBASENAME[@]}" ::: "${VCFGENERICLIST[@]}"
parallel --link mv {1}*.vcf {2} ::: "${HTBASENAME[@]}"  ::: "${HTGENERICLIST[@]}"

#parallel --link mv {1} {2} ::: "${FILELIST[@]}" ::: "${GENERICLIST[@]}"

parallel bgzip {} ::: "${GENERICLIST[@]}"

parallel tabix {}.gz ::: "${GENERICLIST[@]}"

parallel AWS_ACCESS_KEY_ID=$AWSACCESS AWS_SECRET_ACCESS_KEY=$AWSSECRET aws s3 cp --acl public-read {}.gz s3://$AWSBUCKET/VCF/$RELEASE/ ::: "${GENERICLIST[@]}"

parallel AWS_ACCESS_KEY_ID=$AWSACCESS AWS_SECRET_ACCESS_KEY=$AWSSECRET aws s3 cp --acl public-read {}.gz.tbi s3://$AWSBUCKET/VCF/$RELEASE/ ::: "${GENERICLIST[@]}"

#some of these files can be big too
#parallel rm {}.gz ::: "${GENERICLIST[@]}"
#parallel rm {}.gz.tbi ::: "${GENERICLIST[@]}"

#parallel ./{}_fetch_and_upload.sh -r $RELEASE ::: "${HTPONLY[@]}"
# decided not to do this in parallel--might be causing disk space issues
#./mouse_fetch_and_upload.sh -r $RELEASE
#./human_fetch_and_upload.sh -r $RELEASE


