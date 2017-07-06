FROM ocaml/opam:ubuntu-17.04_ocaml-4.02.3
MAINTAINER Stéphane Lepin <stephane.lepin@gmail.com>

USER opam
ENV LIQ_VERSION="1.3.1"
ENV LIQ_PLUGINS="mad lame vorbis opus fdkaac flac cry taglib soundtouch samplerate"
RUN opam update
RUN eval $(opam config env) && opam depext -y -i $LIQ_PLUGINS "liquidsoap.$LIQ_VERSION"

ENTRYPOINT ["/home/opam/.opam/system/bin/liquidsoap"]
