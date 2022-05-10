FROM registry.access.redhat.com/ubi8/ubi
ARG openvidu_server_url
ARG openvidu_server_secret
ARG vrspace_server_url

RUN dnf -y install maven git java-11-openjdk
ENV OPENVIDU_SERVER_URL=${OPENVIDU_SERVER_URL}
ENV OPENVIDU_SERVER_SECRET=${OPENVIDU_SERVER_SECRET}
ENV VRSPACE_SERVER_URL=${VRSPACE_SERVER_URL}

WORKDIR /app
RUN git clone https://github.com/yd-ono/vrspace.git
WORKDIR /app/vrspace
RUN JAVA_HOME=/usr/lib/jvm/jre-11/ mvn clean install -DskipTests
EXPOSE 8080
CMD ["/usr/lib/jvm/jre-11/bin/java", "-jar", "/app/vrspace/server/target/server-0.4.6-SNAPSHOT.jar"]
