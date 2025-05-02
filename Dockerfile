# First stage, build the custom JRE
FROM openjdk:17-jdk-slim AS jre-builder

# Install binutils, required by jlink
RUN apt-get update -y &&  \
    apt-get install -y binutils

# Build small JRE image
RUN $JAVA_HOME/bin/jlink \
         --verbose \
         --add-modules java.base,java.compiler,java.desktop,java.instrument,java.management,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.security.jgss,java.sql,jdk.jfr,jdk.unsupported \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /optimized-jdk-17

# Second stage, Use the custom JRE and build the app image
FROM alpine:latest
#ENV JAVA_HOME=/opt/jdk/jdk-17
#ENV PATH="${JAVA_HOME}/bin:${PATH}"
WORKDIR /app

# copy JRE from the base image
COPY --from=jre-builder /optimized-jdk-17/  /optimized-jdk-17/

COPY  staging/*.jar /app/app.jar
EXPOSE 8080
CMD [ "/app/optimized-jdk-17/bin/java", "-jar", "/app/app.jar" ]