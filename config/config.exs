use Mix.Config

config :rwt, slack_bot_token: System.get_env("SLACK_BOT_TOKEN")

config :rwt,
       Rwt.Scheduler,
       jobs: [
         {"45 7 * * 1-5", {Rwt.Server, :schedule_tips, []}},
       ]
