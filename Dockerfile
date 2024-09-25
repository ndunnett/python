ARG BASE_IMAGE
ARG BASE_IMAGE_TAG
ARG PYTHON_VERSION
ARG PYTHON_PREFIX=/usr/local
ARG DEBIAN_FRONTEND=noninteractive
ARG PYTHONDONTWRITEBYTECODE=1


FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG} AS base
ARG DEBIAN_FRONTEND

RUN set -eux; \
    # delete default user on new ubuntu images
    grep ubuntu /etc/passwd && \
    touch /var/mail/ubuntu && \
    chown ubuntu /var/mail/ubuntu && \
    userdel -r ubuntu; \
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
ENV LANG=C.UTF-8


FROM base AS builder
ARG PYTHON_PREFIX
ARG PYTHON_VERSION
ARG DEBIAN_FRONTEND
ARG PYTHONDONTWRITEBYTECODE

# install dependencies
RUN set -eux; \
    apt update; \
    apt install -y wget rdfind gnupg \
        libffi-dev zlib1g-dev libsqlite3-dev libssl-dev libnsl-dev \
        libbz2-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
        libncurses5-dev libreadline6-dev lzma-dev tk-dev uuid-dev

# download and verify python source
RUN set -eux; \
    mkdir -p /tmp/python /root/.gnupg && cd /tmp/python; \
    PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}"; \
    TARBALL="Python-$PYTHON_VERSION.tgz"; \
    # GPG public keys for Pablo Galindo Salgado and Thomas Wouters (release managers for 3.10+)
    gpg --receive-keys 7169605F62C751356D054A26A821E680E5FA6305; \
    gpg --receive-keys A035C8C19219BA821ECEA86B64E628F8D684696D; \
    wget -q "$PYTHON_URL/$TARBALL"; \
    wget -qO - "$PYTHON_URL/$TARBALL.asc" | gpg --verify - "$TARBALL"; \
	tar -xz -C /tmp/python -f "$TARBALL" --strip-components=1

# configure python
RUN set -eux; \
    cd /tmp/python; \
    ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
        --build="$ARCH" \
        --enable-loadable-sqlite-extensions \
        --enable-optimizations \
        --with-computed-gotos \
        --with-lto=full \
        --with-ensurepip=upgrade \
        --prefix="$PYTHON_PREFIX"

# compile and install python
RUN set -eux; \
    cd /tmp/python; \
    EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; \
    LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
    make -j "$(nproc)" \
        "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" \
        "LDFLAGS=${LDFLAGS:-}"; \
    make install

# remove __pycache__ directories and redundant files from build
RUN set -eux; \
    rdfind -makehardlinks true -makeresultsfile false "$PYTHON_PREFIX"; \
    find "$PYTHON_PREFIX" -type d -name __pycache__ -prune -exec rm -rf {} +

# make symlinks for python
RUN set -eux; \
    for ex in idle3 pip3 pydoc3 python3 python3-config; do \
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


FROM built AS dev
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
    mkdir -p "/home/$USERNAME/repo"; \
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME" "/home/$USERNAME/repo"
WORKDIR "/home/$USERNAME/repo"
USER "$USERNAME"

# install python modules
RUN set -eux; \
    python -m pip install requests pyperformance

# entrypoint
CMD ["sleep", "infinity"]


FROM built AS final
