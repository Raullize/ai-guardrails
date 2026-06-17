---
name: "docker-expert"
description: "Optimizes, creates, or fixes Dockerfiles and docker-compose.yml files. Invoke when the user asks for Docker configuration, image size reduction, or container setup."
---

# Docker Configuration Expert

<instructions>
When creating or optimizing Dockerfiles and `docker-compose.yml` files, you MUST apply industry-standard best practices:

1. **Image Size & Build Times:**
   - ALWAYS use Multi-stage builds to separate the build environment from the runtime environment.
   - Use lightweight base images like `alpine` or `-slim` variants (e.g., `node:20-alpine`).
   - Order Dockerfile commands correctly to leverage layer caching (e.g., copy `package.json` and install dependencies BEFORE copying the rest of the source code).

2. **Security:**
   - NEVER run the container as the `root` user. Always create a dedicated non-root user (e.g., `USER node` or `USER appuser`) before the `CMD` instruction.
   - Do not hardcode secrets in the Dockerfile. Use environment variables or `.env` files.

3. **Docker Compose:**
   - Define clear dependencies between services using `depends_on`.
   - Setup named volumes for databases to ensure data persistence.
   - Map ports explicitly and configure healthchecks for critical services like databases.
</instructions>