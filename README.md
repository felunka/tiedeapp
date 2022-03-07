# Tiedeapp

[![CD](https://github.com/felunka/tiedeapp/actions/workflows/cd.yml/badge.svg)](https://github.com/felunka/tiedeapp/actions/workflows/cd.yml)

This web application is written in ruby on rails 7 and ruby 3.0.3 and is desinged to help with the signup process of the Familentag. Users can signup with a unique token or via thier user profile. Admin users can see registrations and create new events.

The application is fully dockerised using docker-compose to bundle the application with a postgresql database.

## Infrastructure

This repo is intended to be used with [this traefik setup](https://github.com/conscribtor/docker-traefik-letsencrypt). The reverse proxy handles obtaining a valid certificate and enforcing TLS.

## Mail

Sending mails is handled via the sendgrid SMTP server. The free license only allows for 100 mails per day.
