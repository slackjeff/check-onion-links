#!/bin/sh
#=====================================================================#
# AUTHOR: Jefferson Carneiro <Slackjeff>
# Desc  : Simple script for check .onions and generate static page.
#
# 4 RUN.
# Need tor run on machine, tor + httping!
#
###### TODO
# some onions services use https, httping can't handle https + proxy
# torsocks + httping is VERY SLOW.
#=====================================================================#

# For Cron
PATH=/usr/local/bin:/bin:/usr/bin

#================= | GLOBAL VARS |
# URL List
file_links="/var/www/onion.links"

# Temporary file
html_temp_file="/tmp/onion.html.temp"

# Final file
html_final="/var/www/html/onion.html"

# tor Proxy:port
proxy_and_port="127.0.0.1:9050"

#================= | CHECK |
# Do you have all needed software installed on the system?
# - Tor
# - cURL
###########################################

needed_binaries=('tor' 'curl')
for current_binary in "${needed_binaries[@]}"; do
	if ! type $current_binary 1>/dev/null 2>/dev/null; then
		printf '%s\n' "You need $current_binary installed in your system to continue."
		exit 1
	fi
done

#================= | FUNCTIONS |
HEADER()
{
    cat <<EOF > "$html_temp_file"
<!DOCTYPE html>
<html>
<head>
    <title>Check Onion Links</title>
    <meta charset='UTF-8'>
    <meta name="description" content="Check Onion Links">
    <meta name="keywords" content="Onion Links">
    <meta name="author" content="Jefferson Carneiro">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body{background-color: #0b0b0b; color: magenta; font-size: 1.2em; margin: 0 auto; max-width: 60%;}
        a:link{color: white;}
        li{margin-top: 1.4%;}
    </style>
</head>
<body>
    <a href="/">← Retornar a página principal</a>
    <br>
    <h1 style="color: cyan;">Check Onion LINKS</h1>
    <h3>Os links abaixos são selecionados manualmente e tentamos selecionar serviços que são voltados a tecnologia, segurança e tópicos deste nicho. NÃO é responsabilidade minha sobre o conteúdo ou pensamento dos links abaixo.</h2>
    <p>Último Update da lista: <time>$(date "+%H:%M %d/%b/%Y")</time></p>
    <hr>
<ul>
EOF
}

FOOTER()
{
    cat <<EOF >> "$html_temp_file"
</ul>
<hr>
<p>Check Onions é um script em Shell, se você deseja colaborar com o código ou adicionando novos serviços na lista mande um pull: <a href="https://github.com/slackjeff/check-onion-links" target='_blank'>https://github.com/slackjeff/check-onion-links</a></p>
</body>
</html>
EOF
}

HEADER # Call function
printf "\e[31;1m Scanning onions links...\e[m\n"
while read -r line; do
    if [ "$line" = "$(echo $line | grep "^#")" ]; then
        category=$(echo $line | cut -d '#' -f 2)
        echo "<h2 style='color: yellow;'>$category</h2>" >> $html_temp_file
        continue
    fi
    site_name=$(echo $line | cut -d '|' -f '1')
    site_url=$(echo $line | cut -d '|' -f '3')
    printf "\e[34;1m\t+ Scanning $site_name\e[m"
    # CHECK ONION SERVICE
    # It sends HEAD method/verb to the target URL through 
    # Tor using socks5 proxy. It also waits for 10s before
    # giving timeout. 
    # Moreover, it accepts self-signed certificate to avoid false negative.
    if curl -kI --connect-timeout 10 --socks5-hostname $proxy_and_port "$site_url" 1>/dev/null 2>/dev/null; then
        printf "\e[32;1m\t+ [ON]\e[m\n"
        echo "<li><strong><a href=$site_url>$site_name</a> $site_url <b style='color: #0ec600;'>ONLINE</b></strong></li>" >> $html_temp_file
    else
        printf " \e[31;1m\t+ [OFF]\e[m\n"
        echo "<li><strong><a href=$site_url>$site_name</a> $site_url <b style='color: red;'>OFFLINE</b></strong></li>" >> $html_temp_file
    fi
done < "$file_links"
FOOTER # Call Function

# Big url lists will slow things down!
# So we mount everything in a temporary file and then move it to a final file.
cat "$html_temp_file" > "$html_final"

# remove old temp file
#rm $html_temp_file
