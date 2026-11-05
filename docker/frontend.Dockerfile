FROM node:18-bullseye
WORKDIR /app

COPY frontend/package.json frontend/package-lock.json ./
# The repository lockfile predates the current package manifest. npm install
# performs the required one-time lockfile reconciliation in the image.
RUN npm install --legacy-peer-deps
COPY frontend/ ./

EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
