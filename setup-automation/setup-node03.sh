#!/bin/bash

setenforce 0

dnf install httpd nano -y



cat <<EOF | tee /var/www/html/index.html


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nothing to See Here</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            color: #333;
        }
        h1 {
            font-size: 3em;
            text-align: center;
        }
    </style>
</head>
<body>
    <h1>Nothing to See Here - Not Yet Anyway - Node03</h1>
</body>
</html>

EOF

systemctl start httpd

mkdir /backup
chmod -R 777 /backup
