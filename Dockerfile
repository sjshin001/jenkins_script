FROM jenkins/jenkins:lts

# ── root로 전환하여 시스템 패키지 설치 ──
USER root

# ── 한국어 로케일 설정 ──
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    && sed -i 's/# ko_KR.UTF-8/ko_KR.UTF-8/' /etc/locale.gen \
    && locale-gen ko_KR.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=ko_KR.UTF-8
ENV LANGUAGE=ko_KR.UTF-8
ENV LC_ALL=ko_KR.UTF-8

# ── 타임존 설정 (Asia/Seoul) ──
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    echo "Asia/Seoul" > /etc/timezone

ENV TZ=Asia/Seoul

# ── Docker CLI 설치 (docker.image().inside() 파이프라인용) ──
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates gnupg lsb-release \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# ── 기본 빌드 도구 + Python3 (node-gyp 네이티브 빌드용) ──
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ── JDK 8 설치 (Selenium 프로젝트용) ──
RUN curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(. /etc/os-release && echo $VERSION_CODENAME) main" \
    > /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && apt-get install -y --no-install-recommends temurin-8-jdk && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/temurin-8-jdk-amd64

# ── Maven 3 설치 ──
ARG MAVEN_VERSION=3.9.9
RUN curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    | tar -xz -C /opt && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven

ENV MAVEN_HOME=/opt/maven
ENV PATH="${MAVEN_HOME}/bin:${PATH}"

# ── Node.js 20 설치 (Playwright 프로젝트용) ──
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# ── Playwright 브라우저 시스템 의존성 (Chromium용) ──
RUN npx playwright install-deps chromium

# ── Jenkins 플러그인 사전 설치 ──
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# ── jenkins 유저로 복귀 ──
USER jenkins
