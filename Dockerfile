FROM debian:jessie
MAINTAINER Stéphane Lepin <contact@slepin.fr>

# Create liquidsoap user with passwordless sudo
RUN apt-get update && apt-get install -y sudo
RUN useradd -m liquidsoap && echo 'liquidsoap ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers

# Install liquidsoap using OPAM
USER liquidsoap
WORKDIR /home/liquidsoap
RUN sudo apt-get install -y opam && opam init -a && eval `opam config env` && \
	opam install -y depext && \
	opam-depext taglib mad lame vorbis cry opus liquidsoap && \
	opam install -y taglib mad lame vorbis cry opus liquidsoap

RUN sudo mkdir /scriptdir
VOLUME /scriptdir

ENTRYPOINT eval `opam config env` && sudo chown -R liquidsoap:liquidsoap /scriptdir && \
	cd /scriptdir && liquidsoap /scriptdir/main.liq
