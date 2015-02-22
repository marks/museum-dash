Stock http://shopify.github.com/dashing install plus:
- added dashing-contrib (https://github.com/QubitProducts/dashing-contrib) for its additions
- removed several jobs and dashboards that were not needed for this project
- be sure to define SOCRATA_APP_TOKEN in a .env file during local dev and set the environment variable on Heroku using the instructions at https://devcenter.heroku.com/articles/config-vars (heroku config:set SOCRATA_APP_TOKEN=123)


Data documentation: http://www.imls.gov/assets/1/AssetManager/MUDF_Documentation_2014q3.pdf