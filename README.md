# Tiedeapp

This web application is written in ruby on rails 6 and is desinged to help with the signup process of the Familentag. Users can signup with a unique token or via thier user profile. Admin users can see registrations and create new events.

## Infrastructure

This repo is intended to be used with [this traefik setup](https://github.com/conscribtor/docker-traefik-letsencrypt). The reverse proxy handles obtaining a valid certificate and enforcing TLS.
