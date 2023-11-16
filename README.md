## Get up and running

**Assumptions:**

- You have Elixir & Erlang installed
- You have Postgres installed and running (optional - see "Using Docker for Postgres" below

If you don't meet this assumptions you can read our [comprehensive install instructions](https://docs.petal.build/portfolio-documentation/fundamentals/installation).

**The steps**

1. Add the "petal" repo so your local Hex is aware of our private packages. Simply run the command in step 1 in the ["Install Petal Framework"](https://petal.build/components/install-petal-framework) guide (make sure you're signed in so your license key is automatically insterted).
1. `mix setup` (this get dependencies, setup database, migrations, seeds, install esbuild + Tailwind)
1. `iex -S mix phx.server` (starts the server in IEX mode)
1. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

[] Put bit about AI agents on landing page / write an article
