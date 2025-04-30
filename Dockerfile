FROM gcr.io/distroless/java-base-debian12
      
EXPOSE 8080
 
ENV APP_HOME=/usr/src/app

COPY staging/*.jar $APP_HOME/app.jar

WORKDIR $APP_HOME

CMD ["app.jar"]
