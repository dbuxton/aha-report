aha-report
==========

To ease reporting when using Aha.

### Development

To run locally and for OAuth redirects to work, we use localtunnel:

    npm install -g localtunnel coffee-script

Run the dev server:

    foreman start

There is a localtunnel subdomain hardcoded into the Procfile; Aha will not
accept alternatives as redirect urls.
