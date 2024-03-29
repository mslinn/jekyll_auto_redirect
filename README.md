# Jekyll AutoRedirect Generator Plugin [![Gem Version](https://badge.fury.io/rb/jekyll_auto_redirect.svg)](https://badge.fury.io/rb/jekyll_auto_redirect)

## **Work in progress, not functional yet**

*Jekyll plugin to silently generate redirects for pages and posts when they are renamed or moved.*

More information is available on my web site about
[my Jekyll plugins](https://www.mslinn.com/blog/2020/10/03/jekyll-plugins.html).


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

You can add an `auto_redirect` key in `_config.yml` to control the plugin.
All possible subkeys are shown below.

```yml
auto_redirect:
  - enabled: true  # Default value
  - dead_page_dirs: [ _dead ]
  - dead_post_dirs: [ collections/_dead ]
  - dead_urls: [
    - /blog/2013/2013-06-01-load-testing-scalacoursescom.html
    - /blog/2020/2020-08-16-new-jekyll-post.html
  ]
```

All paths are assumed to be relative to the top-level directory, whether the paths start with a leading slash or not.

* `enabled` controls whether the plugin will process pages and posts that have been moved or deleted.
* `verbose` controls informational output displayed on the console.


### HTTP 404

Jekyll can be configured to generate a [custom HTTP 404 page](https://jekyllrb.com/tutorials/custom-404-page/).
This plugin has subkeys to specify directories containing dead pages and posts,
as well as URL paths that should resolve to HTTP 404.

* `dead_page_dirs`: array of directory names to scan for pages that should resolve to HTTP 404.
* `dead_post_dirs`: array of directory names to scan for posts that should resolve to HTTP 404.
* `dead_urls`: array of URL paths that should resolve to HTTP 404.


## Usage

This plugin strives to work automatically, without the user having to do anything.
Once the plugin is installed, each time Jekyll generates the website,
the plugin will insert a new entry into the front matter of every page and post.
The entry contains a unique ID (UUID) for the page and looks like this:

```yml
auto_redirect_id: 43246cf2-5902-47de-8e44-a34ab05e8aeb
```

A file called `_auto_redirect.txt` is also created that contains a map of UUIDs to URL paths for every page and post.
The UUIDs allow pages and posts to be uniquely identified, and to automatically generate page stubs
containing HTTP 404 redirects when pages are moved or renamed.


## Note on Use with GitHub Pages Gem

The GitHub Pages gem ignores all plugins included in the Gemfile.
If you only include `jekyll_auto_redirect` in the Gemfile without also including it in the `_config.yml`
*the plugin will not work*.
This can be confusing because the official Jekyll docs state that plugins can be included
in either the Gemfile or `_config.yml`.

When building a site that uses the GitHub Pages gem,
follow the instructions above and ensure that `jekyll_auto_redirect` is listed in the `plugins` array in `_config.yml`.


## Development

After checking out the repo, run `bin/setup` to install dependencies.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Install development dependencies like this:
```
$ BUNDLE_WITH="development" bundle install
```

### Build and Install Locally

To build and install this gem onto your local machine, run:

```shell
$ bundle exec rake install
```

examine the newly built gem:

```shell
$ gem info jekyll_auto_redirect

*** LOCAL GEMS ***

jekyll_auto_redirect (1.0.0)
    Author: Mike Slinn
    Homepage:
    https://github.com/mslinn/jekyll_auto_redirect
    License: MIT
    Installed at: /home/mslinn/.gems

    Generates Jekyll logger with colored output.
```


### Build and Push to RubyGems

To release a new version,

  1. Update the version number in `version.rb`.
  2. Commit all changes to git; if you don't the next step might fail with an unexplainable error message.
  3. Run the following:

     ```shell
     $ bundle exec rake release
     ```

     The above creates a git tag for the version, commits the created tag,
     and pushes the new `.gem` file to [RubyGems.org](https://rubygems.org).


### Override default development settings

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


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
