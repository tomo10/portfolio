defmodule PortfolioWeb.CustomComponents do
  use Phoenix.Component
  use PetalComponents

  attr :image_src, :string, required: true
  attr :logo_cloud_title, :string, default: nil
  attr :max_width, :string, default: "lg", values: ["sm", "md", "lg", "xl", "full"]
  slot :title
  slot :description
  slot :about_me_1
  slot :about_me_2
  slot :action_buttons

  def hero(assigns) do
    ~H"""
    <section id="hero" class="flex-1 from-white to-gray-100 dark:from-gray-900 dark:to-gray-800">
      <%!-- <div class="flex flex-wrap items-center -mx-3"> --%>
      <div class="w-full px-8">
        <div class="py-12">
          <div class="max-w-lg mx-auto mb-8 text-center lg:max-w-md lg:mx-0 lg:text-left">
            <.h1 class="fade-in-animation">
              <%= render_slot(@title) %>
            </.h1>

            <p class="mt-6 text-lg leading-relaxed text-gray-500 dark:text-gray-400 fade-in-animation">
              <%= render_slot(@description) %>
            </p>
            <p class="mt-6 text-lg leading-relaxed text-gray-500 dark:text-gray-400 fade-in-animation">
              <%= render_slot(@about_me_1) %>
            </p>
            <p class="mt-6 text-lg leading-relaxed text-gray-500 dark:text-gray-400 fade-in-animation">
              <%= render_slot(@about_me_2) %>
            </p>
          </div>
          <div class="space-x-2 text-center lg:text-left fade-in-animation">
            <%= render_slot(@action_buttons) %>
          </div>
        </div>
      </div>
      <%!-- <div class="bg-red-400 w-full px-3 mb-12 lg:w-1/2 lg:mb-0">
            <div class="flex items-center justify-center lg:h-128">
              <img
                id="hero-image"
                class="fade-in-from-right-animation rounded-full lg:max-w-lg max-h-[200px]"
                src={@image_src}
                alt=""
              />
            </div>
          </div> --%>
      <%!-- </div> --%>
    </section>
    """
  end

  attr :image_src, :string, required: true
  attr :max_width, :string, default: "lg", values: ["sm", "md", "lg", "xl", "full"]
  slot :form
  slot :response

  def aida(assigns) do
    ~H"""
    <section class="flex-1 from-white to-gray-100 py-12 dark:from-gray-900 dark:to-gray-800">
      <div class="lg:h-128">
        <div class="flex items-center justify-center lg:h-128">
          <img
            id="hero-image"
            class="fade-in-from-right-animation rounded-full lg:max-w-lg max-h-[100px]"
            src={@image_src}
            alt=""
          />
        </div>

        <%!-- <.h3>AIDA Prompt</.h3> --%>
        <.form for={@form} phx-submit="submit">
          <.field
            field={@form[:question]}
            placeholder="Ask me anything..."
            help_text="e.g. What technology do you like using?"
          />
        </.form>
        <%!-- <div class="flex justify-start">
          <.button color="secondary" phx-disable-with="Loading...">Ask me</.button>
        </div> --%>

        <div :if={@response} class="mt-20">
          <div class="p-5 text-white border-gray-200 rounded-lg bg-slate-800 text-semibold">
            <%= @response %>
          </div>
        </div>
      </div>
    </section>
    """
  end

  attr :title, :string
  attr :cloud_logo, :list, default: [], doc: "List of slots"

  def logo_cloud(assigns) do
    ~H"""
    <div id="logo-cloud" class="container px-4 mx-auto">
      <%= if @title do %>
        <h2 class="mb-10 text-2xl text-center text-gray-500 fade-in-animation dark:text-gray-300">
          <%= @title %>
        </h2>
      <% end %>

      <div class="flex flex-wrap justify-center">
        <%= for logo <- @cloud_logo do %>
          <div class="w-full p-4 md:w-1/3 lg:w-1/6">
            <div class="py-4 lg:py-8">
              <%= render_slot(logo) %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string
  # attr :link_to, :string

  attr :features, :list,
    default: [],
    doc:
      "A list of projects, which are maps with the keys :icon (a HeroiconV1), :title and :description"

  attr :grid_classes, :string,
    default: "md:grid-cols-3",
    doc: "Tailwind grid cols class to specify how many columns you want"

  attr :max_width, :string, default: "lg", values: ["sm", "md", "lg", "xl", "full"]

  def projects(assigns) do
    ~H"""
    <section
      id="projects"
      class="relative z-10 py-16 text-center transition duration-500 ease-in-out bg-white md:py-32 dark:bg-gray-900 dark:text-white"
    >
      <.container max_width={@max_width} class="relative z-10">
        <div class="mx-auto mb-16 md:mb-20 lg:w-7/12 stagger-fade-in-animation">
          <div class="mb-5 text-3xl font-bold md:mb-7 md:text-5xl fade-in-animation">
            <%= @title %>
          </div>
          <div class="text-lg font-light anim md:text-2xl fade-in-animation">
            <%= @description %>
          </div>
        </div>

        <div class={["grid stagger-fade-in-animation gap-y-8", @grid_classes]}>
          <%= for feature <- @features do %>
            <div class="px-8 mb-10 border-gray-200 md:px-16 fade-in-animation last:border-0">
              <div class="flex justify-center mb-4 md:mb-6">
                <span class="flex items-center justify-center w-12 h-12 rounded-md bg-primary-600">
                  <.icon name={feature.icon} class="w-6 h-6 text-white" />
                </span>
              </div>
              <div class="mb-2 text-lg font-medium md:text-2xl">
                <.link :if={!feature.external} patch={feature.link_to}>
                  <%= feature.title %>
                </.link>
                <.link :if={feature.external} href={feature.link_to} target="_blank">
                  <%= feature.title %>
                </.link>
              </div>
              <p class="font-light leading-normal md:text-lg">
                <%= feature.description %>
              </p>
            </div>
          <% end %>
        </div>
      </.container>
    </section>
    """
  end

  attr :blogs, :list,
    default: [],
    doc:
      "A list of blogs, which are maps with the keys :icon (a HeroiconV1), :title and :description"

  attr :grid_classes, :string,
    default: "md:grid-cols-2",
    doc: "Tailwind grid cols class to specify how many columns you want"

  attr :max_width, :string, default: "lg", values: ["sm", "md", "lg", "xl", "full"]

  def blogs(assigns) do
    ~H"""
    <section
      id="blogs"
      class="relative z-10 py-16 text-center transition duration-500 ease-in-out bg-white md:py-32 dark:bg-gray-900 dark:text-white"
    >
      <.container max_width={@max_width} class="relative z-10">
        <div class={["grid stagger-fade-in-animation gap-y-8", @grid_classes]}>
          <%= for blog <- @blogs do %>
            <div
              class="rounded-lg shadow-lg overflow-hidden flex"
              phx-click="go-to-article"
              style="cursor: pointer;"
            >
              <div class="flex-1 p-4 text-left hover:bg-gray-800">
                <h3 class="text-xl font-semibold mb-2"><%= blog.title %></h3>
                <p class="text-sm text-gray-700 mb-4"><%= blog.description %></p>
                <.button color="secondary" label="Read" variant="inverted" />
              </div>
            </div>
          <% end %>
        </div>
      </.container>
    </section>
    """
  end

  attr :title, :string, default: "Contact"
  attr :socials, :list, doc: "A list of maps with the keys: title, image_src, "
  attr :max_width, :string, default: "lg", values: ["sm", "md", "lg", "xl", "full"]

  def contact(assigns) do
    ~H"""
    <section
      id="contact"
      class="relative z-10 transition duration-500 ease-in-out bg-white py-36 dark:bg-gray-900"
    >
      <div class="overflow-hidden content-wrapper">
        <.container max_width={@max_width} class="relative z-10">
          <div class="mb-5 text-center md:mb-12 section-header stagger-fade-in-animation">
            <div class="mb-3 text-3xl font-bold leading-none dark:text-white md:mb-5 fade-in-animation md:text-5xl">
              <%= @title %>
            </div>
          </div>

          <div class="solo-animation fade-in-animation flickity">
            <%= for social <- @socials do %>
              <.contact_panel {social} />
            <% end %>
          </div>
        </.container>
      </div>
    </section>

    <script phx-update="ignore" id="testimonials-js" type="module">
      // Flickity allows for a touch-enabled slideshow - used for testimonials
      import flickity from 'https://cdn.skypack.dev/flickity@2';

      let el = document.querySelector(".flickity");

      if(el){
        new flickity(el, {
          cellAlign: "left",
          prevNextButtons: false,
          adaptiveHeight: false,
          cellSelector: ".carousel-cell",
        });
      }
    </script>

    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/flickity/2.3.0/flickity.min.css"
      integrity="sha512-B0mpFwHOmRf8OK4U2MBOhv9W1nbPw/i3W1nBERvMZaTWd3+j+blGbOyv3w1vJgcy3cYhzwgw1ny+TzWICN35Xg=="
      crossorigin="anonymous"
      referrerpolicy="no-referrer"
    />
    <style>
      /* Modify the testimonial slider to go off the page */
      #testimonials .flickity-viewport {
        overflow: unset;
      }

      #testimonials .flickity-page-dots {
        position: relative;
        bottom: unset;
        margin-top: 40px;
        text-align: center;
      }

      #testimonials .flickity-page-dots .dot {
        background: #3b82f6;
        transition: 0.3s all ease;
        opacity: 0.35;
        margin: 0;
        margin-right: 10px;
      }

      #testimonials .flickity-page-dots .dot.is-selected {
        opacity: 1;
      }

      .dark #testimonials .flickity-page-dots .dot {
        background: white;
      }
    </style>
    """
  end

  attr :image_src, :string, required: true
  attr :title, :string, required: true
  attr :other, :string
  attr :link, :string, required: true

  def contact_panel(assigns) do
    ~H"""
    <div class="p-4 mr-10 overflow-hidden text-gray-700 transition duration-500 ease-in-out rounded-lg shadow-lg md:p-8 md:w-8/12 lg:w-5/12 bg-primary-50 dark:bg-gray-700 dark:text-white carousel-cell last:mr-0">
      <div class="flex items-center">
        <div class="inline-flex flex-shrink-0 border-2 border-white rounded-full">
          <img class="w-16 h-16 rounded-full" src={@image_src} alt="" />
        </div>
        <div class="ml-4">
          <.link href={@link} class="text-base font-bold"><%= @title %></.link>
          <div :if={@other} class="text-base font-semibold"><%= @other %></div>
        </div>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :max_width, :string, default: "lg", values: ["sm", "md", "lg", "xl", "full"]

  attr :plans, :list,
    doc:
      "List of maps with keys: :most_popular (bool), :name, :currency, :price, :unit, :description, :features (list of strings)"

  def load_js_animations(assigns) do
    IO.inspect("------------------------------")
    IO.inspect("load_js_animations...")
    IO.inspect("------------------------------")

    ~H"""
    <script type="module">
      // Use GSAP for animations
      // https://greensock.com/gsap/
      import gsap from 'https://cdn.skypack.dev/gsap@3.10.4';

      // Put it on the window for when you want to try out animations in the console
      window.gsap = gsap;

      // A plugin for GSAP that detects when an element enters the viewport - this helps with timing the animation
      import ScrollTrigger from "https://cdn.skypack.dev/gsap@3.10.4/ScrollTrigger";
      gsap.registerPlugin(ScrollTrigger);

      animateHero();
      setupPageAnimations();

      // This is needed to ensure the animations timings are correct as you scroll
      setTimeout(() => {
        ScrollTrigger.refresh(true);
      }, 1000);

      function animateHero() {

        // A timeline just means you can chain animations together - one after another
        // https://greensock.com/docs/v3/GSAP/gsap.timeline()
        const heroTimeline = gsap.timeline({});

        heroTimeline
          .to("#hero .fade-in-animation", {
            opacity: 1,
            y: 0,
            stagger: 0.1,
            ease: "power2.out",
            duration: 1,
          })
          .to("#hero-image", {
            opacity: 1,
            x: 0,
            duration: 0.4
          }, ">-1.3")
          <%!-- .to("#logo-cloud .fade-in-animation", {
            opacity: 1,
            y: 0,
            stagger: 0.1,
            ease: "power2.out",
          }) --%>
      }

      function setupPageAnimations() {

        // This allows us to give any individual HTML element the class "solo-animation"
        // and that element will fade in when scrolled into view
        gsap.utils.toArray(".solo-animation").forEach((item) => {
          gsap.to(item, {
            y: 0,
            opacity: 1,
            duration: 0.5,
            ease: "power2.out",
            scrollTrigger: {
              trigger: item,
            },
          });
        });

        // Add the class "stagger-fade-in-animation" to a parent element, then all elements within it
        // with the class "fade-in-animation" will fade in on scroll in a staggered formation to look
        // more natural than them all fading in at once
        gsap.utils.toArray(".stagger-fade-in-animation").forEach((stagger) => {
          const children = stagger.querySelectorAll(".fade-in-animation");
          gsap.to(children, {
            opacity: 1,
            y: 0,
            ease: "power2.out",
            stagger: 0.15,
            duration: 0.5,
            scrollTrigger: {
              trigger: stagger,
              start: "top 75%",
            },
          });
        });
      }
    </script>
    """
  end
end
