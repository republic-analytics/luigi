FROM ghcr.io/astral-sh/uv:debian-slim

# install system packages
#   - ca-certificates - download from pypi.org/simple/tornado
#   - clang - building specific python dependencies which don't have pre-built wheels (e.g. psutil)
#   - docker.io - execute docker commands (e.g. azureblob tests); prefer to mount host's docker socket so that sibling containers are created instead of child containers
RUN apt update -y && \
    apt install -y \
        ca-certificates \
        clang \
        docker.io \
    && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

# install python version, default to 3.12
ARG PYTHON_VERSION=3.12
RUN uv python install "${PYTHON_VERSION}"

# install test dependencies (tox)
RUN uv venv && \
    uv pip install --no-cache-dir \
        setuptools \
        "tox<4.0"

# install luigi
WORKDIR /app
COPY bin ./bin
COPY luigi ./luigi
COPY README.rst setup.py .
RUN uv run python setup.py install

# copy tests and config
COPY .coveragerc tox.ini .
COPY doc ./doc
COPY scripts ./scripts
COPY test ./test

# entrypoint
ENTRYPOINT ["uv", "run"]
CMD ["tox", "-e", "flake8"]
