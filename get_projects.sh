#!/bin/bash
# (C) Copyright 2024 Hewlett Packard Enterprise Development LP
set -eux


LOCATION="Geneva-EPC-PCE1"
SPACE="Hosted-Trial-EPCPCE1-Space"

ACCESS_TOKEN=$(curl -s -k -X POST \
  "${HPEGL_IAM_SERVICE_URL}/v1/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${HPEGL_USER_ID}" \
  -d "client_secret=${HPEGL_USER_SECRET}" \
  -d grant_type=client_credentials \
  -d scope=hpe-tenant | jq -r '.access_token')

echo ${ACCESS_TOKEN}


# Get Projects 
curl -s -k -X GET \
   "https://client.greenlake.hpe.com/api/metal/rest/v1/projects?space=${SPACE}&location=${LOCATION}" \
   -H "Authorization: ${ACCESS_TOKEN}" \
   -H "Space: ${SPACE}" 