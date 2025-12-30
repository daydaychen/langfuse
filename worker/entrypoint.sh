#!/bin/sh

# Run cleanup script before running migrations
# Check if DATABASE_URL is not set
if [ -z "$DATABASE_URL" ]; then
    # Check if all required variables are provided
    if [ -n "$DATABASE_HOST" ] && [ -n "$DATABASE_USERNAME" ] && [ -n "$DATABASE_PASSWORD" ]  && [ -n "$DATABASE_NAME" ]; then
        # Construct DATABASE_URL from the provided variables
        DATABASE_URL="postgresql://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}/${DATABASE_NAME}"
        export DATABASE_URL
    else
        echo "Error: Required database environment variables are not set. Provide a postgres url for DATABASE_URL."
        exit 1
    fi
    if [ -n "$DATABASE_ARGS" ]; then
      # Append ARGS to DATABASE_URL
    	DATABASE_URL="${DATABASE_URL}?$DATABASE_ARGS"
    	export DATABASE_URL
    fi
fi

# Check REDIS_PORT - if it's a variable name (not a valid port), resolve it
if [ -n "$REDIS_PORT" ]; then
    # Check if REDIS_PORT is a valid port number (1-65535)
    case "$REDIS_PORT" in
        ''|*[!0-9]*|*[!0-9]) 
            # Not a valid port number, treat as variable name and resolve it
            if [ -n "$(eval echo \${$REDIS_PORT})" ]; then
                REDIS_PORT="$(eval echo \${$REDIS_PORT})"
                export REDIS_PORT
            fi
            ;;
        *)
            # Valid port number, keep as is
            ;;
    esac
fi

# Run the command passed to the docker image on start
exec "$@"
