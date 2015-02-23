aha-report
==========

To ease reporting when using Aha.

### Development

To run locally and for OAuth redirects to work, we use localtunnel. Use `npm`
to install dev dependencies:

    npm install

Run the dev server:

    foreman start

There is a localtunnel subdomain hardcoded into the Procfile; Aha will not
accept alternatives as redirect urls. You will have to create your own Aha
application and set redirect urls if you want to mess around with that:

[https://secure.aha.io/oauth/applications](https://secure.aha.io/oauth/applications)