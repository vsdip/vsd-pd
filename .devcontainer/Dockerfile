
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1


# Create vscode user that Codespaces expects
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd --gid ${USER_GID} ${USERNAME} \
  && useradd -m -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} ${USERNAME} \
  && apt-get update && apt-get install -y --no-install-recommends sudo \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

# Base packages (your original set)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl unzip git make python3 python3-pip python3-numpy python3-pandas python3-matplotlib python3-jinja2 python3-xlsxwriter \
    xvfb xfce4 xfce4-session xfce4-panel xfdesktop4 xfwm4 xfce4-terminal thunar dbus-x11 x11vnc novnc websockify supervisor \
    magic ngspice gtkwave verilator iverilog \
    build-essential autoconf automake libtool m4 cmake ninja-build clang \
    tcl tcl-dev tcllib tcl-trf tclx tk tk-dev locales sudo \
    perl libfile-which-perl ca-certificates gnupg lsb-release pkg-config \
    libcairo2-dev libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev \
    libx11-dev libxext-dev libxrender-dev libxpm-dev libxaw7-dev libfontconfig1-dev \
    libreadline-dev libncurses-dev flex bison gawk tcsh time bc vim \
    libqt5charts5 libyaml-cpp0.7 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# OSS CAD Suite (Yosys, etc.)
RUN set -eux; \
  curl -L https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-10-03/oss-cad-suite-linux-x64-20241003.tgz; \
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

# -------- OpenROAD from your custom .deb --------
ARG OPENROAD_DEB_URL="https://vsd-labs.sgp1.cdn.digitaloceanspaces.com/vsd-labs/openroad_2.0+custom+20251027_amd64.deb"
RUN set -eux; \
  apt-get update && apt-get install -y --no-install-recommends wget ca-certificates; \
  wget -O /tmp/openroad.deb "$OPENROAD_DEB_URL"; \
  apt-get install -y /tmp/openroad.deb || { \
    # if dependencies are missing, fetch them
    apt-get -f install -y; \
  }; \
  rm -rf /var/lib/apt/lists/* /tmp/openroad.deb

# Ensure OpenROAD is on PATH and wire env
RUN set -eux; \
  install -d /usr/local/bin; \
  ln -sf /opt/openroad/bin/openroad /usr/local/bin/openroad; \
  chmod +x /opt/openroad/bin/openroad || true; \
  command -v openroad; \
  openroad -version || true

ENV OPENROAD_EXE="/opt/openroad/bin/openroad"


ENV PATH="/usr/local/bin:${PATH}"

# (Optional) slang + yosys-slang plugin
#RUN set -eux; \
#  git clone --depth=1 https://github.com/MikePopoloski/slang /tmp/slang && \
#  cmake -S /tmp/slang -B /tmp/slang/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DSLANG_INCLUDE_TESTS=OFF && \
#  cmake --build /tmp/slang/build -j"$(nproc)"
#RUN set -eux; \
#  git clone --recursive https://github.com/povik/yosys-slang /tmp/yosys-slang && \
#  make -C /tmp/yosys-slang YOSYS=/opt/oss-cad-suite/bin/yosys SLANG_DIR=/tmp/slang/build -j"$(nproc)"; \
#  install -Dm755 /tmp/yosys-slang/build/slang.so /opt/oss-cad-suite/share/yosys/plugins/slang.so && \
#  rm -rf /tmp/yosys-slang
#ENV YOSYS_PLUGIN_PATH="/opt/oss-cad-suite/share/yosys/plugins"
#RUN /opt/oss-cad-suite/bin/yosys -m slang -p "slang_version" || true

# OpenROAD-flow-scripts
#RUN git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts /opt/orfs
#WORKDIR /opt/orfs
ENV YOSYS_PLUGIN_PATH="/opt/oss-cad-suite/share/yosys/plugins" \
    YOSYS_EXE="/opt/oss-cad-suite/bin/yosys" \
    PATH="/opt/oss-cad-suite/bin:/usr/local/bin:${PATH}"

# -----------------------------
# noVNC desktop environment
# -----------------------------
COPY supervisord.conf /etc/supervisor/conf.d/vnc.conf
EXPOSE 6080
CMD ["/usr/bin/supervisord", "-n"]


