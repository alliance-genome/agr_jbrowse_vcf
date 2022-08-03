FROM gmod/jbrowse-gff-base:latest 

LABEL maintainer="scott@scottcain.net"

RUN git clone --single-branch --branch main https://github.com/alliance-genome/agr_jbrowse_vcf.git

#at the moment, this repo isn't used
#RUN git clone --single-branch --branch master https://github.com/alliance-genome/agr_jbrowse_config.git

RUN  mv agr_jbrowse_vcf/parallel.sh . && \
     mv agr_jbrowse_vcf/get_vcf_urls.py . && \
     mv agr_jbrowse_vcf/human_fetch_and_upload.sh . && \
     mv agr_jbrowse_vcf/mouse_fetch_and_upload.sh .


#VOLUME /data
CMD ["/bin/bash", "/parallel.sh"]
