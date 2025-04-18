#!/bin/bash

OPTIONS="plugin rp-pppoe.so
        usepeerdns
        persist
        defaultroute
        hide-password
        noauth
        replacedefaultroute
        noipdefault"

echo "user      => $1"
echo "password  => $2"

NewOPTIONS="$OPTIONS eth0 user '$1' password '$2'"

rm -f /etc/ppp/peers/REDCOM
echo $NewOPTIONS >> /etc/ppp/peers/REDCOM
pppd call REDCOM
echo "PPPоE создание конфигурации"
echo "----------------------------------"

testIP="redcom.ru"
while : ; do
  sleep 2
  if ping -c 1 $testIP &> /dev/null
    then
      echo -e "\e[32m$testIP - success\e[0m"
      break
    else
      echo -e "\e[31m$testIP - not available\e[0m"
  fi
done

echo "----------------------------------"

echo -e "\e[32minformation request\e[0m"
curl http://ip-api.com/line/?fields=city,as,query
echo "----------------------------------"
echo -e "\e[32mRX TX data\e[0m"
ip -s link show dev wlp2s0
echo "----------------------------------"
echo -e "\e[32mSpeed test \e[0m"
echo "$(curl -skLO https://git.io/speedtest.sh && chmod +x speedtest.sh && /bin/bash ./speedtest.sh --simple)"
echo "----------------------------------"
echo -n "Прервать соединение?"
read item

poff REDCOM
rm -f /etc/ppp/peers/REDCOM

package main

import (
	"fmt"
	"github.com/goccy/go-yaml"
)

func main() {
	yamlContent := `
# Конфигурация
app:
  name: MyApp  # Название
  port: 8080
`

	// Чтение с сохранением комментариев
	var node yaml.Node
	err := yaml.Unmarshal([]byte(yamlContent), &node)
	if err != nil {
		panic(err)
	}

	// Изменение данных
	var config map[string]interface{}
	err = yaml.Unmarshal([]byte(yamlContent), &config)
	if err != nil {
		panic(err)
	}
	config["app"].(map[string]interface{})["port"] = 9090

	// Запись обратно с комментариями
	out, err := yaml.MarshalWithOptions(config, yaml.Indent(2), yaml.WithComment(node))
	if err != nil {
		panic(err)
	}

	fmt.Println(string(out))
}
