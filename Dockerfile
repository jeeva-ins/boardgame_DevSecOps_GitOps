FROM adoptopenjdk/openjdk11:alpine
      
EXPOSE 8080
 
ENV APP_HOME /usr/src/app

COPY stageing/*.jar $APP_HOME/app.jar

WORKDIR $APP_HOME

CMD ["java", "-jar", "app.jar"]
