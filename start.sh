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
# Конфигурация приложения
name: MyApp  # Название
hosts:
  - example.com  # Основной хост
`

	// 1. Парсим YAML в map (или структуру)
	var config map[string]interface{}
	err := yaml.Unmarshal([]byte(yamlContent), &config)
	if err != nil {
		panic(err)
	}

	// 2. Добавляем комментарии вручную
	comment := yaml.Comment{
		Line:   "  # Добавленный комментарий",
		Column: 4,
	}

	// 3. Сериализуем обратно с комментариями
	out, err := yaml.MarshalWithOptions(config,
		yaml.WithComment(comment),  // Добавляем комментарий
		yaml.Indent(2),            // Отступ в 2 пробела
	)
	if err != nil {
		panic(err)
	}

	fmt.Println(string(out))
}
package main

import (
	"fmt"
	"bytes"
	"github.com/goccy/go-yaml"
)

func main() {
	yamlContent := `
# Главный заголовок
app:
  name: MyApp  # Название
  port: 8080   # Порт
`

	// 1. Парсинг с комментариями
	var config map[string]interface{}
	dec := yaml.NewDecoder(bytes.NewReader([]byte(yamlContent)))
	dec.SetCommentRecursion(true)
	
	if err := dec.Decode(&config); err != nil {
		panic(err)
	}

	// 2. Чтение существующих комментариев
	comments := dec.CommentMap()
	fmt.Println("Комментарий к app.name:", comments[yaml.Path("$.app.name")].Line)

	// 3. Добавление нового поля с комментарием
	config["app"].(map[string]interface{})["debug"] = true
	newComment := &yaml.Comment{
		Line: "  # Режим отладки",
	}

	// 4. Сериализация
	out, err := yaml.MarshalWithOptions(config,
		yaml.WithComments(comments),      // Старые комментарии
		yaml.WithComment(newComment),    // Новый комментарий
		yaml.Indent(2),
	)
	if err != nil {
		panic(err)
	}

	fmt.Println(string(out))
}





package main

import (
	"fmt"
	"github.com/goccy/go-yaml"
)

func main() {
	yamlContent := `
# Конфигурация приложения
name: MyApp  # Название
hosts:
  - example.com  # Основной хост
`

	// 1. Парсим в map (сохраняет комментарии автоматически)
	var config interface{}
	err := yaml.UnmarshalWithOptions(
		[]byte(yamlContent),
		&config,
		yaml.CommentToMap(true), // Ключевая опция!
	)
	if err != nil {
		panic(err)
	}

	// 2. Модифицируем данные (пример добавления хоста)
	if m, ok := config.(map[string]interface{}); ok {
		hosts := m["hosts"].([]interface{})
		hosts = append(hosts, "backup.example.com")
		m["hosts"] = hosts
	}

	// 3. Сериализуем обратно с комментариями
	out, err := yaml.MarshalWithOptions(
		config,
		yaml.Indent(2),
		yaml.WithComment(), // Автоматически подтягивает комментарии из map
	)
	if err != nil {
		panic(err)
	}

	fmt.Println(string(out))
}
