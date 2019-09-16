FROM jenkins/jenkins:2.176.3

USER root

# Update System
RUN apt -y update && apt -y upgrade

# # Install pre-requisites
RUN apt -y install \
  apt-utils \
  gcc \
  make \
  cmake \
  git \
  btrfs-progs \
  # golang-go \
  go-md2man \
  iptables \
  libassuan-dev \
  libc6-dev \
  libdevmapper-dev \
  libglib2.0-dev \
  libgpgme-dev \
  libgpg-error-dev \
  libostree-dev \
  libprotobuf-dev \
  libprotobuf-c-dev \
  libseccomp-dev \
  libselinux1-dev \
  libsystemd-dev \
  pkg-config \
  runc \
  uidmap \
  libapparmor-dev

# Install go
RUN ["/bin/bash", "-c", "curl https://storage.googleapis.com/golang/go1.10.linux-amd64.tar.gz -o go1.10.linux-amd64.tar.gz && \
    tar -xvf go1.10.linux-amd64.tar.gz && \
    chown -R root:root ./go && \
    mv go /usr/local"]

# RUN echo 'export GOPATH=/root/go' >> ~/.bashrc && \
#     echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.bashrc

# RUN ["/bin/bash", "-c", "cat ~/.bashrc"]
# RUN ["/bin/bash", "-c", "source ~/.bashrc"]
RUN ["/bin/bash", "-c", "ln -s /usr/local/go/bin/go /usr/bin/go"]
# RUN ["/bin/bash", "-c", "go version"]
# RUN ["/bin/bash", "-c", "go env"]

# Install conmon
RUN git clone https://github.com/containers/conmon && \
    cd conmon && \
    make && \
    make podman && \
    cp /usr/local/libexec/podman/conmon  /usr/local/bin/

# Install CNI plugins
RUN git clone https://github.com/containernetworking/plugins.git $GOPATH/src/github.com/containernetworking/plugins && \
	cd $GOPATH/src/github.com/containernetworking/plugins && \
	./build_linux.sh && \
	mkdir -p /usr/libexec/cni && \
	cp bin/* /usr/libexec/cni

#Setup CNI networking
RUN mkdir -p /etc/cni/net.d && \
	curl -qsSL https://raw.githubusercontent.com/containers/libpod/master/cni/87-podman-bridge.conflist | tee /etc/cni/net.d/99-loopback.conf

# Populate configuration files
RUN mkdir -p /etc/containers && \
	curl https://raw.githubusercontent.com/projectatomic/registries/master/registries.fedora -o /etc/containers/registries.conf && \
	curl https://raw.githubusercontent.com/containers/skopeo/master/default-policy.json -o /etc/containers/policy.json


# Install Podman
RUN git clone https://github.com/containers/libpod/ $GOPATH/src/github.com/containers/libpod && \
	cd $GOPATH/src/github.com/containers/libpod && \
	make && \
	make install

RUN podman version && podman info
# RUN alias docker=podman
# RUN docker version && docker info