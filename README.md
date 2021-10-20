# Food find

[![CD](https://github.com/felunka/food_find/actions/workflows/cd.yml/badge.svg)](https://github.com/felunka/food_find/actions/workflows/cd.yml)

This is a very basic web application written in ruby on rails 6 to help find something to cook for dinner. You can setup your favorite foods and add tags to them.
Using the tags you can choose a random meal every day.

## Infrastructure

This repo is intended to be used with [this traefik setup](https://github.com/conscribtor/docker-traefik-letsencrypt). The reverse proxy handles obtaining a valid certificate and enforcing TLS.

## Future plans

The project is still WiP. In the future the user should be abple to add a description, shopping list and pictures to the food items. Also some kind of authentication might be necessary.
