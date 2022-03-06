# Jekyll AutoRedirect Generator Plugin

**Work in progress, not functional yet**

*Jekyll plugin to silently generate a file containing original paths to published paths for your Jekyll site*

[![Build Status](https://travis-ci.org/jekyll/jekyll_auto_redirect.svg?branch=master)](https://travis-ci.org/jekyll/jekyll_auto_redirect)

## Usage

1. Add `gem 'jekyll_auto_redirect'` to your site's `Gemfile` and run `bundle install`.
2. Add the following to your site's `_config.yml`:

```yml
plugins:
  - jekyll_auto_redirect
```

💡 If you are using a Jekyll version less than 3.5.0, use the `gems` key instead of `plugins`, like this:
```yml
gems:
  - jekyll_auto_redirect
```

## Note on Use with GitHub Pages Gem
The GitHub Pages gem ignores all plugins included in the Gemfile.
If you only include `jekyll_auto_redirect` in the Gemfile without also including it in the `_config.yml` *the plugin will not work*.
This can be confusing because the official Jekyll docs state that plugins can be included in either the Gemfile or `_config.yml`.

When building a site that uses the GitHub Pages gem,
follow the instructions above and ensure that `jekyll_auto_redirect` is listed in the `plugins` array in `_config.yml`.

:warning: If you are using Jekyll < 3.5.0 use the `gems` key instead of `plugins`.


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
