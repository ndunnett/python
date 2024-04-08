ARG BASE_IMAGE=ubuntu
ARG BASE_IMAGE_TAG=jammy
ARG PYTHON_VERSION=3.12.2
ARG PYTHON_PREFIX=/usr/local


FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG} AS builder
ARG PYTHON_VERSION
ARG PYTHON_PREFIX

# stops python stdout/stderr from being buffered
ENV PYTHONUNBUFFERED=1

# add to path
ENV PATH="$PYTHON_PREFIX/bin:$PATH"

RUN set -eux; \
    # install dependencies
    apt-get update; \
    DEBIAN_FRONTEND="noninteractive" \
    apt-get install -y --no-install-recommends \
    gcc gdb make wget ca-certificates \
    libffi-dev zlib1g-dev libsqlite3-dev libssl-dev \
    libbz2-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev lzma-dev tk-dev uuid-dev; \
    # download python source
    PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tgz"; \
    wget -qO - "${PYTHON_URL}" | tar -xz -C /tmp; \
    cd "/tmp/Python-${PYTHON_VERSION}"; \
    # configure python
    LDFLAGS="-Wl,-rpath=$PYTHON_PREFIX/lib" \
    ./configure \
    --enable-loadable-sqlite-extensions \
    --with-computed-gotos \
    --enable-optimizations \
    --with-lto \
    --without-ensurepip \
    --without-doc-strings \
    --enable-option-checking=fatal \
    --enable-shared \
    --prefix="$PYTHON_PREFIX"; \
    # compile and install python
    make -s -j "$(nproc)"; \
    make install; \
    for ex in idle3 pydoc3 python3 python3-config; do \
        src="$PYTHON_PREFIX/bin/$ex"; \
        dst="$(echo "$src" | tr -d 3)"; \
        [ -s "$src" ] && [ ! -e "$dst" ] && ln -svT "$src" "$dst"; \
    done; \
    # install pip
    wget -q https://bootstrap.pypa.io/get-pip.py; \
    PYTHONDONTWRITEBYTECODE=1; \
    python get-pip.py --no-cache-dir --no-compile; \
    # cleanup
    apt-get purge -y wget \
    libffi-dev zlib1g-dev libsqlite3-dev libssl-dev \
    libbz2-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev lzma-dev tk-dev uuid-dev; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/cache/*; \
    rm -rf /var/log/*; \
    rm -rf /root/.cache/*; \
    rm -rf /tmp/*

# entrypoint
CMD ["python"]


FROM builder AS non_root

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

# entrypoint
CMD ["sleep", "infinity"]


FROM builder AS final
