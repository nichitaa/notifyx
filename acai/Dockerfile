FROM elixir:latest

# Create app directory and copy the Elixir project into it.
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install Hex package manager.
# By using `--force`, we don’t need to type "Y" to confirm the installation.
RUN mix local.hex --force &&  \
    mix local.rebar --force

# Compile the project.
RUN mix do compile

CMD ["/app/entrypoint.sh"]