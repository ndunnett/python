ARG BASE_IMAGE
ARG BASE_IMAGE_TAG
ARG PYTHON_VERSION
ARG PYTHON_PREFIX=/usr/local
ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHONDONTWRITEBYTECODE=1


FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG} AS base
ARG DEBIAN_FRONTEND

RUN set -eux; \
    # update base image
    apt update; \
    apt full-upgrade -y; \
    # install common dependencies
    apt install -y --no-install-recommends \
    build-essential ca-certificates sqlite3 rdfind; \
    # find and remove redundant files
    rdfind -makehardlinks true -makeresultsfile false \
    /etc /usr /var; \
    # set default compilers
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 100; \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 100; \
    # clean up
    apt remove -y rdfind; \
    apt autoremove -y; \
    apt clean; \
    rm -rf /root; \
    rm -rf /var/cache/*; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/lib/dpkg/status-old; \
    rm -rf /var/log/*

ENV PATH="$PYTHON_PREFIX/bin:$PATH"


FROM base AS builder
ARG PYTHON_PREFIX
ARG PYTHON_VERSION
ARG DEBIAN_FRONTEND
ARG PYTHONDONTWRITEBYTECODE

# install dependencies
RUN set -eux; \
    apt update; \
    apt install -y wget rdfind \
    libffi-dev zlib1g-dev libsqlite3-dev libssl-dev \
    libbz2-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev lzma-dev tk-dev uuid-dev

# download python source
RUN set -eux; \
    PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tgz"; \
    wget -qO - "$PYTHON_URL" | tar -xz -C /tmp

# configure python
RUN set -eux; \
    cd "/tmp/Python-$PYTHON_VERSION"; \
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
    --prefix="$PYTHON_PREFIX"

# compile and install python
RUN set -eux; \
    cd "/tmp/Python-$PYTHON_VERSION"; \
    make -s -j "$(nproc)"; \
    make install

# install pip
RUN set -eux; \
    wget -qO - https://bootstrap.pypa.io/get-pip.py | python3

# remove __pycache__ directories and redundant files from build
RUN set -eux; \
    rdfind -makehardlinks true -makeresultsfile false "$PYTHON_PREFIX"; \
    find "$PYTHON_PREFIX" -type d -name __pycache__ -prune -exec rm -rf {} \;

# make symlinks for python
RUN set -eux; \
    for ex in idle3 pydoc3 python3 python3-config; do \
    src="$PYTHON_PREFIX/bin/$ex"; dst="$(echo "$src" | tr -d 3)"; \
    [ -s "$src" ] && [ ! -e "$dst" ] && ln -svT "$src" "$dst"; done


FROM base AS built
ARG PYTHON_PREFIX

# stops python stdout/stderr from being buffered
ENV PYTHONUNBUFFERED=1

# copy python build
COPY --from=builder "$PYTHON_PREFIX" "$PYTHON_PREFIX"

# entrypoint
CMD ["python"]


FROM built AS non_root
ARG DEBIAN_FRONTEND

# install basic tools
RUN set -eux; \
    apt-get update; \
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


FROM built AS final
