#!/usr/bin/env sh
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

#================= | GLOBAL VARS |
# URL List
file_links="onion.links"
# Temporary file
html_temp_file="/tmp/onion.html.temp"
# Final file
html_final="/var/www/html/onion.html"
# tor Proxy:port
proxy_and_port="127.0.0.1:9050"

#================= | CHECK |
# all software installed on the system?
# Need torsocks for run on tor and...
# httping "ping" .onion urls ;)
###########################################
for checkMe in 'tor' 'httping'; do
    if ! type $checkMe 1>/dev/null 2>/dev/null; then
        printf '%s\n' "You need $checkMe for continue."
        exit 1
    fi
done

# remove old temp file
rm $html_temp_file

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
        li{margin-top: 0.4%;}
    </style>
</head>
<body>
    <a href="/">← Retornar a página principal</a>
    <br>
    <h1 style="color: cyan;">Check Onion LINKS</h1>
<ul>
EOF
}

FOOTER()
{
    cat <<EOF >> "$html_temp_file"
</ul>
</body>
</html>
EOF
}

HEADER # Call function
echo "Último Update da lista: <time>$(date "+%H:%M %d/%b/%Y")</time></br>" >> "$html_temp_file"
echo "Atenção, a lista é atualizada a cada 2 horas" >> "$html_temp_file"
echo "<hr>" >> "$html_temp_file"
printf "\e[31;1m Scanning onions links...\e[m\n"
while read -r line; do
    if [ "$line" = "$(echo $line | grep "^#")" ]; then
        category=$(echo $line | cut -d '#' -f 2)
        echo "<h2>$category</h2>" >> $html_temp_file
        continue
    fi
    site_name=$(echo $line | cut -d '|' -f '1')
    site_url=$(echo $line | cut -d '|' -f '3')
    printf "\e[34;1m\t+ Scanning $site_name\e[m"
    # CHECK ONION SERVICE
    if httping -f -c 1 --proxy=$proxy_and_port "$site_url" 1>/dev/null 2>/dev/null; then
        printf "\e[32;1m\t+ [ON]\e[m\n"
        echo "<hr>" >> $html_temp_file
        echo "<summary><strong><a href=$site_url>$site_name</a> $site_url <b style='color: #0ec600;'>ONLINE</b></strong></summary>" >> $html_temp_file
        echo "</details>" >> $html_temp_file
        echo "<hr>" >> $html_temp_file
    else
        printf " \e[31;1m\t+ [OFF]\e[m\n"
        echo "<hr>" >> $html_temp_file
        echo "<summary><strong><a href=$site_url>$site_name</a> $site_url <b style='color: red;'>OFFLINE</b></strong></summary>" >> $html_temp_file
        echo "</details>" >> $html_temp_file
        echo "<hr>" >> $html_temp_file
    fi
done < "$file_links"
FOOTER # Call Function

# Big url lists will slow things down!
# So we mount everything in a temporary file and then move it to a final file.
cat "$html_temp_file" > "$html_final"

