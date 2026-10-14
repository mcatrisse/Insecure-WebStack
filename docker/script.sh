#!/bin/sh

## Install VSFTPD ##
echo "Install VSFTPD"
FTP_FOLDER="$PWD/vsftpd-2.3.4-infected"
make -C $FTP_FOLDER
# Deps #
mkdir -p /usr/share/empty /var/ftp/ 
/sbin/useradd -d /var/ftp ftp
chown root:root /var/ftp
chmod og-w /var/ftp
# Install
cp $FTP_FOLDER/vsftpd /usr/local/sbin/vsftpd
cp $FTP_FOLDER/vsftpd.8 /usr/local/man/man8
cp $FTP_FOLDER/vsftpd.conf.5 /usr/local/man/man5
cp $FTP_FOLDER/vsftpd.conf /etc
# Set password to FTP user
echo "ftp:supersecret" | /sbin/chpasswd

echo "Done VSFTPD!"

## MySQL ##
echo "Config MySQL..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';RENAME USER 'root'@'localhost' TO 'root'@'%';FLUSH PRIVILEGES;"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf
cat << EOF > /etc/mysql/conf.d/90-max-connections.cnf
[mysqld]
max_connections = 999999999
max_connect_errors = 999999999
EOF
echo "Done MySQL!"

## Nginx ##
cat << EOF > /var/www/html/README
AWS_ACCESS_KEY_ID=root
AWS_SECRET_ACCESS_KEY=mySuperSecureCredentialsNobodyCouldGuess
EOF

### Script part 2: Vulnerable Login Form ###

# Variables
DB_NAME="login_app"
DB_USER="root"        # Adjust for your MySQL username
DB_PASS="root"    # Adjust for your MySQL password


# Configure MySQL for login

echo "Setting up MySQL database and user..."
mysql -u root -p$DB_PASS <<EOF
DROP DATABASE IF EXISTS $DB_NAME;
CREATE DATABASE $DB_NAME;
USE $DB_NAME;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);
INSERT INTO users (username, password) VALUES ('admin', 'supersecure');
EOF

# Create a  vulnerable login PHP form
tee /var/www/html/login.php > /dev/null <<EOF
<?php
\$servername = "localhost";
\$username = "$DB_USER";
\$password = "$DB_PASS";
\$dbname = "$DB_NAME";

// Create connection
\$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

// Check connection
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}

if (\$_SERVER["REQUEST_METHOD"] == "POST") {
    \$username = \$_POST['username'];
    \$password = \$_POST['password'];

    // Vulnerable SQL query (Time-based SQL Injection)
    \$sql = "SELECT * FROM users WHERE username = '\$username' AND password = '\$password'";
    \$result = \$conn->query(\$sql);

    if (\$result->num_rows > 0) {
        \$row = \$result->fetch_row();
        echo "Login successful! - User:" . \$row[1];
    } else {
        echo "Invalid credentials!";
    }
}

\$conn->close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
</head>
<body>
    <h2>Login</h2>
    <form action="login.php" method="POST">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required>
        <br><br>
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required>
        <br><br>
        <input type="submit" value="Login">
    </form>
</body>
</html>
EOF

# Configure NGINX
echo "Configuring NGINX..."
tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.php;

    server_name _;
	
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
	
    location / {
        try_files \$uri \$uri/ =404;
    }

}
EOF