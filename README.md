# Wdbomber

A tool to load test webdriver infrastructure

## Installation

```mix escript.install https://github.com/mpugach/wdbomber-eli/raw/0.1.3/wdbomber```

or

```docker pull mpugach/wdbomber```

## Usage

```wdbomber URL ITERATIONS CONCURRENCY ACTIONS OPTIONS```

or

```docker run --rm mpugach/wdbomber:0.1.3 URL ITERATIONS CONCURRENCY ACTIONS OPTIONS```

ITERATIONS, CONCURRENCY and ACTIONS should be numbers

OPTIONS:

* -h, --help                 Show this help message.
* -r REGION, --region=REGION Specify a region.
* -v, --version              Show version.
