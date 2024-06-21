#!/bin/bash

set -e

DEFAULTRELEASE=7.3.0
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

BASENAME=(
'VCF_WBcel235'
'VCF_R6'
'VCF_GRCm39'
'VCF_mRatBN7.2'
'VCF_GRCz11'
'HTPOSTVEPVCF_FB'
'HTPOSTVEPVCF_RGD'
'HTPOSTVEPVCF_WB'
'HTPOSTVEPVCF_ZFIN'
'HTPOSTVEPVCF_SGD'
)


FILELIST=(
'VCF_WBcel235.vcf'
'VCF_R6.vcf'
'VCF_GRCm39.vcf'
'VCF_mRatBN7.2.vcf'
'VCF_GRCz11.vcf'
'HTPOSTVEPVCF_FB.vcf'
'HTPOSTVEPVCF_RGD.vcf'
'HTPOSTVEPVCF_WB.vcf'
'HTPOSTVEPVCF_ZFIN.vcf'
'HTPOSTVEPVCF_SGD.vcf'
)

GENERICLIST=(
'worm-latest.vcf'
'fly-latest.vcf'
'mouse-latest.vcf'
'rat-latest.vcf'
'zebrafish-latest.vcf'
'HTPOSTVEPVCF_FB_latest.vcf'
'HTPOSTVEPVCF_RGD_latest.vcf'
'HTPOSTVEPVCF_WB_latest.vcf'
'HTPOSTVEPVCF_ZFIN_latest.vcf'
'HTPOSTVEPVCF_SGD_latest.vcf'
)

#HTPONLY=(
#'human'
#'mouse'
#)

#parallel wget -q https://fms.alliancegenome.org/download/{}.gz ::: "${FILELIST[@]}"

#gets phenotypic vcf files
curl https://fms.alliancegenome.org/api/datafile/by/VCF?latest=true | python3 get_vcf_urls.py | parallel

#get high throughput vcf
curl https://fms.alliancegenome.org/api/datafile/by/HTPOSTVEPVCF?latest=true | python3 get_vcf_urls.py | parallel

#get rid of vcf for old assemblies
rm VCF_Rnor60*
rm VCF_GRCm38*

#parallel gzip -d {}.gz ::: "${FILELIST[@]}"
#un parallel this to make life easier
#gzip -d *.gz
ls *.vcf.gz | xargs -P 14 -n 1 gzip -d


parallel --link mv {1}*.vcf {2} ::: "${BASENAME[@]}" ::: "${GENERICLIST[@]}"

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


