# Harpoon

A simplified version of a tool similar to webhook.site, built with Elixir and Phoenix LiveView.
This tool allows users to easily inspect HTTP requests in real-time.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)

## Introduction

This is a simple tool built using Elixir and Phoenix LiveView, allowing users to create temporary endpoints to inspect and monitor HTTP requests.
The tool is intended for testing, debugging, and monitoring webhooks, APIs, and other HTTP requests in real-time.

## Features

- Create temporary endpoints for testing and monitoring HTTP requests.
- Inspect HTTP requests in real-time using Phoenix LiveView.
- Store request data in a PostgreSQL database for future analysis and reference.
- Lightweight and easy to use.

## Prerequisites

### Docker Version
- Docker
- Docker Compose

### Local Version
- Elixir
- Erlang
- PostgreSQL

## Installation

To install Elixir/Erlang we do recommend using [asdf](https://asdf-vm.com/).

After installing asdf, you can run those following commands to install Elixir/Erlang:
```
# enable elixir/erlang plugins on asdf
asdf plugin add elixir
asdf plugin add erlang

# clone the repo
git clone https://github.com/aschiavon91/harpoon.git && cd harpoon

# install version from '.tool-versions' file
asdf install
```

### Dev setup

```bash
docker compose -f docker-compose-dev.yaml up -d
mix setup
```

or using [just](https://github.com/casey/just)
```bash
just start_dev
```

### Prod setup

Change the value of 'SECRET_KEY_BASE' env in the .prod.env file, you can run `mix phx.gen.secret 64` to generated a secret for you.

```bash
docker compose -f docker-compose.yaml up -d
```

or using [just](https://github.com/casey/just)

```bash
just start_prod
```

## Usage

Browser to `http://localhost:4000/` and you should be redirected to `http://localhost:4000/?sid=?<some_uuid>`.

Then, you can start making HTTP requests to `http://localhost:4000/<some_id>`, and you should start seeing the requests in the dashboard.
