#!/bin/bash
#

RELEASE=5.1.1

while getopts r:s:a:k: option
do
case "${option}"
in
r)
  RELEASE=${OPTARG}
  ;;
b)
  AWSBUCKET=${OPTARG}
  ;;
esac
done

if [ -z "$RELEASE" ]
then
    RELEASE=${RELEASE}
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

CHROMOSOME=(
'4'
'5'
'6'
'7'
'8'
'9'
'10'
'11'
'12'
'13'
'14'
'15'
'16'
'17'
'18'
'19'
'MT'
'X'
'Y'
'3'
'2'
'1'
)

for CHROM in "${CHROMOSOME[@]}" ; do
    echo "fetching chrom $CHROM files"
    wget https://download.alliancegenome.org/variants/MGI/MGI.vep.$CHROM.vcf.gz
    wget https://download.alliancegenome.org/variants/MGI/MGI.vep.$CHROM.vcf.gz.tbi
    aws s3 cp --acl public-read MGI.vep.$CHROM.vcf.gz s3://$AWSBUCKET/docker/$RELEASE/MGI/mouse/VCF/MGI.vep.$CHROM.vcf.gz
    aws s3 cp --acl public-read MGI.vep.$CHROM.vcf.gz.tbi s3://$AWSBUCKET/docker/$RELEASE/MGI/mouse/VCF/MGI.vep.$CHROM.vcf.gz.tbi
    rm MGI.vep.$CHROM.vcf.gz
    rm MGI.vep.$CHROM.vcf.gz.tbi
done
  


