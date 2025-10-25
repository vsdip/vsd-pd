FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# -------- Base packages --------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core system
    wget curl unzip git make python3 python3-pip \
    # Desktop environment (optional; keep if you want GUI/VNC)
    xvfb xfce4 xfce4-session xfce4-panel xfdesktop4 xfwm4 \
    xfce4-terminal thunar dbus-x11 x11vnc novnc websockify \
    # EDA tools from Ubuntu
    magic ngspice gtkwave verilator iverilog \
    # Build tools
    build-essential cmake ninja-build clang tcl-dev \
    # Flow helpers
    time bc gawk \
    # Tcl/locale/misc
    tcl tcllib tcl-trf tclx tk locales sudo \
    perl libfile-which-perl ca-certificates gnupg lsb-release \
 && rm -rf /var/lib/apt/lists/*

# (Optional) Python libs from Ubuntu (avoid compiling)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-numpy python3-pandas python3-matplotlib python3-jinja2 python3-xlsxwriter && \
    rm -rf /var/lib/apt/lists/*

# -------- OSS CAD Suite (yosys, etc.) --------
RUN set -eux; \
  curl -L https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-10-03/oss-cad-suite-linux-x64-20241003.tgz \
    -o /tmp/oss-cad.tgz; \
  mkdir -p /opt && tar -xzf /tmp/oss-cad.tgz -C /opt; \
  ln -s /opt/oss-cad-suite /opt/oss-cad; \
  rm /tmp/oss-cad.tgz
ENV PATH="/opt/oss-cad/bin:${PATH}"

# -------- KLayout for Ubuntu 22.04 --------
RUN set -eux; \
  curl -L -o /tmp/klayout.deb \
    https://www.klayout.org/downloads/Ubuntu-22/klayout_0.29.0-1_amd64.deb; \
  apt-get update && apt-get install -y --no-install-recommends /tmp/klayout.deb; \
  rm -rf /var/lib/apt/lists/* /tmp/klayout.deb

# -------- OpenROAD prebuilt for Ubuntu 22.04 --------
ARG OPENROAD_DEB_URL="https://github.com/Precision-Innovations/OpenROAD/releases/download/2024-12-14/openroad_2.0-17598-ga008522d8_amd64-ubuntu-22.04.deb"
RUN set -eux; \
  apt-get update && apt-get install -y --no-install-recommends wget; \
  wget -O /tmp/openroad.deb "$OPENROAD_DEB_URL"; \
  apt-get install -y /tmp/openroad.deb; \
  rm -rf /var/lib/apt/lists/* /tmp/openroad.deb
RUN which openroad && openroad -version

# -------- Build slang + yosys-slang (Jammy has CMake>=3.20 and g++-11 by default) --------
# Uses system g++ (11 on 22.04) which supports C++20 <concepts>
RUN set -eux; \
  git clone --depth=1 https://github.com/MikePopoloski/slang /tmp/slang && \
  cmake -S /tmp/slang -B /tmp/slang/build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DSLANG_INCLUDE_TESTS=OFF && \
  cmake --build /tmp/slang/build -j"$(nproc)"

RUN set -eux; \
  git clone --recursive https://github.com/povik/yosys-slang /tmp/yosys-slang && \
  make -C /tmp/yosys-slang \
       YOSYS=/opt/oss-cad-suite/bin/yosys \
       SLANG_DIR=/tmp/slang/build \
       -j"$(nproc)"; \
  cp /tmp/yosys-slang/slang.so /opt/oss-cad-suite/share/yosys/plugins/ && \
  rm -rf /tmp/slang /tmp/yosys-slang

# Verify the plugin (don’t fail the build if just probing)
RUN /opt/oss-cad-suite/bin/yosys -V && \
    /opt/oss-cad-suite/bin/yosys -m slang -p "slang_version" || true

# -------- OpenROAD-flow-scripts (ORFS) --------
RUN git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts /opt/orfs
WORKDIR /opt/orfs

# Wire ORFS to binaries
ENV YOSYS_PLUGIN_PATH="/opt/oss-cad-suite/share/yosys/plugins" \
    OPENROAD_EXE="/usr/bin/openroad" \
    YOSYS_EXE="/opt/oss-cad-suite/bin/yosys" \
    PATH="/opt/oss-cad-suite/bin:${PATH}"

# (Optional) quick self-checks and a tiny flow smoke test
# RUN /opt/oss-cad-suite/bin/yosys -help && \
#     /opt/oss-cad-suite/bin/yosys -m slang -p "slang_version" && \
#     openroad -help && \
#     make DESIGN_CONFIG=./designs/nangate45/gcd/config.mk -C flow -j"$(nproc)" && \
#     make DESIGN_CONFIG=./designs/nangate45/gcd/config.mk gui_final -C flow

# -------- Locale and user --------
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en

RUN useradd -m -s /bin/bash vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER vscode
WORKDIR /home/vscode
RUN mkdir -p /home/vscode/Desktop
