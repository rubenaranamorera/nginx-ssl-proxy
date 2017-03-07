#!/bin/bash
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and

# Env says we're using SSL
if [ -n "${ENABLE_SSL+1}" ] && [ "${ENABLE_SSL,,}" = "true" ]; then
  echo "Enabling SSL..."
  cp /usr/src/proxy_ssl.conf /etc/nginx/conf.d/proxy.conf
  if [ -n "${ENABLE_AUTO_CERTS+1}" ] && [ "${ENABLE_AUTO_CERTS,,}" = "true" ]; then
    . ./init.sh
  fi
else
  # No SSL
  cp /usr/src/proxy_nossl.conf /etc/nginx/conf.d/proxy.conf
fi

# If an htpasswd file is provided, download and configure nginx
if [ -n "${ENABLE_BASIC_AUTH+1}" ] && [ "${ENABLE_BASIC_AUTH,,}" = "true" ]; then
  echo "Enabling basic auth..."
   sed -i "s/#auth_basic/auth_basic/g;" /etc/nginx/conf.d/proxy.conf
fi

if [ -z "${TARGET_SERVICE+x}" ]; then
  TARGET_SERVICE="$TARGET_PORT_80_TCP_ADDR:$TARGET_PORT_80_TCP_PORT"
fi

# Tell nginx the address and port of the service to proxy to
sed -i "s/{{TARGET_SERVICE}}/${TARGET_SERVICE}/g;" /etc/nginx/conf.d/proxy.conf

echo "Starting nginx..."
nginx -g 'daemon off;'
