ARG BASE_IMAGE=rstudio/r-base
FROM ${BASE_IMAGE}:xenial
MAINTAINER Manuel Garber <manuel.garber@umassmed.edu>

ARG R_VERSION=4.1.0
ARG OS_IDENTIFIER=ubuntu-1604


RUN   echo "Hello from inside the container"
RUN    export DEBIAN_FRONTEND="noninteractive"
#RUN    sed -i 's/$/ universe/' /etc/apt/sources.list
RUN    apt-get update --fix-missing 

    # Install ubuntu system-level packages
    # hadolint ignore=DL3008,DL3009
RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends \
        wget \
        bzip2 \
        ca-certificates \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1 \
        gdebi-core \
       aptitude\	
        libssl1.0.0 \
        libssl-dev git \
	sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
       
    # The aptitude command works better than apt-get for some packages
RUN    aptitude -y install g++ xorg-dev libreadline-dev gfortran locales-all
    

# Install R
RUN wget https://cdn.rstudio.com/r/${OS_IDENTIFIER}/pkgs/r-${R_VERSION}_1_amd64.deb && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y ./r-${R_VERSION}_1_amd64.deb && \
    ln -s /opt/R/${R_VERSION}/bin/R /usr/bin/R && \
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/bin/Rscript && \
    ln -s /opt/R/${R_VERSION}/lib/R /usr/lib/R && \
    rm r-${R_VERSION}_1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*


# Install Python  -------------------------------------------------------------#
ARG PYTHON_VERSION=3.9.5
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-4.7.12.1-Linux-x86_64.sh && \
    bash Miniconda3-4.7.12.1-Linux-x86_64.sh -bp /opt/python/${PYTHON_VERSION} && \
    /opt/python/${PYTHON_VERSION}/bin/conda install -y python==${PYTHON_VERSION} && \
    /opt/python/${PYTHON_VERSION}/bin/pip install 'virtualenv<20' && \
    /opt/python/${PYTHON_VERSION}/bin/pip install --upgrade setuptools && \
    rm -rf Miniconda3-*-Linux-x86_64.sh

# Install Rstudio 4.0
RUN    export PATH=/usr/lib/rstudio-server/bin:${PATH}
    # Add the R repository for version 4.0
RUN    echo "deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran40/" >> /etc/apt/sources.list
RUN    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN    apt-get -y update
RUN    apt-cache showpkg r-base
RUN    aptitude -y install r-base-core r-base-dev r-recommended r-recommended r-cran-mgcv r-cran-nlme

# Download and install rstudio-server
RUN    wget https://download2.rstudio.org/server/xenial/amd64/rstudio-server-1.3.1093-amd64.deb
RUN    gdebi -n ./rstudio-server-1.3.1093-amd64.deb


# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini


## Install bootcamp packages
RUN R -e 'install.packages("BiocManager",repos = "https://repo.miserver.it.umich.edu/cran/",dependencies = TRUE)'
RUN R -e 'BiocManager::install("DESeq2")'
RUN R -e 'BiocManager::install("ShortRead")'
RUN R -e 'BiocManager::install("Rsubread")'
RUN R -e 'install.packages(c( "pwr", "reshape2", "ggpubr","ggdendro"),repos = "https://repo.miserver.it.umich.edu/cran/",dependencies = TRUE)'
RUN R -e 'install.packages(c("tidyverse", "extraDistr", "gplots", "GGally", "ggrepel", "RColorBrewer"),repos = "https://repo.miserver.it.umich.edu/cran/",dependencies = TRUE)'
RUN R -e 'install.packages(c( "knitr", "RCurl", "plotly", "rmarkdown"),repos = "https://repo.miserver.it.umich.edu/cran/",dependencies = TRUE)'

CMD ["rserver \"${@}\""]


