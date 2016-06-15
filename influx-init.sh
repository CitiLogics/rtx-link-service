#!/bin/bash
 
usage() { echo "Setup Influx admin user and link to Grafana. Usage: $0 -u user -p password" 1>&2; exit 1; }

while getopts "u:p:" opt; do
  case $opt in
    u)
      echo "User is: $OPTARG" >&2
      user=$OPTARG ;;
    p)
      echo "Password is: $OPTARG" >&2 
      pass=$OPTARG ;;
    *)
      usage ;;
    
  esac
done
shift $((OPTIND-1))

if [ -z "${user}" ] || [ -z "${pass}" ]; then
    usage
fi


echo "Creating Influx root user"
curl -XPOST 'http://localhost:8086/query?' \
  --data-urlencode "q=CREATE USER ${user} WITH PASSWORD '${pass}' WITH ALL PRIVILEGES"
echo " "

echo "Creating Influx DB"
curl -XPOST 'http://localhost:8086/query?' \
  -u ${user}:${pass} \
  --data-urlencode "q=CREATE DATABASE link_flux"
echo " "

echo "Linking Data Source in Grafana"

cat <<DATASOURCE > ds.json
    {
      "name":"LINK-INFLUX",
      "type":"influxdb",
      "url":"http://influx:8086",
      "access":"proxy",
      "isDefault":true,
      "database":"link_flux",
      "user":"${user}",
      "password":"${pass}"
    }
DATASOURCE

curl "http://admin:admin@localhost:3000/api/datasources" \
  -X POST -H "Content-Type: application/json" \
  --data-binary "@ds.json"
echo " "
rm ds.json