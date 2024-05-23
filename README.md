# agr_jbrowse_vcf

Tools for processing VCF data for JBrowse

This docker file is a collection of tools for fetching
Alliance VCF files, processing them into tabix indexed files, and then
moving the results to the Alliance S3 bucket (`agrjbrowse` by default, though
`agrjbrowse2` has been used for testing in the past). The use of this docker file
is controlled in GoCD in the `JBrowseSoftwareProcessVCF` and `JBrowseProcessVCF`
pipelines. The primary description of the workflow for getting genome browsing
ready for a new release is described in the agr_jbrowse_gff repo
(https://github.com/alliance-genome/agr_jbrowse_gff).

# Typical workflow

1. After both the phenotypic variant VCF and high throughput VCF files are
   available in the FMS (see note about `latest` files in the agr_jbrowse_gff
   README--the same thing applies here:
   https://github.com/alliance-genome/agr_jbrowse_gff?tab=readme-ov-file#warning-about-getting-the-latest-gff-files),
   edit the `parallel.sh` file to update the value on the `RELEASE=...` line.
   Commit and push that change.

2. Unpause the `JBrowseSoftwareProcessVCF` and `JBrowseProcessVCF` pipelines
   in GoCD (generally they are kept paused to avoid accidentally running them).
