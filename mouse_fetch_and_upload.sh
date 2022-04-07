#!/bin/bash
#

#RELEASE=5.1.1

while getopts r:b:a:k: option
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
    RELEASE=${ALLIANCE_RELEASE}
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
    wget -q https://download.alliancegenome.org/variants/MGI/MGI.vep.$CHROM.vcf.gz
    wget -q https://download.alliancegenome.org/variants/MGI/MGI.vep.$CHROM.vcf.gz.tbi
    AWS_ACCESS_KEY_ID=$AWSACCESS AWS_SECRET_ACCESS_KEY=$AWSSECRET aws s3 cp --quiet --acl public-read MGI.vep.$CHROM.vcf.gz s3://$AWSBUCKET/docker/$RELEASE/MGI/mouse/VCF/MGI.vep.$CHROM.vcf.gz
    AWS_ACCESS_KEY_ID=$AWSACCESS AWS_SECRET_ACCESS_KEY=$AWSSECRET aws s3 cp --quiet --acl public-read MGI.vep.$CHROM.vcf.gz.tbi s3://$AWSBUCKET/docker/$RELEASE/MGI/mouse/VCF/MGI.vep.$CHROM.vcf.gz.tbi
    rm MGI.vep.$CHROM.vcf.gz
    rm MGI.vep.$CHROM.vcf.gz.tbi
done
  


