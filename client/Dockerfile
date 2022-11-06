FROM node:16-alpine

# Set the working directory to /app inside the container
WORKDIR /app
# Copy app files
COPY . .

# Install and build
RUN npm ci
RUN npm run build


# Just in case, but by default `vite build` runs in `--mode production` by default
# And loads the `.env.prod` variables
ENV NODE_ENV production
# Expose the port on which the app will be running (3000 is the default that `serve` uses)
EXPOSE 3333

# Start the app
CMD [ "npx", "serve", "build" ]