FROM node:16

# Create app directory
WORKDIR /app

COPY package.json package-lock.json ./

# Required for pm2-runtime
RUN npm install pm2 -g
RUN npm install

# Bundle app source
COPY . .

CMD ["npm", "run", "prod:pm2"]