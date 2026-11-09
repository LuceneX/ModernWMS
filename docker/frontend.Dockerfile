FROM node:18-bullseye
WORKDIR /app

COPY frontend/package.json frontend/package-lock.json ./
# The repository lockfile predates the current package manifest. npm install
# performs the required one-time lockfile reconciliation in the image.
RUN npm install --legacy-peer-deps
COPY frontend/ ./

ENV VITE_API_BASE_URL=/api
ENV BACKEND_SERVICE=http://backend:5555
EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
