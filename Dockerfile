FROM joelnitta/baitfindr_tidyverse:latest

### Other dependencies for fluidigm2purc
RUN apt-get update \
	&& apt-get install -y --no-install-recommends apt-utils \
        gcc \
        g++ \
        make \
        git \
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
        tk-dev \
        python-pip \
        python-dev \
	&& apt-get clean \
### R packages
# CRAN packages
	&& install2.r -e assertr caper DiagrammeR latex2exp kableExtra phangorn phytools seqinr writexl xaringan \
# Bioconductor packages
	&& Rscript -e 'source("http://bioconductor.org/biocLite.R")' \
	-e 'biocLite("Biostrings")' \
	-e 'biocLite("DECIPHER")' \
	-e 'biocLite("ShortRead")' \
# github packages
	&& Rscript -e 'library(devtools)' \
	-e 'install_github("r-lib/remotes")' \
	-e 'install_github("tidyverse/googledrive")'

# Install necessary python package
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
ENV PATH $PATH:/home/purc

# Make usearch executable
RUN cp /home/purc/Dependencies/usearch8.1.1756 /usr/bin/usearch \
  && chmod -v 0755 /usr/bin/usearch
