aptitude install python3 meld inkscape python3-flask python-yaml libxml2-utils git

cp system/osm-themes-webserver.service /etc/systemd/system

systemctl enable osm-themes-webserver.service
systemctl start osm-themes-webserver.service
