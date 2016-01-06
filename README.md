## Standup-Bot

#### Automated Standups for Slack Channels

Messaging tools like Slack changed our work world. Standup changed our meetings. Standup Bot keeps us accountable, tracks our goals, and got us to post our successes, plans, and upcoming challenges. We love it so much and we think you will too, so we're releasing it Open-Source.


### Slack Setup:
  * Create a new Bot in Slack if you don't have one
    * Visit `https://your-team.slack.com/services/new/bot`
  * Add your Bot to the Slack Channel
    * `/invite @your_bot`
  * Add a slash command integration (It allows to start the Standup typing /standup in Slack)
    * Visit `https://your-team.slack.com/services/new/slash-commands`
      * Set `/standup` as the command.
      * Set `http://your-app.herokuapp.com/api/start` as the url.
      * Set `GET` as the method.

#### Local Setup (After Slack Setup):
  * Clone the repository
    * `git clone git@github.com:sofetch/slack-standup-bot.git`
  * Install all the gems
    * `bundle install`
  * Create and migrate the DB
    * `rake db:create db:migrate`
  * Create a new .env file and associate the API Token of your Bot
    * `echo SLACK_API_TOKEN=your-token > .env`
  * Start a local server and then visit the Settings page
    * `rails s`
    * Visit `http://localhost:3000/settings`  Enter your Channel name and the Bot username.
  * Now you have everythig ready to start your first Standup
    * Visit `http://localhost:3000/api/start` or just type `/standup`.

#### Heroku Setup (After Slack Setup):
  * Clone the repository
    * `git clone git@github.com:sofetch/slack-standup-bot.git`
  * Associate your Heroku app and then push the master branch into Heroku
    * `heroku git:remote -a heroku-app-name`
    * `git push heroku master`
  * Run the Migrations
    * `heroku run rake db:migrate`
  * Associate the API Token of your Bot with the Application
    * `heroku config:set SLACK_API_TOKEN=your-token`
  * Visit the Settings page
    * `http://your-app.herokuapp.com/settings` Enter your Channel name and the Bot username.
  * Now you have everythig ready to start your first Standup
    * Visit `http://your-app.herokuapp.com/api/start` or just type `/standup`.

> Be really careful when assigning the Channel name and the Bot username, the app won't work if one of them is incorrect.


#### Commands:
  * `-skip`  Skips your turn until the end of standup.
  * `-yes`   Agrees to start your standup.
  * `-help`  Displays standup-bot commands in your channel.
  * `-edit: #(1,2,3)` Edit your answer for the day.
  * `-delete: #(1,2,3)` Delete your answer for the day.

  * ##### Admin only Commands (Admin is determined by user who enters "-Start" Command)
    * `-vacation: @user`  Skip users standup for the day.
    * `-skip: @user`  Place user at the end of standup.
    * `-n/a: @user`   Skips users standup for the day
    * `-quit-standup` Quit standup.
    * `-start` Begins standup.


##### How to make a pull request:

1. Fork it ( https://github.com/sofetch/slack-standup-bot/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
