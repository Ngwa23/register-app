FROM maven:3.6.3-jdk-8 AS builder
WORKDIR /workspace

# Copy the full project and build all modules (skip tests for faster builds)
COPY . .
RUN mvn -B -DskipTests package

FROM tomcat:8.5-jre8

# Remove default apps and deploy the built WAR as ROOT.war
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /workspace/webapp/target/webapp.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
