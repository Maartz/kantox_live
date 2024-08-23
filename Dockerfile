FROM hexpm/elixir:1.13.0-erlang-23.3.4.10-alpine-3.14.3 AS base

WORKDIR /render

RUN mix do local.hex --force, local.rebar --force

RUN apk add npm inotify-tools

# -----------------
# BUILD
# -----------------
FROM base AS build

RUN apk add curl bash git

ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV
COPY . ./

RUN mix do deps.get, compile

# -----------------
# RELEASE
# -----------------
FROM build AS release

RUN mix assets.deploy

RUN mix release

# -----------------
# PRODUCTION
# -----------------
FROM alpine:3.14.3

WORKDIR /render

ARG MIX_ENV=prod

RUN apk add ncurses-libs curl

COPY --from=release /render/_build/$MIX_ENV/rel/render ./

CMD ["bin/render", "start"]
