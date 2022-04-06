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
'20'
'21'
'22'
'MT'
'X'
'Y'
'1'
'2'
'3'
'4'
)

for CHROM in "${CHROMOSOME[@]}" ; do
    echo "fetching chrom $CHROM files"
    wget https://download.alliancegenome.org/variants/HUMAN/HUMAN.vep.$CHROM.vcf.gz
    wget https://download.alliancegenome.org/variants/HUMAN/HUMAN.vep.$CHROM.vcf.gz.tbi
    aws s3 cp --acl public-read HUMAN.vep.$CHROM.vcf.gz s3://$AWSBUCKET/docker/$RELEASE/human/VCF/HUMAN.vep.$CHROM.vcf.gz
    aws s3 cp --acl public-read HUMAN.vep.$CHROM.vcf.gz.tbi s3://$AWSBUCKET/docker/$RELEASE/human/VCF/HUMAN.vep.$CHROM.vcf.gz.tbi
    rm HUMAN.vep.$CHROM.vcf.gz
    rm HUMAN.vep.$CHROM.vcf.gz.tbi
done
  


