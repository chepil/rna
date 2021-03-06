export ANDROID_SDK_VERSION=r24.4.1
export ANDROID_BUILD_TOOLS_VERSION=build-tools-27.0.3,build-tools-26.1.1,build-tools-26.0.2,build-tools-26.0.1,build-tools-23.0.3
export ANDROID_SDK_FILENAME=android-sdk_${ANDROID_SDK_VERSION}-linux.tgz
export ANDROID_SDK_URL=http://dl.google.com/android/${ANDROID_SDK_FILENAME}
export ANDROID_API_LEVELS=android-27
export ANDROID_EXTRA_COMPONENTS=extra-android-m2repository,extra-google-m2repository
export ANDROID_HOME=/opt/android-sdk-linux
export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
export GRADLE_VERSION=4.7
export GRADLE_HOME=/usr/lib/gradle
export PATH=$PATH:$GRADLE_HOME/bin
export NODE_VERSION=8.11.2
export PATH=${PATH}:/opt/node/bin
export LANG=en_US.UTF-8
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
