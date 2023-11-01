# -march=native -mssse3 -mcx16 -msse4.1 -msse4.2 -mpopcnt -mno-avx

FROM python:3.8
ARG TENSORFLOW_SRC="https://github.com/tensorflow/tensorflow.git"
ARG BAZELISK_PACKAGE="https://github.com/bazelbuild/bazelisk/releases/download/v1.18.0/bazelisk-linux-amd64"

SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git wget libssl-dev patchelf libgl1 python3-dev python3-pip python3-venv clang llvm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/bin
RUN wget -O bazelisk $BAZELISK_PACKAGE && chmod +x bazelisk

WORKDIR /usr/local/src/tensorflow
RUN git clone $TENSORFLOW_SRC source

WORKDIR /usr/local/src/tensorflow/source
RUN git checkout v2.13.1
RUN python3.8 -m venv ./venv
RUN source ./venv/bin/activate
RUN pip install -U pip numpy wheel packaging requests opt_einsum && \
    pip install -U keras_preprocessing --no-deps

# enter in a bash session:                      docker run -it --name tensorflow tensorflow-build:initial bash
# in /usr/local/src/tensorflow/source, run:     source ./venv/bin/activate
# run:                                          python3.8 ./configure.py
# and insert the following flags:               -march=native -mssse3 -mcx16 -msse4.1 -msse4.2 -mpopcnt -mno-avx
# run:                                          bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package