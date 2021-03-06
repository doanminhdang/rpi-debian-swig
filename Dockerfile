# Pull base image
FROM resin/raspberrypi3-debian:stretch

# Install dependencies update apt
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -qy build-essential \
    gcc g++ \
    libgsl0-dev \
    liblapack-dev \
    libopenblas-dev \
    libeigen3-dev \
    python3-tk \
    automake \
    libpcre3-dev \
    git \
    cmake \
    python3-dev \
    pkg-config
RUN apt-get install byacc # swig
RUN apt-get install python3-scipy python3-numpy python3-matplotlib
RUN rm -rf /var/lib/apt/lists/*

# Define working directory
WORKDIR /home/pi

RUN git clone https://github.com/acados/acados.git -b master acados
RUN cd /home/pi/acados && git submodule update --recursive --init

# Set Python to Python3
RUN cd /usr/bin && ln -s python3 python

# Compile swig
RUN cd /home/pi/acados/external/swig && \
    ./autogen.sh && \
    ./configure --prefix=$(pwd)/swig_install --enable-silent-rules && \
    make && \
    make install > /dev/null # quiet installation

# Add date for tracing the date of installing
RUN cd /home/pi && date -u '+%F %T %Z' > date_install_swig.txt

# Set PATH environment to let casadi and acados find swig
ENV PATH="/home/pi/acados/external/swig:${PATH}"

# Make port 22 available to the world outside this container
EXPOSE 22

# Define default command
CMD ["bash"]
