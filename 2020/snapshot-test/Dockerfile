FROM ubuntu:18.04
RUN apt-get update -q
RUN apt-get install --no-install-recommends -q -y build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev bison- autoconf- ruby-
#ADD https://cache.ruby-lang.org/pub/ruby/snapshot/snapshot-master.tar.xz .
RUN useradd -m -s /bin/bash runner
WORKDIR /home/runner
COPY --chown=runner snapshot-master.tar.xz /home/runner
USER runner
RUN tar xf snapshot-master.tar.xz
RUN cd snapshot-* && ./configure && make -j$(nproc)
