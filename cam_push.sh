#!/bin/bash
read -p 'CAM Push Ticket #: ' ticketnum
git checkout -b u/`whoami`/CAM-${ticketnum}-cam-push
vim ~/puppet/modules/redshift/data/ecosystem/prod.yaml 
