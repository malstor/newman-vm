###############################################################################
#
#  Script which will configure NGinx service as a reverse proxy for Newman.
#
#  WARNING:  This configuration is an example implementation and is in no way 
#            a complete security solution.
# 
#  This will include https encryption, basic auth, for 
#  --Newman flask application ReST layer 
#  --Elastic Search and plugins
#  --Kibana service
#
#
###############################################################################


sudo apt-get update
sudo apt-get -y install nginx

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/cert.key -out /etc/nginx/cert.crt

sudo cp artifacts/newman--ssl_ba_rproxy /etc/nginx/sites-available/newman
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/newman /etc/nginx/sites-enabled/newman

sudo cp artifacts/elastic-kibana--ssl_ba_rproxy /etc/nginx/sites-available/elastic
sudo ln -s /etc/nginx/sites-available/elastic /etc/nginx/sites-enabled/elastic

sudo mkdir -p /var/www/newman/
sudo chown -R vagrant:vagrant /var/www/newman



RED='\033[0;31m'
NC='\033[0m'

echo "========================================================================================"
echo "Please read carfully:  You must add users to the 3 password files to allow basic auth.  "
echo "The 3 files are:                                                                        "
echo "/etc/nginx/.newman.htpasswd      --User access to Newman app                            "
echo "/etc/nginx/.elastic.htpasswd     --User access to Elasticsearch ReST layer              "
echo "/etc/nginx/.kibana.htpasswd      --User access to Kibana                                "
echo "                                                                                        "
echo "  e.g.  To add vagrant user to .newman.htpasswd file do the following:                  "
echo -e "${RED}Add users to .htpasswd file using the following two commands:${NC}             "
echo "sudo sh -c \"echo -n 'vagrant:' >> /etc/nginx/.newman.htpasswd\"                        "
echo "sudo sh -c \"openssl passwd -apr1 >> /etc/nginx/.newman.htpasswd\"                      "
echo "...repeat for each user, granting access to the respective .htpasswd files.             "
echo "========================================================================================"


#  Add users to .htpasswd will prompt for passwd
#  e.g. vagrant users / pass
#  sudo sh -c "echo -n 'vagrant:' >> /etc/nginx/.htpasswd"
#  sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
#  ...repeat
#


