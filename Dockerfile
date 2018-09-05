FROM ubuntu:16.04
COPY liblsl*.deb /
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install git g++ make libsndfile1-dev jackd2 portaudio19-dev \
                       libjack-jackd2-dev octave-signal default-jre liblo-dev && \
    dpkg -i /liblsl*.deb && \
    rm /liblsl*.deb && \
    mkdir -p /opt && \
    git clone https://github.com/HoerTech-gGmbH/openMHA/ /opt/openMHA
WORKDIR /opt/openMHA
RUN ./configure && \
    make -j 4 test unit-tests install && \
    echo ". /opt/openMHA/bin/thismha.sh" >> /root/.bashrc
