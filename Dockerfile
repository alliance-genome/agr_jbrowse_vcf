FROM gmod/jbrowse-gff-base:latest 

LABEL maintainer="scott@scottcain.net"

RUN git clone --single-branch --branch main https://github.com/alliance-genome/agr_jbrowse_vcf.git

#at the moment, this repo isn't used
#RUN git clone --single-branch --branch master https://github.com/alliance-genome/agr_jbrowse_config.git

RUN  mv agr_jbrowse_vcf/parallel.sh .


#VOLUME /data
CMD ["/bin/bash", "/parallel.sh"]
