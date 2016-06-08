FROM debian:jessie
MAINTAINER Stéphane Lepin <contact@slepin.fr>

# Create liquidsoap user with passwordless sudo
RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list && \
	sed -i "s/httpredir.debian.org/ftp.debian.org/" /etc/apt/sources.list
RUN apt-get update && apt-get install -y sudo
RUN useradd -m liquidsoap && echo 'liquidsoap ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers

# Build liquidsoap from source
USER liquidsoap
WORKDIR /home/liquidsoap
RUN sudo apt-get install -y build-essential wget ocaml-findlib libao-ocaml-dev \
	libmad-ocaml-dev libtaglib-ocaml-dev libvorbis-ocaml-dev libladspa-ocaml-dev \
	libxmlplaylist-ocaml-dev libflac-dev libmp3lame-dev libcamomile-ocaml-dev \
	libfaad-dev libpcre-ocaml-dev libfdk-aac-dev \
	libsamplerate-ocaml-dev libsoundtouch-ocaml-dev libdssi-ocaml-dev \
	liblo-ocaml-dev libyojson-ocaml-dev libopus-dev
RUN wget https://github.com/savonet/liquidsoap/releases/download/liquidsoap-1.1.1/liquidsoap-1.1.1-full.tar.gz -O- | tar zxvf -
WORKDIR /home/liquidsoap/liquidsoap-1.1.1-full
RUN cp PACKAGES.minimal PACKAGES && \
	for module in ocaml-opus ocaml-fdkaac ocaml-faad ocaml-soundtouch ocaml-samplerate \
	ocaml-dssi ocaml-xmlplaylist ocaml-lo; do sed -i "s/#$module/$module/g" PACKAGES; done
RUN ./configure
RUN make
RUN sudo make install

# Runtime environment
RUN sudo mkdir /scriptdir
VOLUME /scriptdir
ENTRYPOINT eval `opam config env` && sudo chown -R liquidsoap:liquidsoap /scriptdir && \
	cd /scriptdir && liquidsoap /scriptdir/main.liq
