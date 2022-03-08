# Jekyll AutoRedirect Generator Plugin

**Work in progress, not functional yet**

*Jekyll plugin to silently generate redirects for pages and posts when they are renamed or moved.*

[![Build Status](https://travis-ci.org/jekyll/jekyll_auto_redirect.svg?branch=master)](https://travis-ci.org/jekyll/jekyll_auto_redirect)


## Installation

1. Add `gem 'jekyll_auto_redirect'` to your site's `Gemfile` and run `bundle install`.
2. If you are using a Jekyll version greater than or equal to 3.5.0, add the following to your site's `_config.yml`:

    ```yml
    plugins:
      - jekyll_auto_redirect
    ```
   Otherwise, if you are using a Jekyll version less than 3.5.0,
   use the `gems` key instead of `plugins`, like this:

    ```yml
    gems:
      - jekyll_auto_redirect
    ```


## Configuration

You can add an `auto_redirect` key in `_config.yml` to control it.
All implemented subkeys are shown below.

```yml
auto_redirect:
  - enabled: true  # Default value
  - dead_pages: [ _dead ]
  - dead_posts: [ collections/_dead ]
  - dead_urls: [
    - /blog/2013/2013-06-01-load-testing-scalacoursescom.html
    - /blog/2020/2020-08-16-new-jekyll-post.html
  ]
  - verbose: false  # Default value
```
All paths are assumed to be relative to the top-level directory, whether the paths start with a leading slash or not.

 * `enabled` controls whether the plugin is operational or not.
 * `verbose` controls informational output displayed on the console


### HTTP 404
Jekyll can be configured to generate a [custom HTTP 404 page](https://jekyllrb.com/tutorials/custom-404-page/). This plugin has subkeys to specify directories containing dead pages and posts, as well as URL paths which should resolve to HTTP 404.
 * `dead_pages`: array of directory names to scan for pages that should resolve to HTTP 404.
 * `dead_pages`: array of directory names to scan for pages that should resolve to HTTP 404.
* `dead_urls`: array of URL paths that should resolve to HTTP 404.


## Usage

This plugin strives to work automatically, without the user having to do anything. The first time that Jekyll generates the website, after the plugin was installed, causes the plugin to insert a new entry into the front matter of every page and post. The entry contains a unique ID for the page and looks like this:

```yml
auto_redirect_id: 43246cf2-5902-47de-8e44-a34ab05e8aeb
```

A file called `_auto_redirect.txt` is also created that contains a map of UUIDs to URL paths for every page and post. The entry contains a UUID. This allows pages and posts to be uniquely identified, and to track when pages are moved or renamed.


## Note on Use with GitHub Pages Gem
The GitHub Pages gem ignores all plugins included in the Gemfile.
If you only include `jekyll_auto_redirect` in the Gemfile without also including it in the `_config.yml` *the plugin will not work*.
This can be confusing because the official Jekyll docs state that plugins can be included in either the Gemfile or `_config.yml`.

When building a site that uses the GitHub Pages gem,
follow the instructions above and ensure that `jekyll_auto_redirect` is listed in the `plugins` array in `_config.yml`.


## Override default development settings

[Follow these instructions on Jekyll's documentation](https://jekyllrb.com/docs/usage/#override-default-development-settings).


## Developing locally

* Use `script/bootstrap` to bootstrap your local development environment.
* Use `script/console` to load a local IRB console with the Gem.


## Testing

1. `script/bootstrap`
2. `script/cibuild`


## Known Issues
If the front matter in pages and posts does not get updated when a file is moved:
1. Ensure `_config.yml` doesn't have `safe: true`. That prevents all plugins from working.
2. Ensure that there is no `jekyll_auto_redirect.rb` plugin in the `_plugin` folder.


## Contributing

1. Fork the project
2. Create a descriptively named feature branch
3. Add your feature
4. Submit a pull request
