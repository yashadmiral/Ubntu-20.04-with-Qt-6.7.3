FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ARG QT_VERSION=6.7.3
ARG QT_SRC_URL=https://download.qt.io/archive/qt/6.7/6.7.3/single/qt-everywhere-src-6.7.3.tar.xz
ENV QTDIR=/opt/Qt/${QT_VERSION}
ENV PATH=${QTDIR}/bin:${PATH}
ENV LD_LIBRARY_PATH=${QTDIR}/lib:$LD_LIBRARY_PATH

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential cmake ninja-build git python3 python3-pip \
    libgl1-mesa-dev libxkbcommon-x11-0 libxcb-icccm4 libxcb-image0 \
    libxcb-keysyms1 libxcb-render-util0 libxcb-shape0 libxcb-sync1 \
    libxcb-xfixes0 libxcb-xinerama0 libxcb-randr0 libx11-xcb1 libxi6 \
    wget xz-utils && \
    rm -rf /var/lib/apt/lists/*

# Download Qt source
RUN wget ${QT_SRC_URL} -O /tmp/qt-src.tar.xz && \
    mkdir -p /tmp/qt-src && \
    tar -xf /tmp/qt-src.tar.xz -C /tmp/qt-src --strip-components=1

# Build and install Qt
WORKDIR /tmp/qt-src

# Create build directory
RUN mkdir build

# Configure the Qt build
WORKDIR /tmp/qt-src/build

# Configure Qt for dynamic/shared build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=${QTDIR} -DBUILD_SHARED_LIBS=ON -DQT_FEATURE_core=ON -DQT_FEATURE_network=ON -DQT_FEATURE_serialport=ON -DQT_FEATURE_concurrent=ON -DQT_FEATURE_gui=OFF -DQT_FEATURE_widgets=OFF -DQT_FEATURE_qml=OFF -DQT_FEATURE_qtcharts=OFF -DQT_FEATURE_qt3d=OFF -DQT_FEATURE_qtmultimedia=OFF -DQT_FEATURE_qtquick3d=OFF -DQT_FEATURE_qtsvg=OFF -DQT_FEATURE_qtwebengine=OFF -DQT_FEATURE_qtwebsockets=OFF -DQT_FEATURE_qtwayland=OFF -DQT_FEATURE_qttools=OFF -DQT_FEATURE_qttranslations=OFF -DQT_FEATURE_qtvirtualkeyboard=OFF -DQT_FEATURE_qtwinextras=OFF -DQT_FEATURE_qtxmlpatterns=OFF -DQT_FEATURE_qtdeclarative=OFF -DQT_FEATURE_tests=OFF -DQT_FEATURE_examples=OFF
RUN make -j$(nproc)
RUN make install

# Clean up source to reduce image size
#RUN rm -rf /tmp/qt-src /tmp/qt-src.tar.xz

CMD ["/bin/bash"]
