# ---------- Builder: build OpenROAD from source ----------
FROM ubuntu:22.04 AS openroad-builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates build-essential cmake ninja-build tcl tcl-dev \
    python3 python3-pip clang pkg-config libx11-dev libxext-dev libxrender-dev \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /opt

# Clone OpenROAD
ARG OPENROAD_REF=master
RUN git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD && \
    cd OpenROAD && git checkout "${OPENROAD_REF}" && git submodule update --init --recursive

# Install deps using project script (noninteractive)
WORKDIR /opt/OpenROAD
RUN ./etc/DependencyInstaller.sh -all

# Build (Release by default)
RUN ./etc/Build.sh -no-warnings

# Normalize path (some builds drop the binary elsewhere)
RUN mkdir -p /opt/openroad-artifacts/bin && \
    if [ -x build/bin/openroad ]; then cp -a build/bin/openroad /opt/openroad-artifacts/bin/; \
    elif [ -x build/OpenROAD/src/openroad ]; then cp -a build/OpenROAD/src/openroad /opt/openroad-artifacts/bin/; \
    else echo "OpenROAD binary not found" && exit 1; fi

# ---------- Final image: tools + slim OpenROAD binary ----------
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Base packages (your original set)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl unzip git make python3 python3-pip \
    xvfb xfce4 xfce4-session xfce4-panel xfdesktop4 xfwm4 \
    xfce4-terminal thunar dbus-x11 x11vnc novnc websockify \
    magic ngspice gtkwave verilator iverilog \
    build-essential cmake ninja-build clang tcl-dev \
    time bc gawk \
    tcl tcllib tcl-trf tclx tk locales sudo \
    perl libfile-which-perl ca-certificates gnupg lsb-release \
    python3-numpy python3-pandas python3-matplotlib python3-jinja2 python3-xlsxwriter \
    && rm -rf /var/lib/apt/lists/*

# OSS CAD Suite (Yosys, etc.)
RUN set -eux; \
  curl -L https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-10-03/oss-cad-suite-linux-x64-20241003.tgz \
    -o /tmp/oss-cad.tgz; \
  mkdir -p /opt && tar -xzf /tmp/oss-cad.tgz -C /opt; \
  ln -s /opt/oss-cad-suite /opt/oss-cad; \
  rm /tmp/oss-cad.tgz
ENV PATH="/opt/oss-cad/bin:${PATH}"

# KLayout (optional)
RUN set -eux; \
  curl -L -o /tmp/klayout.deb \
    https://www.klayout.org/downloads/Ubuntu-22/klayout_0.29.0-1_amd64.deb; \
  apt-get update && apt-get install -y --no-install-recommends /tmp/klayout.deb; \
  rm -rf /var/lib/apt/lists/* /tmp/klayout.deb

# Copy the built OpenROAD binary only (keeps image tiny)
COPY --from=openroad-builder /opt/openroad-artifacts/bin/openroad /usr/local/bin/openroad
RUN /usr/local/bin/openroad -version || true
ENV OPENROAD_EXE="/usr/local/bin/openroad"
ENV PATH="/usr/local/bin:${PATH}"

# (Optional) slang + yosys-slang plugin
RUN set -eux; \
  git clone --depth=1 https://github.com/MikePopoloski/slang /tmp/slang && \
  cmake -S /tmp/slang -B /tmp/slang/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DSLANG_INCLUDE_TESTS=OFF && \
  cmake --build /tmp/slang/build -j"$(nproc)"
RUN set -eux; \
  git clone --recursive https://github.com/povik/yosys-slang /tmp/yosys-slang && \
  make -C /tmp/yosys-slang YOSYS=/opt/oss-cad-suite/bin/yosys SLANG_DIR=/tmp/slang/build -j"$(nproc)"; \
  install -Dm755 /tmp/yosys-slang/build/slang.so /opt/oss-cad-suite/share/yosys/plugins/slang.so && \
  rm -rf /tmp/yosys-slang
ENV YOSYS_PLUGIN_PATH="/opt/oss-cad-suite/share/yosys/plugins"
RUN /opt/oss-cad-suite/bin/yosys -m slang -p "slang_version" || true

# OpenROAD-flow-scripts
#RUN git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts /opt/orfs
#WORKDIR /opt/orfs
ENV YOSYS_PLUGIN_PATH="/opt/oss-cad-suite/share/yosys/plugins" \
    YOSYS_EXE="/opt/oss-cad-suite/bin/yosys" \
    OPENROAD_EXE="/usr/local/bin/openroad" \
    PATH="/opt/oss-cad-suite/bin:/usr/local/bin:${PATH}"

# noVNC desktop starter (the resilient script you now use)
COPY .devcontainer/start-desktop.sh /usr/local/bin/start-desktop.sh
RUN chmod +x /usr/local/bin/start-desktop.sh

# Locale + user
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en
RUN useradd -m -s /bin/bash vscode && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER vscode
WORKDIR /home/vscode
RUN mkdir -p /home/vscode/Desktop
