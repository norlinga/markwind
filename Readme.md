# Testing Markdown Rendering With Talwindcss Prose

In which we set up a - tool chain? - to test TailwindCSSs' `prose` feature, rendering HTML generated from Markdown files.
The tool chain is composed of the following:

- Sinatra to provide a basic web server, shipping content from `./public`.  This will be useful when doing HTMX interactions (more on that in a second).
- Ruby script using the Kramdown gem to convert files from Markdown to HTML.
- Ruby Guard to automate the previous step via a filesystem watcher.
- TailwindCSS with the Typography plugin, rebuilding on change much like Guard using a filesystem watcher.
- All of the above running under `foreman` using a simple Procfile.

## Background

I am interested in exploring how a project making heavy use of TailwindCSS might include and elegantly render content derived from users.
Straight HTML interpolation from users is obviously a no-go.
Markdown is a great, easy to follow format that is readable in its raw form, and is relatively well known and understood.
It's an easy choice when offering users the ability to create content in an app, when the content should eventually become HTML.

Markdown doesn't offer the option to add classes to HTML tags - this would be a really bad feature / design choice at any rate.
Given that TailwindCSS requires utility tags for styling, the option to style plain markup seems to be default styling via Typography.
The TailwindCSS/Typography plugin offers a `prose` utility class that gives access to an entirely parallel stylesheet, still managed by TailwindCSS.
This collection of files and scripts streamlines the development of a custom Typography-prose stylesheet.

## Set Up Your Environment

Ensure you have NPM installed and make sure you have TailwindCSS and TailwindCSS/Typography installed:

```sh
npm install tailwindcss @tailwindcss/typography -g
```

Ensure you have a recent Ruby installed and install the Foreman gem, then Bundle:

```sh
gem install foreman
bundle install
```

From here, you should be able to run the tool chain using Foreman:

```sh
foreman start
```

## Using the Tool Chain for Development

With Foreman started you can direct your browser to [localhost:9292](localhost:9292) and view the default (index.html) page.
This page is served from `./public` by Sinatra and uses HTMX to load the processed and rendered Markdown file named `sample.md`, located in `./markdown_files`, into the `prose` section of `index.html`.

Any change to either `./public/index.html` or the TailwindCSS config file will be picked up by the NPX tailwindcss watcher and will create an updated CSS file in `./public/css/main.css`.
These changes are then reflected pretty quickly in the styles of the rendered web page which is kept up to date via HTMX polling.
Similarly, any changes to the content of the Markdown file will be automatically reflected in the `prose` block of `index.html`.
Any changes to `index.html` itself require the page to be reloaded in order to display.

Because Sinatra serves whatever's in `./public`, anything placed there automatically becomes available to the browser.
This means that any arbitrary HTML / HTMX page could be created in `./public` and any arbitrary Markdown file could be loaded into it using the same `prose` technique.
This allows running multiple experiments.
Examining `./public/index.html` and `./markdown_files/sample.md` should make it plain how to do this.

## The Whole Thing From Scratch

Assuming you have the prerequisites from the environment set up, as shown above, this whole thing can be assembled quickly by hand.  In a new directory:

```sh
bundle init
```

Replace the contents of the generated `Gemfile` with these contents:

```ruby
# frozen_string_literal: true

source "https://rubygems.org"

gem "sinatra"
gem "kramdown"

gem 'guard'
gem 'guard-shell'
```

and install the gems from the `Gemfile` as well as Foreman using Bundle:

```sh
bundle install
gem install foreman
```

Create the Markdown-to-HTML conversion script:

```sh
touch process_markdown.rb
```

with the following contents:

```ruby
# process_markdown.rb
require 'kramdown'

markdown_file = ARGV[0]

if File.basename(markdown_file).casecmp("index.md").zero?
  puts "The file 'index.md' will not be processed."
  exit
end

html_file = markdown_file.gsub('markdown_files', 'public').gsub('.md', '.html')

markdown_content = File.read(markdown_file)
html_content = Kramdown::Document.new(markdown_content).to_html

File.write(html_file, html_content)
```

The script above, the Guard file below, and the CSS file we'll set up shortly assume the presence of a few directories.
We'll go ahead and create all the needed directories now:

```sh
mkdir -p css markdown_files public/css
```

We'll need some Markdown in order to test the script.  Create the `sample.md` file inside the `./markdown_files` directory.
Give the `sample.md` file the following contents (or anything really):

```md
# This is from the sample markdown file!!!

hello

- lists are defined
- in several ways
- in Markdown.  This one is unordered.

What happens if we make a table?

| id | name      |
|--- |---        |
| 1  | Aaron     |
| 2  | Not Aaron |

And there we go!  Enjoy Markdown...ing.
```

We're using Guard to watch for changes to Markdown files to trigger renders as needed.  Configure Guard as follows:

```sh
bundle exec guard init
```

which will generate a `Guardfile`.  Replace its contents with:

```ruby
guard :shell do
  watch(%r{^markdown_files/(.+)\.md$}) do |m|
    system("ruby process_markdown.rb #{m[0]}")
  end
end
```

The `system` keyword above is provided from `guard-shell`, mentioned in the `Gemfile`.
We can test this part of the tool chain by adding the following line to a `Procfile` in the main directory:

```
markdown: bundle exec guard
```

The `markdown:` name is arbitrary and has been named so it relates to the service being run.
Now, we can see `Foreman` run the script:

```sh
foreman start
```

A file named `sample.html` will appear immediately in `./public`.
Any changes made to `sample.md` and saved will be shown immediately in `sample.html`.
Exit the running `foreman` session by pressing CTRL-C.

Create the Sinatra app which we'll use to serve pages and assets:

```sh
touch app.rb config.ru
```

Place the following in `config.ru`:

```ruby
require './app'

run Sinatra::Application
```

and place the following in `app.rb`:

```ruby
require 'sinatra'
```

This will serve assests from public by default, meaning that we don't need to do anything more to get .html, .css, and .js files to the browser.
We offer Sinatra instead of pulling files from the file system for the flexibility this provides us now and in the future.
Add the Sinatra web service to the `Procfile` by adding this line:

```
sinatra: rackup
```

The final step in assembling this tool chain requires setting up TailwindCSS.
Before we can start creating styles and applying them to `prose` blocks, we need to initialize TailwindCSS and install the Typography plugin:

```sh
npm install tailwindcss @tailwindcss/typography -g
```

NPM installs a utility called NPX which can execute NPM modules.
We'll use this to initialize TailwindCSS:

```sh
npx tailwindcss init
```

Replace the contents of the generated `tailwind.config.js` file with:

```json
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './public/index.html',
  ],
  theme: {
    extend: {
      typography: (theme) => ({
        DEFAULT: {
          css: {
            h1: {
              color: theme('colors.red.500'),
              fontWeight: theme('fontWeight.bold'),
            },
          },
        },
      }),
    },
  },
  plugins: [require('@tailwindcss/typography')],
}
```

Add a file named `main.css` to `./css` and give it the following contents:

```css
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';
```

Now test the TailwindCSS-driven CSS generation pipeline by adding the following to the `Procfile` (and restarting Foreman as necessary):

```
tailwind: npx tailwindcss -i ./css/main.css -o ./public/css/main.css --watch
```

Configured as shown, Tailwind will be running through NPX in a "watch" mode, which will cause it to re-run any time the config file is changed, or any file (or file pattern) that's defined in `content:` changes.
Running `Foreman` will generate a new CSS file in `./public/css` named `main.css`.

Our last step is to create the HTMX-powered HTML file that will show us our `prose` styles.
Create the file `index.html` in `./public` and replace its contents with:

```html
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TailwindCSS Typography Testing</title>

  <link rel="stylesheet" href="css/main.css">
  <script src="/htmx-1.9.5.js"></script>

</head>
<body>

  <header class="bg-slate-200 mb-10"><h1 class="text-lg p-6">Hello from index.html</h1></header>

  <article class="prose lg:prose-xl" hx-get="sample.html" hx-trigger="load" hx-poll="5s">
    Loading...
  </article>
  
</body>
</html>
```

Restart `Foreman` and direct your browser to [localhost:9292](localhost:9292).
You page will show two <h1> sections - one with a default dark font.
The `prose` wrapped <h1> coming from `sample.md` will have a default style applied, carrying a red font color.