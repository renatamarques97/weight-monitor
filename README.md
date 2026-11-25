[![Build Status](https://circleci.com/gh/code-master-it/MOVARA.svg?style=svg)](https://app.circleci.com/)
[![codecov](https://codecov.io/gh/code-master-it/MOVARA/branch/master/graph/badge.svg)](https://codecov.io/gh/code-master-it/MOVARA)

# MOVARA

MOVARA is a web platform for tracking weight, nutrition, diet plans and physical
activities. It brings health and fitness information into a single workspace,
helping users monitor progress, organize meal records and analyze workout history.

### Ruby version
```
4.0.9
```

### Rails version
```
8.0.5
```

### Configuration
```shell
bundle install
rails tailwindcss:install
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

### Development and asset rebuild

For normal development, start the Rails and Tailwind watchers through `bin/dev`:

```shell
bin/dev
```

This keeps compiled Tailwind and JavaScript assets updated while the server is running.

To rebuild assets after changing CSS, Tailwind configuration, SVG, or public assets:

```shell
bin/rails assets:clobber
bin/rails tailwindcss:build
bin/rails assets:precompile
```

For a clean Docker rebuild:

```shell
docker compose build --no-cache web
docker compose up web
```

If the browser continues showing an old asset, refresh with `Ctrl+F5`/`Cmd+Shift+R` or open the app in an anonymous/private window.

### Run with Docker

Prerequisites:

- Docker Desktop (or Docker Engine + Docker Compose)

Start the app (build images if needed):

```shell
docker compose up --build
```

Run in detached mode:

```shell
docker compose up -d --build
```

Open the app:

- http://localhost:3000

Useful commands:

```shell
# View logs
docker compose logs -f

# Stop containers
docker compose down

# Stop and remove volumes (resets database)
docker compose down -v

# Recreate only the web service after Dockerfile/ Gem changes
docker compose up --build web
```

Notes:

- The development stack starts PostgreSQL, Redis and Rails.
- The database is prepared automatically on container start.

## Platform Guide

### Account access

Create an account at [Sign up](http://localhost:3000/users/sign_up). Registration
requires a name, email address and password. Existing users can sign in at
[Sign in](http://localhost:3000/users/sign_in).

The account profile also allows users to configure preferred units for weight,
height and distance. MOVARA uses these preferences when displaying measurements.

### Dashboard

After signing in, the dashboard at [http://localhost:3000](http://localhost:3000)
provides an overview of your fitness data.

- **BMI:** Calculated from the most recent weight and the height saved in your
  account profile. If one of these values is unavailable, the dashboard displays
  `0`.
- **Most recent weight:** Shows the latest recorded weight and the variation
  over the previous 30 days, when sufficient history is available.
- **Weight goal:** Uses the initial and target weights from the most recent diet.
  The dashboard shows the completion percentage or a trophy once the target is
  reached. For maintenance plans, achievement is recognized when the current
  weight is within 0.5 kg of the target.
- **Weight and workout progress:** Interactive charts display your weight and
  workout history for configurable periods. The dashboard also summarizes monthly
  workout time.
- **Recent diets:** Lists the diets associated with the signed-in account.

All information shown on the dashboard belongs to the authenticated user.

### Diet plans

Use **New Diet** to create a nutritional plan. A diet contains:

- Initial and target weight;
- Start and end dates;
- Preferred weight unit (`kg` or `lbs`);
- Optional meals, with a food name and nutritional information.

Meals can be searched through the FatSecret food database. MOVARA can complete
serving and nutrition fields from the selected food result. Existing diet plans
can be viewed, edited or removed at any time.

### Meal diaries

The **Meal Diaries** feature lets you record everything consumed on a specific
date. Each diary entry can contain multiple meals and foods, including serving
amount and nutritional values. This provides a flexible record that is separate
from the recurring meals configured in a diet plan.

### Weight records

Weight records are available from the **Weights** section. Add a date and weight
value, and select whether it was entered in kilograms or pounds. Your preferred
unit is used for display, while historical entries remain available for tracking
changes over time.

### Workouts

The **Workouts** section supports running, cycling, walking, swimming,
weightlifting, yoga, soccer, basketball, tennis and martial arts. For each
activity, users can record a date, duration, calories and sports-specific details
such as distance, exercises, goals or sets won.

Workouts can be created, edited and deleted manually. Users can also connect a
Strava account, synchronize activities and disconnect the integration when
needed.

### AI fitness assistant

The **Chat** feature provides a conversational fitness assistant. Users can select
an objective such as weight loss, hypertrophy, running performance or general
health and send questions for tailored guidance. Conversations are associated
with the signed-in account.

### Author

[Renata Marques](https://www.linkedin.com/in/renata-marques-b27877119/)
[Alessandro Barros](https://br.linkedin.com/in/alessandro-barros-leal)

### License

Copyright © 2026 Renata Marques and Alessandro Barros. All rights reserved.

This software is proprietary and confidential. Unauthorized copying,
distribution, modification or commercial use is prohibited.
