const colors = require("tailwindcss/colors");
const plugin = require("tailwindcss/plugin");

module.exports = {
  content: [
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    "./js/**/*.js",
    "../deps/petal_components/**/*.*ex",
    "../deps/petal_framework/**/*.*ex",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        primary: colors.teal,
        secondary: colors.orange,
        success: colors.green,
        danger: colors.red,
        warning: colors.yellow,
        info: colors.sky,
        gray: colors.gray,
      },
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),

    // If you have used `phx-feedback-for` this plugin allows you to do something like `phx-no-feedback:border-zinc-300` on an input. The input border will be zinc-300 unless it has been touched (clicked on). Clicking on the form input removes the `phx-no-feedback` on the element which has the `phx-feedback-for` attribute - usually a parent of the input.
    // Docs: https://hexdocs.pm/phoenix_live_view/form-bindings.html#phx-feedback-for
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])
    ),

    // When you use `phx-click` on an element and click it, the class "phx-click-loading" is applied.
    // With this plugin we can do things like show a spinner when loading.
    // Example usage:
    //     <.button phx-click="x">
    //       <div class="phx-click-loading:hidden">Click me!</div>
    //       <.spinner class="hidden phx-click-loading:!block" />
    //     </.button>
    // Docs: https://hexdocs.pm/phoenix_live_view/bindings.html#loading-states-and-errors
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),

    // When you use `phx-submit` on a form and submit the form, the 'phx-submit-loading` class is applied to the form.
    // Example usage:
    //     <.form :let={f} for={:user} phx-submit="x">
    //       <div class="hidden phx-submit-loading:!block">
    //         Please wait while we save our content...
    //       </div>
    //       <div class="phx-submit-loading:hidden">
    //         <.text_input form={f} field={:name} />
    //         <button>Submit</button>
    //       </div>
    //     </.form>
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),

    // When you use `phx-change` on a form and change the form, the 'phx-change-loading` class is applied to the form.
    // Example usage:
    //     <.form :let={f} for={:user} phx-change="x">
    //       <div class="hidden phx-change-loading:!block">
    //         Please wait while we save our content...
    //       </div>
    //       <div class="phx-change-loading:hidden">
    //         <.text_input form={f} field={:name} />
    //         <button>Submit</button>
    //       </div>
    //     </.form>
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),
  ],
};
