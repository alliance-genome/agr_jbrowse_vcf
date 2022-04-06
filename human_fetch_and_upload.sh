#!/bin/bash
#

#RELEASE=5.1.1

while getopts r:a:k:b: option
do
case "${option}"
in
r)
  RELEASE=${OPTARG}
  ;;
b)
  AWSBUCKET=${OPTARG}
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

if [ -z "$AWSBUCKET" ]
then
    if [ -z "${AWS_S3_BUCKET}" ]
    then
        AWSBUCKET=agrjbrowse2
    else
        AWSBUCKET=${AWS_S3_BUCKET}
    fi
fi

if [ -z "$AWSACCESS" ]
then
    AWSACCESS=${AWS_ACCESS_KEY}
fi

if [ -z "$AWSSECRET" ]
then
    AWSSECRET=${AWS_SECRET_KEY}
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
    wget -q https://download.alliancegenome.org/variants/HUMAN/HUMAN.vep.$CHROM.vcf.gz
    wget -q https://download.alliancegenome.org/variants/HUMAN/HUMAN.vep.$CHROM.vcf.gz.tbi
    AWS_ACCESS_KEY_ID=$AWSACCESS AWS_SECRET_ACCESS_KEY=$AWSSECRET aws s3 cp --quiet --acl public-read HUMAN.vep.$CHROM.vcf.gz s3://$AWSBUCKET/docker/$RELEASE/human/VCF/HUMAN.vep.$CHROM.vcf.gz
    AWS_ACCESS_KEY_ID=$AWSACCESS AWS_SECRET_ACCESS_KEY=$AWSSECRET aws s3 cp --quiet --acl public-read HUMAN.vep.$CHROM.vcf.gz.tbi s3://$AWSBUCKET/docker/$RELEASE/human/VCF/HUMAN.vep.$CHROM.vcf.gz.tbi
    rm HUMAN.vep.$CHROM.vcf.gz
    rm HUMAN.vep.$CHROM.vcf.gz.tbi
done
  


