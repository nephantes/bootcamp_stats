## using rocker/verse and adding some stuff for ARC

FROM rocker/verse:4.1.1

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rsettlag" \
      maintainer="Robert Settlage <rsettlag@vt.edu>"
## helpful read: https://divingintogeneticsandgenomics.rbind.io/post/run-rstudio-server-with-singularity-on-hpc/
ENV PATH="${PATH}:/miniconda3/bin"

RUN apt update \
  && apt-get install -y curl wget gzip locate jags libmpfr-dev

RUN Rscript -e "install.packages(Ncpus=6,c('rjags', 'tidyverse', 'dplyr', 'devtools', 'data.table', 'reticulate', 'ggpubr', 'rlecuyer', 'pkgmaker', 'gtools', 'RcppEigen', 'ggrepel', 'gplots', 'Rmpfr'))"
RUN tlmgr install harvard ctable multirow eurosym comment setspace enumitem \
      --repository http://ctan.math.illinois.edu/systems/texlive/tlnet\
  && tlmgr path add
RUN chown -R root:staff /opt/ \
  && chmod -R g+wx /opt/ \
  && tlmgr path add

RUN Rscript -e "library(reticulate); install_miniconda(path='/miniconda3',update=TRUE,force=TRUE)"


## Install bootcamp packages
RUN R -e 'install.packages("BiocManager",repos = "https://repo.miserver.it.umich.edu/cran/",dependencies = TRUE)'
RUN R -e 'BiocManager::install("DESeq2")'
RUN R -e 'BiocManager::install("ShortRead")'
RUN R -e 'BiocManager::install("Rsubread")'
RUN R -e 'install.packages(c( "pwr", "reshape2", "ggpubr","ggdendro"),repos = "https://repo.miserver.it.umich.edu/cran/",dependencies = TRUE)'
RUN R -e 'install.packages(c("tidyverse", "extraDistr", "gplots", "GGally", "ggrepel", "RColorBrewer"),repos = "https://repo.miserver.it.umich.edu/cran/",dependencies = TRUE)'
RUN R -e 'install.packages(c( "knitr", "RCurl", "plotly", "rmarkdown"),repos = "https://repo.miserver.it.umich.edu/cran/",dependencies = TRUE)'

RUN apt-get clean
RUN echo 'R_ENVIRON_USER=~/.Renviron.OOD \
      \n' >>/usr/local/lib/R/etc/Renviron
RUN rm /usr/local/lib/R/etc/Rprofile.site
