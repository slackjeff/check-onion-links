# check-onion-links

## Files
* onion.links    = CSV File with (Name of onion service | small description | URL.onion)
* check_onion.sh = Script that checks onion.links and generate static page on /var/www/html/onion.html

## For execute every 2 hours, put on crontab
0 */2 * * * /usr/local/bin/check_onion.sh >/dev/null

## See
https://slackjeff.com.br/onion.html
