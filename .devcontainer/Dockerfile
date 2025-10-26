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

# -------- OpenROAD (build from source) --------
# Pin to a ref for reproducibility if you like:
#   --build-arg OPENROAD_REF=<tag|commit|branch>

#ARG OPENROAD_REF=master
#RUN set -eux; \
#  git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD /opt/openroad; \
#  cd /opt/openroad; \
#  git checkout "${OPENROAD_REF}"; \
#  # Ensure submodules match the chosen ref
#  git submodule update --init --recursive; \
#  \
#  # Install deps (script uses apt; we're root in Docker)
#  ./etc/DependencyInstaller.sh -all; \
#  \
#  # Build (Release by default). Add -j to speed up.
#  ./etc/Build.sh -no-warnings; \
#  \
#  # Normalize binary location and make a stable path
#  mkdir -p /opt/openroad/build/bin; \
#  if [ ! -x /opt/openroad/build/bin/openroad ] && [ -x /opt/openroad/build/OpenROAD/src/openroad ]; then \
#      ln -sf /opt/openroad/build/OpenROAD/src/openroad /opt/openroad/build/bin/openroad; \
#  fi; \
#  /opt/openroad/build/bin/openroad -version
#ENV OPENROAD_EXE="/opt/openroad/build/bin/openroad"
#ENV PATH="/opt/openroad/build/bin:${PATH}" 

# -------- Build slang + yosys-slang (Jammy has CMake>=3.20 and g++-11) --------
#RUN set -eux; \
#  git clone --depth=1 https://github.com/MikePopoloski/slang /tmp/slang && \
#  cmake -S /tmp/slang -B /tmp/slang/build -G Ninja \
#        -DCMAKE_BUILD_TYPE=Release \
#        -DSLANG_INCLUDE_TESTS=OFF && \
#  cmake --build /tmp/slang/build -j"$(nproc)"

# Build yosys-slang plugin (against OSS-CAD-Suite Yosys + the Slang you built)
#RUN set -eux; \
#  git clone --recursive https://github.com/povik/yosys-slang /tmp/yosys-slang && \
#  make -C /tmp/yosys-slang \
#      YOSYS=/opt/oss-cad-suite/bin/yosys \
#      SLANG_DIR=/tmp/slang/build \
#      -j"$(nproc)"; \
#  install -Dm755 /tmp/yosys-slang/build/slang.so /opt/oss-cad-suite/share/yosys/plugins/slang.so && \
#  rm -rf /tmp/yosys-slang
#ENV YOSYS_PLUGIN_PATH="/opt/oss-cad-suite/share/yosys/plugins"
#RUN /opt/oss-cad-suite/bin/yosys -m slang -p "slang_version" || true

# Wire ORFS to binaries (use the source-built OpenROAD)
#ENV YOSYS_PLUGIN_PATH="/opt/oss-cad-suite/share/yosys/plugins" \
#    OPENROAD_EXE="/opt/openroad/build/bin/openroad" \
#    YOSYS_EXE="/opt/oss-cad-suite/bin/yosys" \
#    PATH="/opt/oss-cad-suite/bin:/opt/openroad/build/bin:${PATH}"

# copy your start script into the image

COPY start-desktop.sh /usr/local/bin/start-desktop.sh
RUN chmod +x /usr/local/bin/start-desktop.sh


# -------- Locale and user --------
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en

RUN useradd -m -s /bin/bash vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER vscode
WORKDIR /home/vscode
RUN mkdir -p /home/vscode/Desktop
