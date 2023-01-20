    #!/bin/bash
    yum -y update
    yum -y install httpd
    systemctl start httpd
    systemctl enable httpd    
    echo '<h2 style="color:rgb(100, 27, 27);">Terraform deployed web server-01.</h2>' > /var/www/html/index.html