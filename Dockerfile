# Base image with common dependencies for either running or compiling openMHA
FROM ubuntu:18.04 as openmha-rtbase
COPY liblsl_*.deb /
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install libsndfile1 jackd2 libportaudio2 libjack-jackd2-0 \
                       octave-signal default-jre liblo7 && \
    dpkg -i /liblsl_*.deb && \
    rm /liblsl_*.deb

# Image with development tools for compiling openMHA
FROM openmha-rtbase as openmha-dev
COPY liblsl-dev_*.deb /
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install git g++-7 make libsndfile1-dev portaudio19-dev \
                       libjack-jackd2-dev liblo-dev && \
    dpkg -i /liblsl-dev*.deb && \
    rm /liblsl-dev_*.deb && \
    mkdir -p /opt && \
    git clone https://github.com/HoerTech-gGmbH/openMHA/ /opt/openMHA
WORKDIR /opt/openMHA

# Image with a compiled openMHA ready for usage, development env still available
FROM openmha-dev as openmha-all
RUN ./configure && \
    make -j 4 test unit-tests install
RUN echo ". /opt/openMHA/bin/thismha.sh" >> /root/.bashrc

# Image with openmha without source code or dev environment
FROM openmha-rtbase as openmha-rt
COPY --from=openmha-all /opt/openMHA/bin /opt/openMHA/bin
COPY --from=openmha-all /opt/openMHA/lib /opt/openMHA/lib
COPY --from=openmha-all /root/.bashrc /root/.bashrc
