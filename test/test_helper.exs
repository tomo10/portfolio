ExUnit.configure(exclude: [:petal_framework])
ExUnit.start()
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, PortfolioWeb.Endpoint.url())

"screenshots/*"
|> Path.wildcard()
|> Enum.each(&File.rm/1)
