if [ "$#" -ne 1 ]; then
  echo "Usage: $0 PORT"
  exit 1
fi

PORT="$1"

if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "PORT must be a non-negative integer."
  exit 1
fi

export RAILS_ENV=production

if [ -z "$SECRET_KEY_BASE" ]; then
  echo "SECRET_KEY_BASE not set, generating one."
  export SECRET_KEY_BASE=$(bin/rails secret)
  echo "...: $SECRET_KEY_BASE"
fi

PIDS=$(timeout 2s lsof -ti ":$PORT")
if [ -n "$PIDS" ]; then
  kill -9 $PIDS
fi

git pull
bundle config set --local path 'vendor/bundle'
bundle install
bin/rails db:migrate
bin/rails assets:precompile
bin/rails server -p "$PORT"
