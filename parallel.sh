#!/bin/bash

set -e

RELEASE=5.1.1
while getopts r:s:a:k: option
do
case "${option}"
in
r) 
  RELEASE=${OPTARG}
  ;;
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

if [ -z "$RELEASE" ]
then
    RELEASE=${RELEASE}
fi

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
        AWSBUCKET=agrjbrowse2
    else
        AWSBUCKET=${AWS_S3_BUCKET}
    fi
fi

echo "awsbucket:"
echo $AWSBUCKET
echo "release"
echo $RELEASE

FILELIST=(
'VCF_WBcel235.vcf'
'VCF_R6.vcf'
'VCF_GRCm39.vcf'
#'VCF_mRatBN7.2.vcf'
'VCF_GRCz11.vcf'
)

GENERICLIST=(
'worm-latest.vcf'
'fly-latest.vcf'
'mouse-latest.vcf'
#'rat-latest.vcf'
'zebrafish-latest.vcf'
)

parallel wget -q https://fms.alliancegenome.org/download/{}.gz ; gzip -d {}.gz ::: "${FILELIST[@]}"

parallel --link mv {} {} ::: "${FILELIST[@]}" ::: "${GENERICLIST[@]}"

parallel bgzip {} ; tabix {} ; aws s3 cp --acl public-read fly-latest.vcf.gz s3://agrjbrowse/VCF/$RELEASE/{}.gz ; aws s3 cp --acl public-read fly-latest.vcf.gz s3://agrjbrowse/VCF/$RELEASE/{}.gz.tbi ::: "${GENERICLIST[@]}"



