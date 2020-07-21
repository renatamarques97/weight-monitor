[![Build Status](https://circleci.com/gh/renatamarques97/weight-monitor.svg?style=svg)](https://app.circleci.com/pipelines/github/renatamarques97/weight-monitor)

# Weight Monitor
This is a web solution for managing diets and
weight monitoring. The system allows the
registration and updating of a diet, which has a predetermined
beginning and end, in addition to the idealized weight.
During the diet period, the user must periodically inform his weight.
From that information, the system presents a graph of the
evolution of weight over the period of the diet.

### Ruby version
```
2.7.1
```

### Rails version
```
6.0.3
```

### Configuration
```shell
bundle install
yarn install
```

### Database creation
```shell
bundle exec rails db:setup
or
bundle exec rails db:create
bundle exec rails db:migrate
```

### Using Docker
Make sure that you have docker installed on your system.

```shell
# Let open the console container
$ docker-compose run --rm web bash

# Then run the setup script
$ DOCKER_SETUP=true bin/setup

# With that all the depencies will be installed and you can run the project with:
$ docker-compose up
```

### Initialize postgres
```shell
pg_ctl start
```

### How to run the test suite
```shell
bundle exec rspec
```

### Run the server
```shell
bundle exec rails server
```

