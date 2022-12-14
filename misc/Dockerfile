# If you modify this file, make sure to update the BUILD_IMAGE variable in .gitlab-ci.yml.

FROM debian:buster-slim

USER root

# install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -yq && \
    apt-get upgrade -yq --with-new-pkgs --auto-remove && \
    apt-get install -yq --no-install-recommends autoconf build-essential ca-certificates git graphviz g++ libgmp-dev ocaml-nox unzip wget && \
    apt-get clean

RUN wget --quiet https://github.com/ocaml/opam/releases/download/2.0.6/opam-2.0.6-x86_64-linux -O /usr/local/bin/opam && \
    chmod a+x /usr/local/bin/opam

# create user
RUN adduser --disabled-password --gecos '' user
USER user
ENV HOME /home/user
WORKDIR /home/user

# install opam
ENV OPAM_PACKAGES="conf-autoconf conf-g++"
RUN opam init -y --no-setup -j4 --bare --disable-sandboxing && \
    opam switch create minimal ocaml-system && \
    opam switch create latest  ocaml-system && \
    opam install -y --switch=minimal $OPAM_PACKAGES coq.8.12.2 && \
    opam install -y --switch=latest  $OPAM_PACKAGES coq.8.15.1 && \
    opam clean -a -c -r -s --logs
