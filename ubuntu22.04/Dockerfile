FROM ubuntu:22.04

ARG NODE_VERSION=20
ARG OPENCV_VERSION=4.9.0

# Install Pre-requisites
RUN apt-get update && apt-get install -y curl wget build-essential g++ cmake unzip

# Install Puppeteer Dependencies
RUN apt-get install -y \
    fonts-liberation \
    gconf-service \
    libappindicator1 \
    libasound2 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libfontconfig1 \
    libgbm-dev \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libicu-dev \
    libjpeg-dev \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpng-dev \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    xdg-utils

# Install Node.js
RUN apt-get update  && \
    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

# Download OpenCV
RUN mkdir -p opencv && \
    cd opencv && \
    wget -O opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
    unzip opencv.zip

# Download OpenCV Contrib
RUN cd opencv && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
    unzip opencv_contrib.zip

# Configure OpenCV
RUN cd opencv && \
    mkdir -p build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-${OPENCV_VERSION}/modules \
          -D BUILD_EXAMPLES=OFF ../opencv-${OPENCV_VERSION}

# Compile OpenCV
RUN cd opencv/build && \ 
    cmake --build . --config Release

# Install OpenCV
RUN cd opencv/build && \
    make install
    
