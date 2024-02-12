ARG PYTHON_VERSION=3.12.2
ARG UBUNTU_TAG=jammy
ARG LLVM_VERSION=18

FROM ubuntu:${UBUNTU_TAG} AS builder

# update and install dependencies
ARG LLVM_VERSION
RUN set -eux; \
    DEBIAN_FRONTEND="noninteractive"; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install build-essential zlib1g-dev libssl-dev software-properties-common gnupg wget ca-certificates -y --no-install-recommends; \
    wget -qO - https://apt.llvm.org/llvm.sh | bash -s "${LLVM_VERSION}" all

# download python source
ARG PYTHON_VERSION
RUN set -eux; \
    cd /tmp; \
    PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tgz"; \
    wget -qO - "${PYTHON_URL}" | tar -xz; \
    mv "/tmp/Python-${PYTHON_VERSION}" /tmp/python-source

# configure and build python
RUN set -eux; \
    cd /tmp/python-source; \
    ./configure \
        CC="$(which "clang-$LLVM_VERSION")" \
        CXX="$(which "clang++-$LLVM_VERSION")" \
        LLVM_PROFDATA="$(which "llvm-profdata-$LLVM_VERSION")" \
        LLVM_AR="$(which "llvm-ar-$LLVM_VERSION")" \
        --enable-loadable-sqlite-extensions \
        --with-computed-gotos \
        --enable-optimizations \
        --with-lto \
		--without-ensurepip \
        --prefix=/usr/local; \
	make -j "$(nproc)"


FROM ubuntu:${UBUNTU_TAG} AS final

# stops python stdout/stderr from being buffered
ENV PYTHONUNBUFFERED=1

# update packages
RUN set -eux; \
    DEBIAN_FRONTEND="noninteractive"; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install make wget ca-certificates -y --no-install-recommends

# install python
COPY --from=builder /tmp/python-source /tmp/python-source
RUN set -eux; \
    cd /tmp/python-source; \
    make install; \
    ln -s "/usr/local/bin/python3" "/usr/local/bin/python"; \
	python --version

# install pip, update setuptools and wheel
RUN set -eux; \
    export PYTHONDONTWRITEBYTECODE=1; \
    wget -qO - https://bootstrap.pypa.io/get-pip.py | python; \
    pip install --no-cache-dir --no-compile --upgrade pip setuptools wheel; \
    pip --version

# clean up
RUN set -eux; \
    apt-get purge make wget ca-certificates -y; \
    apt-get clean -y; \
    apt-get autoclean -y; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/cache/*; \
    rm -rf /var/log/*; \
    rm -rf /root/.cache/*; \
    rm -rf /tmp/python-source
