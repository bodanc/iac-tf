#!/bin/bash

sudo yum -y install httpd
sudo systemctl start httpd.service && sudo systemctl enable httpd.service
