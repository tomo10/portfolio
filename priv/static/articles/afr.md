<!-- livebook:{"file_entries":[{"name":"afr-8-11-23.png","type":"attachment"}]} -->

# AFR blog

## The brief

A client asked me to build them a web scraper to gather information on companies on the Australian Financial Review. With their blessing I'll share the prototype I built them.

This is a project that combines Elixir's highly capable webscraping and AI libraries as well as Phoenix LiveView for presentational purposes. I'll talk you through each one but first let's install what we'll need.

```elixir
Mix.install([
  {:floki, ">= 0.30.0"},
  {:jason, "~> 1.2"},
  {:plug_cowboy, "~> 2.5"},
  {:req, "~> 0.3"},
  {:nx, "~> 0.6"},
  {:exla, "~> 0.6"},
  {:bumblebee, "~> 0.3"},
  {:crawly, "~> 0.16.0"}
])
```

### Our plan

What we're going to do is scrape the headlines and summmaries of various articles from the Australian Financial Review (described to me as "Like the Financial Times, but Australian").

Once we've done this, the articles will exist in memory in our GenServer. From there we can display them in a Phoenix LiveView as well as run other asyncronous tasks - in our case sentiment analysis.

<!-- livebook:{"break_markdown":true} -->

### Our web scraper

<!-- livebook:{"break_markdown":true} -->

First we are going to build our web scraper using Elixir's [Crawly library](URLhttps://github.com/elixir-crawly/crawly)

```elixir
defmodule Afr do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://www.afr.com/companies/financial-services"

  @impl Crawly.Spider
  def init() do
    [start_urls: ["https://www.afr.com/companies/financial-services"]]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # CSS class selector for headlines on afr.com/companies/financial-services
    article_css_class = "._2slqK"

    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)

    items =
      Floki.find(document, article_css_class)
      |> Enum.map(fn story ->
        %{
          title: Floki.find(story, "h3") |> Floki.text(),
          summary: Floki.find(story, "p") |> Floki.text(),
          sentiment: nil
        }
      end)

    GenServer.cast(Tomai.News.AfrStream, {:scraped_data, items})

    %{items: items, requests: []}
  end

  def start_afr_spider() do
    Crawly.Engine.start_spider(Afr)
  end
end
```

The Crawly library has 3 functions that are required for every Spider
`base_url(), init(), and parse_item()`. This code will start a Spider based on your required urls (for the moment we are only crawling the financial-services articles).

The parse_item is where the main action is. Here we find the class tag by inspecting the html on the target website, parse the document body of the response, and then map the title and summary of the article to our items list.

Take note of line 30 where we make a cast call to our GenServer, this is how we are getting the data from our webscraper process to our GenServer process. This is vital for allowing us to then do something with our scraped data e.g. present in a LiveView, run sentiment analysis on etc.

<!-- livebook:{"break_markdown":true} -->

### Our GenServer

```elixir
defmodule Tomai.News.AfrStream do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def connect(pid) do
    GenServer.call(__MODULE__, {:add_lv_pid, pid})
  end

  @impl true
  def init(_state) do
    {:ok, %{items: []}}
  end

  @impl true
  def handle_call({:add_lv_pid, lv_pid}, _from, state) do
    state = Map.put(state, :lv_pid, lv_pid)

    {:reply, [], state}
  end

  @impl true
  def handle_cast({:scraped_data, items}, state) do
    updated_state = update_items(state, items)

    send(Map.get(state, :lv_pid), {:afr_stream, items})

    {:noreply, updated_state}
  end

  def update_items(state, items) do
    Map.update(state, :items, [], fn existing_items -> existing_items ++ items end)
  end
end
```

Here we see a pretty typical representation of a GenServer. What's different about ours is a `handle_cast()` function is implemented to receive the cast from our scraper and store the news items in state. It also sends the items to our Phoenix LiveView using the LiveView's process id on line 28. You'll see later how we pass the `lv_pid` we use here to the GenServer.

<!-- livebook:{"break_markdown":true} -->

### Our Phoenix LiveView

<!-- livebook:{"break_markdown":true} -->

First you'll need to create a route for you AFR feed

```elixir
live("/afr-sentiment", FeedLive.Index, :index)
```

Then create an index file in **lib/tomai_web/scraper_live**

```elixir
defmodule TomaiWeb.ScraperLive.Index do
  alias Tomai.News.AfrStream
  use TomaiWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    AfrStream.connect(self())

    {:ok, assign(socket, :articles, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <div class="grid grid-cols-2 gap-12">
        <div class="col-span-1 pb-2">
          <button
            phx-click="scrape"
            class="bg-yellow-500 hover:bg-yellow-600 text-white font-semibold py-2 px-4">
            Start scrape
          </button>
          <ul class="divide-y">
            <li :for={article <- @articles}>
              <a href="www.bbc.co.uk" target="_window">
                <div class="px-4 py-4">
                  <%= if article.sentiment do %>
                    <div class={[class_for_sentiment(article.sentiment), "p-1 rounded-lg"]}>
                      <p class="text-sm">Sentiment: <%= article.sentiment %></p>
                    </div>
                  <% end %>
                  <h2 class="text-md font-medium"><%= article.title %></h2>
                  <p class="text-sm"><%= article.summary %></p>
                  <div class="inline-flex space-x-2"></div>
                </div>
              </a>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  defp class_for_sentiment("positive"), do: "bg-green-100"
  defp class_for_sentiment("negative"), do: "bg-red-100"
  defp class_for_sentiment(_class), do: "bg-gray-100"

  @impl true
  def handle_event("scrape", _params, socket) do
    Afr.start_afr_spider()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:afr_stream, new_articles}, socket) do
    socket = run_enrichment_task(socket, new_articles)

    {:noreply, socket}
  end

  def handle_info({_task, enriched_articles}, socket) do
    socket =
      socket
      |> update(:articles, fn articles -> enriched_articles ++ articles end)

    {:noreply, socket}
  end

  def handle_info({:DOWN, _, _, _, _}, socket) do
    {:noreply, socket}
  end

  defp do_sentiment_enrich(articles) do
    Task.async(fn ->
      {_ignore, enrich} = Enum.split_with(articles, &(&1.sentiment != nil))
      Tomai.News.Enrichments.Sentiment.predict(enrich)
    end)
  end

  defp run_enrichment_task(socket, articles) do
    enrich_task = do_sentiment_enrich(articles)

    assign(socket, :enrich_task, enrich_task)
  end
end
```

If you are not familiar with LiveView the first thing to note is a that a LiveView is just a process. See Jason's [article](https://fly.io/phoenix-files/a-liveview-is-a-process/) which brilliantly explains this. Therefore we pass the process id to our GenServer on line 7 thus allowing our server to send (in our case) articles to our LiveView.

Our `handle_info` callback on line 52 is the very function which receives these AFR articles from our GenServer. Before we display them to our user we run our sentiment analysis on the title and summary of our article. More on this below.

<!-- livebook:{"break_markdown":true} -->

### Our Sentiment Analysis

We pass our articles off from our LiveView to our **Enrichments.Sentiments** module.

```elixir
defmodule Tomai.News.Enrichments.Sentiment do
  @moduledoc """
  Bumblebee based financial sentiment analysis.
  """
  alias Tomai.News.Article

  def predict(%Article{title: title, summary: summary} = article) do
    title_and_summary = title <> summary
    %{predictions: preds} = Nx.Serving.batched_run(__MODULE__, title_and_summary)
    %{label: max_label} = Enum.max_by(preds, & &1.score)
    %{article | sentiment: max_label}
  end

  def predict(articles) when is_list(articles) do
    preds =
      Nx.Serving.batched_run(
        __MODULE__,
        Enum.map(articles, fn article ->
          article.title <> article.summary
        end)
      )

    Enum.zip_with(articles, preds, fn article, %{predictions: pred} ->
      %{label: max_label} = Enum.max_by(pred, & &1.score)
      %{article | sentiment: max_label}
    end)

  def serving() do
    {:ok, model} = Bumblebee.load_model({:hf, "ahmedrachid/FinancialBERT-Sentiment-Analysis"})

    {:ok, tokenizer} =
      Bumblebee.load_tokenizer({:hf, "ahmedrachid/FinancialBERT-Sentiment-Analysis"})

    Bumblebee.Text.text_classification(model, tokenizer,
      defn_options: [compiler: EXLA],
      compile: [batch_size: 8, sequence_length: 128]
    )
  end
end
```

Here we see what our predict function call is doing under the hood where are taking advantage of the powerful [Bumbleebee](https://github.com/elixir-nx/bumblebee/), [Nx](https://github.com/elixir-nx/nx), and [EXLA](https://github.com/elixir-nx/xla) libraries.

As we are analysing Financial Sentiment of these companies the FinBERT sentiment analysis model is perfect for our use case. When presented with some text (in our case titles and summaries of articles) it returns whether the text's sentiment is most likely positive, negative or neutral. This can be very useful for traders, buy-side operations, to sense the general mood for a market or company.

The NX library efficiently batches the operations and serves them to our model via the Bumblee api. Check out the links to the libraries above to see more about what they can do.

```elixir
def handle_info({_task, enriched_articles}, socket) do
  socket =
    socket
    |> update(:articles, fn articles -> enriched_articles ++ articles end)

  {:noreply, socket}
end
```

Once the sentiment analsis task has run asyncronously and completed, the results are sent back to the LiveView handle info function and then rendered.

<!-- livebook:{"break_markdown":true} -->

![](files/afr-8-11-23.png)

<!-- livebook:{"break_markdown":true} -->

### Conclusion

<!-- livebook:{"break_markdown":true} -->

There are a myriad of ways to expand on this basic web scraper sentiment analysis prototype. The results could be saved to a database like Postgres where you could run time series analysis. Background processing jobs could be scheduled. Other enrichments could be run on the test to create alerts for certain keywords / companies - _spolier this is what we did for this application :)_

But I hope this shows one of the ways you can move data from a website, through a GenServer, and then rendered in a LiveView, all using just the tools available in the Elixir ecosytem.

<!-- livebook:{"break_markdown":true} -->

_N.B. Much thanks to Sean Moriarity's excellent article on [end-to-end machine learning](https://dockyard.com/blog/2023/09/19/end-to-end-machine-learning-in-elixir) which formed the backbone of the machine learning aspects of this blog._
