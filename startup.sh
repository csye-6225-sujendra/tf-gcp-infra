#!/bin/bash

# Navigate to the webapp directory
cd /tmp/webapp

# Create the .env file with the required values
cat <<EOF > .env
DB_HOST=${db_host}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
DB_PORT=${db_port}
DB_DIALECT=${db_dialect}
DB_POOL_MAX=${db_pool_max}
DB_POOL_MIN=${db_pool_min}
DB_POOL_ACQUIRE=${db_pool_acquire}
DB_POOL_IDLE=${db_pool_idle}
EOF

# Set the correct permissions for the .env file
chmod 655 /tmp/webapp/.env

# Start or restart the service
sudo systemctl start csye6225
