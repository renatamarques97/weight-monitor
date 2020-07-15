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

