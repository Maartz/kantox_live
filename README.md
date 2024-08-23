# SuperMarkex - KantoxLive Application

To start your application:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Test suite

To run the tests you can:

```
mix test
```

Or if you want to have an overview of the code coverage you can:

```
mix coveralls
```

In order to get the code coverage as accurate as possible, without being polluted with already generated test.

You can check the list of excluded files here:

```json
{
  "skip_files": [
    "lib/kantox_live.ex",
    "lib/kantox_live_web.ex",
    "lib/kantox_live_web/controllers/",
    "lib/kantox_live_web/components/",
    "lib/kantox_live_web/router.ex",
    "lib/kantox_live_web/telemetry.ex",
    "lib/kantox_live_web/endpoint.ex",
    "lib/kantox_live/application.ex",
    "test/"
  ]
}
```

It can also be found inside the `coveralls.json` file.

## Code quality and smells

You can run `mix credo --strict` if you want to check for code quality, smells and improvement.

**Important** to note, I've left a `FIXME` inside the code.
It's on purpose as I won't be able to find a perfect solution for my problem.

The other issues comes either from the multilines of this `FIXME` or from `core_components.ex`. Which I've decided to not fix.
