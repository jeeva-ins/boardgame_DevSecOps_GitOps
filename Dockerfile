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
ENV JAVA=/app/optimized-jdk-17/bin/java
# copy JRE from the base image
COPY --from=jre-builder /optimized-jdk-17/  $JAVA
RUN ls -ltr /app

# Add app user
ARG APPLICATION_USER=spring

# Create a user to run the application, don't run as root
RUN addgroup --system $APPLICATION_USER &&  adduser --system $APPLICATION_USER --ingroup $APPLICATION_USER

# Create the application directory
RUN chown -R $APPLICATION_USER /app

COPY --chown=$APPLICATION_USER:$APPLICATION_USER staging/*.jar /app/app.jar

USER $APPLICATION_USER

EXPOSE 8080

ENV PATH="${JAVA}/bin:${PATH}"

CMD [ "$JAVA", "-jar", "/app/app.jar" ]