# Choose desired JDK as the base image
FROM openjdk:8-jre-alpine
LABEL maintainer="Ajitem Sahasrabuddhe <ajitem.s@outlook.com> & Yash Shanker Srivastava <yash.shanker@outlook.com>"

RUN apk add --no-cache curl grep sed unzip

#Install NodeJS and npm to fully support JS projects analysis
RUN apk add --update nodejs npm

# Set timezone to India 
ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /root
# Get Sonar Scanner CLI + Cleanup
ARG sonar_scanner_version=3.2.0.1227
RUN curl -o sonarscanner.zip -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${sonar_scanner_version}-linux.zip &&  \
    unzip sonarscanner.zip && \
    rm sonarscanner.zip && \
    mv sonar-scanner-${sonar_scanner_version}-linux sonar-scanner

# prefer embedded java for musl over glibc
RUN sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /root/sonar-scanner/bin/sonar-scanner

RUN addgroup -g 1000 sonar && \
    adduser -D -u 1000 -G sonar sonar && \
    chown -R sonar:sonar /root

USER sonar

ENTRYPOINT [ "/root/sonar-scanner/bin/sonar-scanner" ]

CMD [ "-Dsonar.projectBaseDir=./" ]
