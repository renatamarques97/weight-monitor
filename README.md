[![Build Status](https://circleci.com/gh/renatamarques97/weight-monitor.svg?style=svg)](https://app.circleci.com/pipelines/github/renatamarques97/weight-monitor)

# Weight Monitor
This is a web solution for managing diets and
weight monitoring. The system allows the
registration and updating of a diet, which has a predetermined
beginning and end, in addition to the idealized weight.
During the diet period, the user must periodically inform his weight.
From that information, the system presents a graph of the
evolution of weight over the period of the diet.

### [Production App](https://weight-monitor-app.herokuapp.com/)

### Ruby version
```
3.1.3
```

### Rails version
```
7.1.3
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

## Documentation

You will need an account to use the platform,
you can create an account here: `http://localhost:3000/users/sign_up`,
it requires `name`, `email` and `password`.

If you already have an account, you can sign in here: `http://localhost:3000/users/sign_in`.

After you enter your account, you will see your dashboard (`http://localhost:3000/`),
contains your `IMC` (`0` as default), your `Diets`, your `Goal` and your `Progress`.

Dashboard:

- [Extra] IMC is calculated by your latest weight and your height.
- You can see a list of your Diets in the second session or create a new one.
- [Extra] Your `goal` is the target weight of your diet, you achieve the goal
when your target weight is equal to your current weight, you receive a trophy
when this happens (clock as default).
- Progress is a chart of your weight during time.
- Your dashboard only shows your informations, don't worry, no one (expect you)
is allowed to view your confidential information.

Diets:

You can create a new diet in the menu button (`new diet`), a diet tracks your meals
during day, you will need to inform your current weight, target weight, the start date,
the end date, your height (for IMC purpose) and what you eat during the day.
Remember that you are always able to edit or delete an existing diet and create a new one
whenever you want.

Weight Progress:

Your weight progress is represented by a chart, you can inform your weight once a day, everyday.
To update your weight, you will need the value (kg) and the date, that's all.

### Author

[Renata Marques](https://www.linkedin.com/in/renata-marques-b27877119/)

### License

This project is licensed under the MIT License
