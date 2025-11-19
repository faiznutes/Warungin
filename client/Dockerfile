# Frontend Dockerfile
FROM node:18-alpine AS frontend-builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
# Use npm install to handle lock file sync issues, fallback to legacy-peer-deps if needed
RUN npm install --legacy-peer-deps || npm install

# Copy source code
COPY . .

# Set environment variable for API URL
ARG VITE_API_URL=https://pos.faiznute.site/api
ENV VITE_API_URL=$VITE_API_URL

# Build application
RUN npm run build

# Production stage with nginx
FROM nginx:alpine

# Install wget for healthcheck
RUN apk add --no-cache wget

# Copy built files
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

