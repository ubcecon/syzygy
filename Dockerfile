FROM callysto/pims-minimal

LABEL maintainer "Ian Allison <iana@pims.math.ca>"

USER root

# Sundials, NLopt, MPI, Nemo, Cairo
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsundials-cvode1 \
    libsundials-cvodes2 \
    libsundials-ida2 \
    libsundials-idas0 \
    libsundials-kinsol1 \
    libsundials-nvecserial0 \
    libsundials-serial \
    libsundials-serial-dev \
    libnlopt0 \
    libnlopt-dev \
    openmpi-bin \
    libopenmpi-dev \
    m4 \
    yasm \
    libacl1-dev \
    gettext \
    zlib1g-dev \
    libffi-dev \
    libpng-dev \
    libpixman-1-dev \
    libpoppler-dev \
    librsvg2-dev \
    libcairo2-dev \
    libpango1.0-0 \
    tk-dev \
    pkg-config \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ipopt
RUN mkdir -p /opt/ipopt \
  && curl -s -L http://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.10.tgz | \
     tar -C /opt/ipopt -x -z --strip-components=1 -f - \
  && cd /opt/ipopt/ThirdParty/Blas && ./get.Blas \
  && ./configure --prefix=/usr/local --disable-shared --with-pic \
  && make install \
  && cd /opt/ipopt/ThirdParty/Lapack && ./get.Lapack \
  && ./configure --prefix=/usr/local --disable-shared --with-pic \
  && make install \
  && cd /opt/ipopt/ThirdParty/Mumps && ./get.Mumps \
  && cd /opt/ipopt/ThirdParty/ASL && ./get.ASL && cd /opt/ipopt \
  && env LIBS='-lgfortran' ./configure --prefix=/usr/local \
    --enable-dependency-linking \
  && make install && echo "/usr/local/lib" > /etc/ld.so.conf.d/ipopt.conf \
  && ldconfig && rm -rf /opt/ipopt

# CBC
RUN mkdir -p /opt/cbc \
  && curl -s -L http://www.coin-or.org/download/source/Cbc/Cbc-2.9.9.tgz | \
     tar -C /opt/cbc -x -z --strip-components=1 -f - \
  && cd /opt/cbc \
  && ./configure --prefix=/usr/local \
    --enable-dependency-linking \
    --without-blas \
    --without-lapack \
    --enable-cbc-parallel \
  && make install && echo "/usr/local/lib" > /etc/ld.so.conf.d/cbc.conf \
  && ldconfig && rm -rf /opt/cbc

# Stan
RUN mkdir -p /opt/cmdstan \
  && curl -s -L https://github.com/stan-dev/cmdstan/releases/download/v2.18.0/cmdstan-2.18.0.tar.gz | \
     tar -C /opt/cmdstan -x -z --strip-components=1 -f - \
  && (cd /opt/cmdstan && echo "CC=g++" >> make/local && echo "CXX=g++" >> make/local && make build) \
  && echo "export CMDSTAN_HOME=/usr/share/cmdstan" > /etc/profile.d/cmdstan.sh \
  && chmod 755 /etc/profile.d/cmdstan.sh \
  && rm -rf /opt/stan

# MPIR
RUN mkdir -p /opt/mpir \
  && curl -s -L http://mpir.org/mpir-3.0.0.tar.bz2 | \
     tar -C /opt/mpir -x -j --strip-components=1 -f - \
  && cd /opt/mpir \
  && ./configure M4=/usr/bin/m4 --enable-gmpcompat --disable-static --enable-shared \
  && make && make install \
  && rm -rf /opt/mpir

# MPFR
RUN mkdir -p /opt/mpfr \
  && cd /opt/mpfr \
  && curl -s -L http://ftp.gnu.org/gnu/mpfr/mpfr-4.0.1.tar.bz2 | \
     tar -C /opt/mpfr -x -j --strip-components=1 -f - \
  && cd /opt/mpfr \
  && ./configure --with-gmp=/usr/local --disable-static --enable-shared \
  && make && make install \
  && rm -rf /opt/mpfr

# Flint2
RUN mkdir -p /opt/flint2 \
  && cd /opt/flint2 \
  && git clone https://github.com/fredrik-johansson/flint2 /opt/flint2 \
  && cd /opt/flint2 \
  && ./configure --disable-static --enable-shared --with-mpir --with-mpfr \
  && make && make install \
  &&  rm -rf /opt/flint2

# **** JULIA-SPECIFIC ****
# Create the following directory in /opt (canonical software receptacle for Linux)
RUN mkdir -p /opt/julia-1.0.0 \
  # Download and unpack Julia binaries. 
  && curl -s -L https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.0-linux-x86_64.tar.gz | \
     tar -C /opt/julia-1.0.0 -x -z --strip-components=1 -f - \
  # Make 'julia-1.0' point to julia-1.0.0
  && ln -fs /opt/julia-1.0.0 /opt/julia-1.0 \
  # Make 'julia' point to julia-1.0.0
  && rm -rf /opt/julia && ln -fs /opt/julia-1.0.0 /opt/julia \
  # Make '/usr/bin/julia' point to our 'julia', which is 'julia-1.0.0'
  && ln -fs /opt/julia/bin/julia /usr/bin/julia \
  # Give ownership of that Julia install to 'jovyan', the "shared user."
  && chown -R jovyan /opt/julia-1.0.0

# Configure our shared environment. 
# Switch over to 'jovyan'
ENV NB_USER=jovyan
ENV HOME=/home/$NB_USER
USER $NB_USER

# Set up our QuantEcon environment in the first depot entry for jovyan (~/jovyan/.julia). 
RUN julia -e "using Pkg; pkg\"add IJulia Compat Revise Plots GR Parameters Expectations Distributions DifferentialEquations DiffEqCallbacks\"; pkg\"build\";  pkg\"precompile\""
# Add the InstantiateFromURL package 
RUN julia -e "using Pkg; pkg\"add https://github.com/QuantEcon/InstantiateFromURL.jl\"; pkg\"precompile\""
# For mkdir stuff. 
USER root 
# Grab the v0.1.0 of the QuantEconLecturePackages
RUN julia -e "using Pkg; using InstantiateFromURL; activate_github(\"QuantEcon/QuantEconLecturePackages\", version = \"v0.1.0\")"
# Grab the v0.2.0 of the QuantEconLecturePackages
RUN julia -e "using Pkg; using InstantiateFromURL; activate_github(\"QuantEcon/QuantEconLecturePackages\", version = \"v0.2.0\")"
# Grab the master of that. 
RUN julia -e "using Pkg; using InstantiateFromURL; activate_github(\"QuantEcon/QuantEconLecturePackages\")"

# Conda stuff. 
RUN mv $HOME/.local/share/jupyter/kernels/julia-1.0 $CONDA_DIR/share/jupyter/kernels/ \
  && chmod -R go+rx /opt/julia \
  && chmod -R go+rx $CONDA_DIR/share/jupyter \
  && rm -rf $HOME/.local \ 
  # Nuke the registry that came with Julia. 
  && rm -rf /opt/julia-1.0.0/local/share/julia/registries \ 
  # Nuke the registry that Jovyan uses. 
  && rm -rf $HOME/.julia/registries 
  
# Create the init script. 
ADD init.sh $HOME/init.sh

# Give the user read and execute permissions over /jovyan/.julia. 
RUN chmod -R go+rx /home/jovyan/.julia
# Give the user read and execute permissions over the init script. 
RUN chmod go+rx /home/jovyan/init.sh

# Set up our user. 
USER jupyter
ENV NB_USER=jupyter \
    NB_UID=9999
ENV HOME=/home/$NB_USER
ENV JULIA_DEPOT_PATH="/home/jupyter/.julia:/home/jovyan/.julia:/opt/julia"
# Run the init script. 
RUN /home/jovyan/init.sh 