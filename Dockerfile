# Pull base image.
FROM ubuntu:18.04
MAINTAINER den@chepil.ru

# Install base software packages
RUN apt-get update && \
    apt-get install -y openssh-server \
    build-essential \
    libssl-dev \
    python python-dev python-distribute python-pip \
    ruby \
    apt-utils \
    supervisor \ 
    vim \
    inetutils-ping \
    net-tools \
    software-properties-common \
    wget \
    curl \
    git \
    zip \
    yarn \
    unzip -y && \
    apt-get clean

RUN mkdir -p /var/run/sshd /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY .bash_profile /root/.bash_profile
RUN chmod 600 /root/.bash_profile

EXPOSE 22 2222 8081 8083 80



# ——————————
# Install Java.
# ——————————
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# ——————————
# Installs i386 architecture required for running 32 bit Android tools
# ——————————

RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

# android build tool needed
#RUN apt-get update && apt-get install -y lib32stdc++6 lib32z1 jq

# ——————————
# Installs Android SDK
# ——————————

#Used by: 
# - Android SDK Tools, revision 25.2.5
#  - Android SDK Platform-tools, revision 27.0.1
#  - Android SDK Build-tools, revision 27.0.3
#  - SDK Platform Android 8.1.0, API 27, revision 3
#Used by: 
# - Android Support Repository, revision 47
#  - Google Repository, revision 58

RUN mkdir -p /opt/android-sdk-linux/licenses && \
    echo "d56f5187479451eabf01fb78af6dfcb131a6481e" > /opt/android-sdk-linux/licenses/android-sdk-license && \
    echo "84831b9409646a918e30573bab4c9c91346d8abd" > /opt/android-sdk-linux/licenses/android-sdk-preview-license

ENV ANDROID_SDK_VERSION r24.4.1
ENV ANDROID_BUILD_TOOLS_VERSION build-tools-27.0.3,build-tools-26.1.1,build-tools-26.0.2,build-tools-26.0.1,build-tools-23.0.3

ENV ANDROID_SDK_FILENAME android-sdk_${ANDROID_SDK_VERSION}-linux.tgz
ENV ANDROID_SDK_URL http://dl.google.com/android/${ANDROID_SDK_FILENAME}
ENV ANDROID_API_LEVELS android-27
ENV ANDROID_EXTRA_COMPONENTS extra-android-m2repository,extra-google-m2repository
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
RUN cd /opt && \
    wget -q ${ANDROID_SDK_URL} && \
    tar -xzf ${ANDROID_SDK_FILENAME} && \
    rm ${ANDROID_SDK_FILENAME} && \
    echo y | android update sdk --no-ui -a --filter tools,platform-tools,${ANDROID_API_LEVELS},${ANDROID_BUILD_TOOLS_VERSION} && \
    echo y | android update sdk --no-ui --all --filter "${ANDROID_EXTRA_COMPONENTS}"

RUN mkdir $HOME/android
RUN ln -s /opt/android-sdk-linux $HOME/android/sdk
    
# ——————————
# Installs Android NDK
# ——————————
    
ENV ANDROID_NDK_VERSION r17

ENV ANDROID_NDK_FILENAME android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip
ENV ANDROID_NDK_URL https://dl.google.com/android/repository/${ANDROID_NDK_FILENAME}
ENV ANDROID_NDK_HOME android-ndk-${ANDROID_NDK_VERSION}
RUN cd /opt && \
    wget -q ${ANDROID_NDK_URL} && \
    unzip ${ANDROID_NDK_FILENAME} && \
    rm ${ANDROID_NDK_FILENAME} 
RUN ln -s /opt/android-ndk-r17 $HOME/android/ndk

# ——————————
# Installs Gradle
# ——————————

# Gradle
ENV GRADLE_VERSION 4.7

RUN cd /usr/lib \
 && curl -fl https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle-bin.zip \
 && unzip "gradle-bin.zip" \
 && ln -s "/usr/lib/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
 && rm "gradle-bin.zip"

# Set Appropriate Environmental Variables
ENV GRADLE_HOME /usr/lib/gradle
ENV PATH $PATH:$GRADLE_HOME/bin

# ——————————
# Install NVM
# ——————————
#ENV NVM_DIR /opt/.nvm
#RUN git clone https://github.com/creationix/nvm.git $NVM_DIR && \
#    cd $NVM_DIR && \
#    git checkout `git describe --abbrev=0 --tags`


# ——————————
# Install Node and global packages
# ——————————
ENV NODE_VERSION 8.11.2
RUN cd && \
    wget -q http://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz && \
    tar -xzf node-v${NODE_VERSION}-linux-x64.tar.gz && \
    mv node-v${NODE_VERSION}-linux-x64 /opt/node && \
    rm node-v${NODE_VERSION}-linux-x64.tar.gz
ENV PATH ${PATH}:/opt/node/bin
RUN ln -s /opt/node/bin/node /usr/bin/node
RUN ln -s /opt/node/bin/node /usr/bin/nodejs


# ——————————
# Install default version of Node.js
# ——————————
#RUN source $NVM_DIR/nvm.sh && \
#    nvm install $NODE_VERSION && \
#    nvm alias default $NODE_VERSION && \
#    nvm use default
    
# source nvm to shell
#RUN echo "source ${NVM_DIR}/nvm.sh" > $HOME/.bashrc && \
#    source $HOME/.bashrc

# Set node environment variables
#ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
#ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
    

# ——————————
# Install Basic React-Native packages
# ——————————
RUN npm config set user 0
RUN npm config set unsafe-perm true

RUN npm install npm@6.0.1 -g
RUN npm install react-native-cli -g
RUN npm install rnpm -g
#RUN npm install -g hexo

ENV LANG en_US.UTF-8

RUN which android
RUN which adb
RUN node --version
RUN npm --version


# ——————————
# Installs FB Watchman
# ——————————

#RUN git clone -b v3.8.0 https://github.com/facebook/watchman.git /tmp/watchman
#WORKDIR /tmp/watchman
#RUN ./autogen.sh
#RUN ./configure
#RUN make
#RUN make install


# Clean up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean
    
# copy all the files into /app
#COPY . /app
#WORKDIR /app
#RUN npm install
#ENV PATH node_modules/.bin:$PATH

# Run it
#RUN cmd echo 999999 | tee -a /proc/sys/fs/inotify/max_user_watches && \
#    echo 999999 | tee -a /proc/sys/fs/inotify/max_queued_events && \
#    echo 999999 | tee -a /proc/sys/fs/inotify/max_user_instances && \
#    watchman shutdown-server && \
#    npm start


CMD ["/usr/bin/supervisord"]

