# agr_jbrowse_vcf
Tools for processing VCF data for JBrowse

This docker file is a collection of scripts I've used for manually fetching
Alliance VCF files, processing them into tabix indexed files, and then
moving the results to the Alliance S3 bucket (`agrjbrowse` by default, though
`agrjbrowse2` is frequently used for testing). The use of this docker
file is pretty straight forward:

```
docker build --no-cache -f Dockerfile -t jbrowse-vcf .
```
and then
```
docker run --rm -e "AWS_ACCESS_KEY=<access key>" \
                -e "AWS_SECRET_KEY=<secret key>" \
                -e "RELEASE=6.0.0" jbrowse-vcf
```

While GoCD pipelines using this docker container on an ansible machine
doesn't exist yet, it should soon.

There are basically three types of VCF files this script deals with:

1. Phenotypic variants VCF files.
2. "Typical" highthroughput VCF files.
3. "Per chromosome" VCF files for mouse and human.
 
