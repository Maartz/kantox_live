FROM hexpm/elixir:1.14.5-erlang-24.2.2-alpine-3.18.8 AS base

WORKDIR /kantox_live

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

WORKDIR /kantox_live

ARG MIX_ENV=prod

RUN apk add ncurses-libs curl

COPY --from=release /kantox_live/_build/$MIX_ENV/rel/kantox_live ./

CMD ["bin/kantox_live", "start"]
