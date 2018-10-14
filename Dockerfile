FROM rocker/tidyverse:latest

### Other dependencies, mostly for fluidigm2purc
RUN apt-get update \
	&& apt-get install -y --no-install-recommends apt-utils \
        gcc \
        g++ \
        make \
        git \
        nano \
        wget \
        default-jre \
        default-jdk \
        build-essential \
        checkinstall \
        libreadline-gplv2-dev \
        libncursesw5-dev \
        libssl-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libc6-dev \
        libbz2-dev \
        mafft \
        ncbi-blast+ \
        phyutility \
        raxml \
        tk-dev \
        python-pip \
        python-dev \
# geospatial dependencies start (https://github.com/rocker-org/geospatial/blob/master/Dockerfile)
        lbzip2 \
        libfftw3-dev \
        libgdal-dev \
        libgeos-dev \
        libgsl0-dev \
        libgl1-mesa-dev \
        libglu1-mesa-dev \
        libhdf4-alt-dev \
        libhdf5-dev \
        libjq-dev \
        liblwgeom-dev \
        libproj-dev \
        libprotobuf-dev \
        libnetcdf-dev \
        libsqlite3-dev \
        libssl-dev \
        libudunits2-dev \
        netcdf-bin \
        protobuf-compiler \
        tk-dev \
        unixodbc-dev \
# geospatial dependencies end 
	&& apt-get clean \
	&& sudo cp /usr/bin/raxmlHPC /usr/bin/raxml \
### R packages
# Bioconductor packages
	&& Rscript -e 'source("http://bioconductor.org/biocLite.R")' \
	-e 'biocLite("Biostrings")' \
	-e 'biocLite("DECIPHER")' \
	-e 'biocLite("ShortRead")' \
	-e 'biocLite("graph")' \
# CRAN packages
	&& install2.r -e ape assertr caper conflicted drake future here ips DiagrammeR latex2exp kableExtra miniUI phangorn phytools rgdal sf seqinr txtq visNetwork writexl xaringan \
# github packages
	&& Rscript -e 'library(devtools)' \
	-e 'install_github("r-lib/remotes")' \
	-e 'install_github("tidyverse/googledrive")' \
	-e 'install_github("joelnitta/jntools")'

# Python packages
WORKDIR /tmp
RUN pip install -q -U biopython cython numpy pandas
	
# Clone and install fluidigm2purc
WORKDIR /home
RUN git clone https://github.com/pblischak/fluidigm2purc.git \
  && cd fluidigm2purc \
  && make && make install

# Clone and install PURC
WORKDIR /home
RUN git clone https://bitbucket.org/crothfels/purc.git \
  && cd purc \
  && bash install_dependencies_linux.sh
# Add custom purc script generated from make_purc_recluster_strict function in T_angustifrons project
ADD purc_recluster_strict.py purc/
ENV PATH $PATH:/home/purc

# Make usearch executable
RUN cp /home/purc/Dependencies/usearch8.1.1756 /usr/bin/usearch \
  && chmod -v 0755 /usr/bin/usearch
