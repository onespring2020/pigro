import Config

config :db2file, Db2file.Repo,
  database: "ONEORCL",
  username: "bno",
  password: "bno0618",
  hostname: "onespring.co.kr",
  port: 6120,
  timeout: 2000_000,
  idle_interval: 1000_000,
  pool_size: 40
