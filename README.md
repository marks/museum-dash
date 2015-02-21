Stock http://shopify.github.com/dashing install plus:
- added dashing-contrib (https://github.com/QubitProducts/dashing-contrib) for its additions
- removed several jobs and dashboards that were not needed for this project
- be sure to define SOCRATA_APP_TOKEN in a .env file during local dev and set the environment variable on Heroku using the instructions at https://devcenter.heroku.com/articles/config-vars (heroku config:set SOCRATA_APP_TOKEN=123)