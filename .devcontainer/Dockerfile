# https://enchufa2.github.io/bspm/#ubuntu
FROM rocker/r-bspm:20.04 
# bspm in "/usr/local/lib/R/site-library" (not "/usr/lib/R/site-library")?

# update indices
RUN apt update -qq \
     && apt install --yes --no-install-recommends git

# https://cloud.r-project.org/bin/linux/ubuntu/
# install two helper packages we need
RUN apt install --no-install-recommends software-properties-common dirmngr

# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
# RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
# RUN add-apt-repository ppa:marutter/rrutter4.0   # R v4.0 and higher


# https://enchufa2.github.io/bspm/slides/20210709-useR2021_talk.html#28
RUN add-apt-repository ppa:c2d4u.team/c2d4u4.0+  # R packages
RUN apt install -y r-cran-bspm python3-{dbus,gi,apt}


# installs into "/usr/lib/R/site-library" (not "/usr/local/lib/R/site-library")
# RUN apt install --no-install-recommends --assume-yes r-base
# r-cran-bspm ? bspm is in list.files(.libPaths()[1]
# https://enchufa2.github.io/bspm/slides/20210709-useR2021_talk.html#21
#   cran2copr's CoprManager is just a branded version of bspm
RUN apt install --no-install-recommends --assume-yes r-cran-tidyverse 
RUN apt install --no-install-recommends --assume-yes r-cran-rstan 
# RUN apt install --no-install-recommends --assume-yes r-cran-brms
# RUN apt install --no-install-recommends --assume-yes r-cran-greta

# RUN Rscript --vanilla -e ' install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")), lib = "/usr/local/lib/R/site-library") '
# RUN Rscript --vanilla -e ' install.packages("brms", repos="https://cran.r-project.org", lib = "/usr/local/lib/R/site-library") '

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
# installs into "/usr/local/lib/R/site-library" NOT "/usr/lib/R/site-library"
ARG USERNAME=rstudio
ARG USER_UID=1001
ARG USER_GID=$USER_UID
USER root
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && usermod -a -G staff ${USERNAME} \
    && apt-get -y install \
        python3-pip \
        libgit2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libxt-dev \
        libfontconfig1-dev \
        libcairo2-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts \
    && python3 -m pip --no-cache-dir install radian \
    && install2.r --error --skipinstalled --ncpus -1 \
        languageserver httpgd \
    && rm -rf /tmp/downloaded_packages


# VSCode R Debugger dependency. Install the latest release version from GitHub without using GitHub API.
# See https://github.com/microsoft/vscode-dev-containers/issues/1032
# remotes from tidyverse?
RUN export TAG=$(git ls-remote --tags --refs --sort='version:refname' https://github.com/ManuelHentschel/vscDebugger v\* | tail -n 1 | cut --delimiter='/' --fields=3) \
    && Rscript -e "remotes::install_git('https://github.com/ManuelHentschel/vscDebugger.git', ref = '"${TAG}"', dependencies = FALSE)"

# R Session watcher settings.
# See more details: https://github.com/REditorSupport/vscode-R/wiki/R-Session-watcher
RUN echo 'if (interactive() && Sys.getenv("TERM_PROGRAM") == "vscode") source(file.path(Sys.getenv("HOME"), ".vscode-R", "init.R"))' >>"${R_HOME}/etc/Rprofile.site"


USER rstudio
# savehistory is NA under radian ? 
#   WARNING: this might include sensitive data / passwords?
# perhaps save to ./.radian_history ?
#   ./.Rhistory (not ~/.Rhistory) so .Rhistory is stored
ENV R_HISTFILE "./.Rhistory" 
