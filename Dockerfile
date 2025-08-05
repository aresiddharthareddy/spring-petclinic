# ----------- Build Stage -----------
FROM openjdk:26-slim-bullseye AS build

# Install Maven and Git
RUN apt-get update && \
    apt-get install -y --no-install-recommends maven git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only necessary files for build
COPY pom.xml ./
COPY src ./src

# Build the app
RUN mvn clean package -DskipTests

# ----------- Runtime Stage -----------
FROM openjdk:26-slim-bullseye AS runtime

# Install curl and create non-root user
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --shell /bin/bash appuser

USER appuser
WORKDIR /home/appuser

# Copy built JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Default command
ENTRYPOINT ["java", "-jar", "app.jar"]
