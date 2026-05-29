# ─────────────────────────────────────────────
#  Stage 1 – Install dependencies
# ─────────────────────────────────────────────
FROM node:18-alpine AS deps

WORKDIR /app

# Copy dependency manifests first (layer-cache friendly)
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# ─────────────────────────────────────────────
#  Stage 2 – Runtime image
# ─────────────────────────────────────────────
FROM node:18-alpine AS runtime

# Add curl for health-checks (tiny addition on alpine)
RUN apk add --no-cache curl

# Create a non-root user for security best-practices
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy production node_modules from the deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application source
COPY . .

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

USER appuser

# Tell Docker which port the app listens on
EXPOSE 3000

# Environment variables
ENV NODE_ENV=production
ENV CONTAINERIZED=true

# Health check – Docker will poll this every 30 s
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Start the application
CMD ["node", "app.js"]
