ARG PYTHON_VERSION=3.12.2
ARG BASE_IMAGE=ubuntu
ARG BASE_IMAGE_TAG=jammy
ARG LLVM_VERSION=18
ARG PYTHON_BUILD_DIR=/tmp/python-build


FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG} AS base_image
FROM base_image AS builder

# set apt to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# update ubuntu and install basic dependenciess
RUN set -eux; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
    build-essential checkinstall software-properties-common gnupg wget ca-certificates pkg-config

# download python source
ARG PYTHON_VERSION
ARG PYTHON_BUILD_DIR
RUN set -eux; \
    PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tgz"; \
    wget -qO - "${PYTHON_URL}" | tar -xz -C /tmp; \
    mv "/tmp/Python-${PYTHON_VERSION}" "$PYTHON_BUILD_DIR"

# install llvm
ARG LLVM_VERSION
RUN set -eux; \
    wget -qO - https://apt.llvm.org/llvm.sh | bash -s "${LLVM_VERSION}" all

# run build-dep for python
RUN set -eux; \
    sed -i -- "s/#deb-src/deb-src/g" /etc/apt/sources.list; \
    sed -i -- "s/# deb-src/deb-src/g" /etc/apt/sources.list; \
    apt-get update; \
    apt-get build-dep -y python3

# install additional header libraries
RUN set -eux; \
    apt-get install -y --no-install-recommends \
    libffi-dev zlib1g-dev libsqlite3-dev libssl-dev

# configure python
RUN set -eux; \
    cd "$PYTHON_BUILD_DIR"; \
    ./configure \
    CC="$(which "clang-$LLVM_VERSION")" \
    CXX="$(which "clang++-$LLVM_VERSION")" \
    LLVM_PROFDATA="$(which "llvm-profdata-$LLVM_VERSION")" \
    LLVM_AR="$(which "llvm-ar-$LLVM_VERSION")" \
    CFLAGS="-Wno-unused-value -Wno-empty-body -Qunused-arguments -Wno-parentheses-equality" \
    --enable-loadable-sqlite-extensions \
    --with-computed-gotos \
    --enable-optimizations \
    --with-lto \
    --without-ensurepip \
    --without-doc-strings \
    --prefix=/usr/local

# compile python
RUN set -eux; \
    cd "$PYTHON_BUILD_DIR"; \
    make -s -j "$(nproc)"

# build package
RUN set -eux; \
    cd "$PYTHON_BUILD_DIR"; \
    checkinstall --default --install=no --fstrans=no --nodoc --pkgname=python --pkgversion="$PYTHON_VERSION"; \
    mv python_3*.deb python-pkg.deb


FROM base_image AS intermediate

# stops python stdout/stderr from being buffered
ENV PYTHONUNBUFFERED=1

# copy over python build
ARG PYTHON_BUILD_DIR
COPY --from=builder "$PYTHON_BUILD_DIR/python-pkg.deb" "$PYTHON_BUILD_DIR/python-pkg.deb"

# run everything in one layer to reduce final image size
RUN set -eux; \
    cd "$PYTHON_BUILD_DIR"; \
    # update ubuntu
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get upgrade -y; \
    # install dependencies
    DEBIAN_FRONTEND="noninteractive" \
    apt-get install -y --no-install-recommends \
    wget ca-certificates libffi-dev zlib1g-dev libsqlite3-dev libssl-dev; \
    # install python build
    dpkg -i python-pkg.deb; \
    ln -s "/usr/local/bin/python3" "/usr/local/bin/python"; \
    # install pip, update setuptools and wheel
    export PYTHONDONTWRITEBYTECODE=1; \
    wget -qO - https://bootstrap.pypa.io/get-pip.py | python; \
    pip install --no-cache-dir --no-compile --upgrade pip setuptools wheel; \
    # clean up
    apt-get clean -y; \
    apt-get autoclean -y; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/cache/*; \
    rm -rf /var/log/*; \
    rm -rf /root/.cache/*; \
    rm -rf /tmp/*


FROM intermediate AS final
