FROM ubuntu:18.04
MAINTAINER Stéphane Lepin <stephane.lepin@gmail.com>

ENV LIQ_VERSION 1.3.3
ENV LIQ_DOWNLOAD https://github.com/savonet/liquidsoap/releases/download/$LIQ_VERSION/liquidsoap-$LIQ_VERSION-full.tar.gz

# Create a dedicated user with passwordless sudo
USER root
RUN apt-get update && apt-get install -y sudo
RUN useradd -m liquidsoap && echo 'liquidsoap ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Build and install liquidsoap
USER liquidsoap
WORKDIR /home/liquidsoap
ENV LIQ_MODULES="ocaml-opus ocaml-fdkaac ocaml-flac ocaml-soundtouch ocaml-samplerate ocaml-dssi ocaml-xmlplaylist ocaml-lo ocaml-flac ocaml-mad ocaml-lame ocaml-gstreamer ocaml-lo"
RUN sudo apt-get install -y build-essential wget ocaml-findlib libao-ocaml-dev \
		libmad-ocaml-dev libtaglib-ocaml-dev libvorbis-ocaml-dev libladspa-ocaml-dev \
		libxmlplaylist-ocaml-dev libflac-dev libmp3lame-dev libcamomile-ocaml-dev \
		libpcre-ocaml-dev libfdk-aac-dev \
		libsamplerate-ocaml-dev libsoundtouch-ocaml-dev libdssi-ocaml-dev \
		liblo-ocaml-dev libyojson-ocaml-dev libopus-dev libgstreamer-ocaml-dev && \
	wget $LIQ_DOWNLOAD -O- | tar xvzf - && \
	cd /home/liquidsoap/liquidsoap-$LIQ_VERSION-full && cp PACKAGES.minimal PACKAGES && \
	for module in $LIQ_MODULES; do sed -i "s/#$module/$module/g" PACKAGES; done && \
	./configure && make && sudo make install && \
	cd /home/liquidsoap && rm -rf liquidsoap-$LIQ_VERSION-full && sudo apt-get autoclean -y

ENTRYPOINT ["liquidsoap"]
