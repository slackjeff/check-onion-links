# check-onion-links

## Help
consider adding onion service on onion.links to help. It is not allowed in any way to add harmful content such as (pornograph*, drug*, weapon*) etc.
To help, send pull request =)


## Files
* onion.links    = CSV File with (Name of onion service | small description | URL.onion)
* check_onion.sh = Script that checks onion.links and generate static page on /var/www/html/onion.html

## For execute every 2 hours, put on crontab
0 */2 * * * /usr/local/bin/check_onion.sh >/dev/null

## See
https://slackjeff.com.br/onion.html
