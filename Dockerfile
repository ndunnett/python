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
    software-properties-common gnupg wget ca-certificates \
    build-essential checkinstall pkg-config gdb lcov pkg-config lzma

# download python source
ARG PYTHON_VERSION
ARG PYTHON_BUILD_DIR
RUN set -eux; \
    PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tgz"; \
    wget -qO - "${PYTHON_URL}" | tar -xz -C /tmp; \
    mv "/tmp/Python-${PYTHON_VERSION}" "$PYTHON_BUILD_DIR"

# run build-dep for python
RUN set -eux; \
    sed -i -- "s/#deb-src/deb-src/g" /etc/apt/sources.list; \
    sed -i -- "s/# deb-src/deb-src/g" /etc/apt/sources.list; \
    apt-get update; \
    apt-get build-dep -y python3

# install additional header libraries
RUN set -eux; \
    apt-get install -y --no-install-recommends \
    libffi-dev zlib1g-dev libsqlite3-dev libssl-dev \
    libbz2-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev lzma-dev tk-dev uuid-dev

# configure python
RUN set -eux; \
    cd "$PYTHON_BUILD_DIR"; \
    ./configure \
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
    wget ca-certificates libffi-dev zlib1g-dev libsqlite3-dev libssl-dev \
    libbz2-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev lzma-dev tk-dev uuid-dev; \
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


FROM intermediate AS non_root

# install basic tools
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND="noninteractive" \
    apt-get install -y --no-install-recommends wget zsh git; \
    rm -rf /var/lib/apt/lists/*

# create user
ARG USERNAME=dev
RUN set -eux; \
    useradd --create-home --user-group --no-log-init "$USERNAME"; \
    mkdir -p "/home/$USERNAME"; \
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
WORKDIR "/home/$USERNAME"
USER "$USERNAME"
ENV PATH="/home/$USERNAME/.local/bin:$PATH"

# entrypoint
CMD ["sleep", "infinity"]

FROM intermediate AS final
