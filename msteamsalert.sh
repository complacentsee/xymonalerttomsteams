#!/bin/bash
####################################################################################
# THIS SCRIPT TAKES A AN INCOMING XYMON ALERT AND PROCESSES IT INTO A
# MICROSOFT TEAMS ADAPTIVE CARD SEND OVER A WEBOOK. 
# WRITTEN BY: ADAM TRAEGER
# DATE: 1/30/2023
# 
# TO USE, ADD A CONFIGURATION TO CALL THE SCRIPT IN alerts.cfg CONFIGURATION
# THE PARAMETER IMMEDIATELY FOLLOWING THE SCRIPT NAME IS THE RECPIENT WHICH
# WILL BE PASSED INTO THE $RCPT ENVAR
# THE SCRIPT MUST BE ABLE TO BE EXECUTED AS YOUR XYMON USER
#
# HOST=xymon-docker SERVICE=disk,ports COLOR=red 
#    SCRIPT /var/lib/xymon/xymontomssteams.sh example FORMAT=SCRIPT 
#
#####################################################################################
#  USER CONFINGURATION STARTS HERE, CONFIGURE YOUR RECPIENT GROUPS INTO THE CASE
#  STATEMENT BELOW. URI SHOULD BE IN THE FOLLOWING FORMAT:
# 'https://outlook.office.com/webhook/<some-long-uid>@<another-uid>/IncomingWebhook/<one-more-uid>/<the-final-uid>'
#
####################################################################################
case $RCPT in
#  example)
#    URI='https://outlook.office.com/webhook/<some-long-uid>@<another-uid>/IncomingWebhook/<one-more-uid>/<the-final-uid>'
#    ;;
  *)
    echo "No defined recpient"
    exit
    ;;
esac

###################################################################################
# END USER CONFIGURATION
###################################################################################

# Setup functions prior to being called
function set_imagedata() {
  local color=$1
  case $color in
    green)
      export imagedata="data:image/gif;base64,R0lGODlhEAAQAPMAAAAAAABg"` 
	      `"AAB0AACGAACQAACcAAC5AADJAAD2AAAAAAAAAAAAAAAAAAAAAAAAAAA"` 
	      `"AACH5BAEAAAkALAAAAAAQABAAAARWMMkJap1YVoTOGVcGcF5hDgGAja"` 
	      `"Xpoqp2GEBB2zWoIcbt56kEwIAr3gYC1dAkYDqRSqJrekoKB1QqTIMFE"` 
	      `"KaAgY7btYS3FLFaHRQBBHBBKpbRmOv4fAQAOw=="
      ;;
    yellow)
      export imagedata="data:image/gif;base64,R0lGODlhEAAQAPMNAAAAAP+K"` 
	      `"AP+iAP++AP/XAP/bAP/jAP/3AP/7Of+atf/7pf+27//b/////wAAAAA"` 
	      `"AACH5BAEAAA4ALAAAAAAQABAAAARn0MkJap1Y1qYQGlcGNJZhBQAGKG"` 
	      `"PDtC9KISPzki+oKccI3D/AQAZA9EiLWnIgSBVNjEXiJxU2HYCDwVThA"` 
	      `"gpM52BL3hbOwxR20Nu2tzrNYJwVVtKqOUE4x4sAAoECKGoZGhaFhooZ"` 
	      `"EQA7"
      ;;
    red)
      export imagedata="data:image/gif;base64,R0lGODlhEAAQAPMAAAAEAABV"` 
	      `"AI0AAKcAAMUAAMgAAOkAAP8AAP9YWP96esDAwAAAAAAAAAAAAAAAAAA"` 
	      `"AACH5BAEAAAsALAAAAAAQABAAAARgcMkJap1Y1pQQMlcGcMdhnMUAYG"` 
	      `"MCnDCQrlpyVPFb0KMJBAED8EVQLXonHM5QXAEQS1gSYAT4LFhA81hIK"` 
	      `"g5fBVHA6z5LJe2OUjCHZQUyq72rEOI0FnXAJ+czR1iAg4QRADs="
      ;;
    clear)
      export imagedata="data:image/gif;base64,R0lGODlhEAAQAPIGAAAAAKur"` 
	      `"q7i4uMrKyuTk5PX19f///wAAACH5BAEAAAcALAAAAAAQABAAAANQeLr"` 
	      `"QvVA1Y0oZLwJaiCdDAEBAYXxoOEoWAXwvuG5wDYpH2bn2IIwllBD0y+"` 
	      `"2GHh9wgGzcZkxYbIBhUF0xkIpE7XZxGoBgLBCtIhLHGc2OJAAAOw=="
      ;;
    purple)
      export imagedata="data:image/gif;base64,R0lGODlhEAAQAPMLAAAEAJgA"` 
	      `"mqwArsYAyNQC1u0A7/wA//1h/v+atf+27//b/////wAAAAAAAAAAAAA"` 
	      `"AACH5BAEAAAwALAAAAAAQABAAAARfkMkJap1Y1nOMIVcGcF5hEgGAjY"` 
	      `"ZVWKiqtccwjDYAah1gpz9figHwWI6VgUBVfC0ACcAzqmQaXooEApDdV"` 
	      `"okDk8s1GBIJprR6pyGAkDqzxkanyykAgV6QkmU0R3+CgxEAOw=="
      ;;
    blue)
      export imagedata="data:image/gif;base64,R0lGODlhEAAQAPMAAAAEAAAs"` 
	      `"nAAxsAA1vQA6zABI/xp7/Shl/TiM/U2Y/lee/gAAAAAAAAAAAAAAAAA"` 
	      `"AACH5BAEAAAsALAAAAAAQABAAAARVcMkJap1YVoWMKVcGKIl3nMQAYK"` 
	      `"NXvHC6al0F28TcAi/PgwPVAtCBGV/BFeBzNA4Eyo9lWnkqCU1nQIfND"`  
	      `"nKUYPMLZaWCaMI2MwQI3oLtjN220O/sCAA7"
      ;;
    *)
      echo "Invalid color"
      ;;
  esac
}

function set_textcolor() {
  local color=$1
  case $color in
    green)
      export textcolor="Good"
      ;;
    yellow)
      export textcolor="Warning"
      ;;
    red)
      export textcolor="Attention"
      ;;
    *)
      export textcolor="Default"
      ;;
  esac
}

################### DEFAULT MS TEAMS ALERT JSON TEMPLATES
TEAMSTEMPLATEJSON='{
   "type":"message",
   "attachments":[
      {
         "contentType":"application/vnd.microsoft.card.adaptive",
         "contentUrl":null,
         "content":{
            "type":"AdaptiveCard",
            "body":[
               {
                  "type":"TextBlock",
                  "size":"Medium",
                  "weight":"Bolder",
                  "text":"Alert for $BBHOSTSVC"
               },
               {  
                  "type": "TextBlock",
                  "text": "Alert triggered {{DATE($triggertimestamp, LONG)}} at {{TIME($triggertimestamp)}}",
                  "size":"Small",
                  "wrap": false,
		  "separator": true

               },
	       {
                  "type":"Table",
                  "columns":[
                     {
                        "width":1
                     },
                     {
                        "width":15
                     }
                  ],
                  "rows":[
$xymontestrows
                        ],
		  "firstRowAsHeaders": false,
		  "spacing": "Small"
               },
               {
                  "type":"TextBlock",
                  "text":"$message",
		  "spacing":"Small",
		  "size":"Small",
		  "fontType":"Monospace",
		  "separator":true,
		  "isVisible": false,
		  "wrap": true,
                  "id": "alertmessage"
               }
            ],
            "actions":[
               {
                  "type": "Action.ToggleVisibility",
                  "title": "Show Message",
                  "targetElements": [ "alertmessage" ]
               },
	       {
                  "type":"Action.OpenUrl",
                  "title":"View Alert on Xymon",
                  "url":"$linkurl"
               }
            ],
            "msteams":{
		"width":"full"
	    },
	    "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
            "version":"1.5"
         }
      }
   ]
}' 

TEAMSTEMPLATEROWJSON='                     {
                        "type":"TableRow",
                        "cells":[
                           {
                              "type":"TableCell",
                              "verticalContentAlignment":"Center",
                              "items":[
                                 {
                                    "type":"Image",
                                    "ImageSize":"auto",
                                    "url":"$imagedata"
                                 }
                              ],
                              "horizontalAlignment":"Center"
			   }, 
			   {
                              "type":"TableCell",
                              "verticalContentAlignment":"Center",
                              "items":[
                                 {
                                    "type":"TextBlock",
                                    "text":"$testMessage",
                                    "wrap":true,
				    "size": "Small",
				    "maxLines": 22,
				    "color": "$textcolor"
                                 }
                              ],
                              "horizontalAlignment":"Left"
                           }
                        ],
			"style": "default"
                     },'

TMPFILE_TEMPLATEJSON=$(mktemp)
TMPFILE_TEMPLATEROWJSON=$(mktemp)
echo "$TEAMSTEMPLATEJSON" > "$TMPFILE_TEMPLATEJSON"
echo "$TEAMSTEMPLATEROWJSON" > "$TMPFILE_TEMPLATEROWJSON"

################### PROCESS XYMON MESSAGE INTO TEAMS MESSAGE

# Create timestamp in teams formatting for the start time of the alert:
start_time=$(($(date +%s) - DOWNSECS))
# Create date and time string from start time
triggertimestamp=$(date -d @$start_time -u --rfc-3339=seconds)
export triggertimestamp=$(echo $triggertimestamp | sed 's/ /T/')

# Parse the BBALPHAMSG variable and extract it's compoent messages
  # Extract link to view the host's service page in xymon
  export linkurl=$(echo "$BBALPHAMSG" | grep -oP 'http:\/\/[^\s]+')

  # Extract the service message. 
  export message=$(echo "$BBALPHAMSG" \
	  | awk '/^$/,/See http/{if(/See http/) exit; print}' \
	  | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')

  # Extract an array of tests and their associated test status message.
  tests=$(echo "$BBALPHAMSG" \
	  | grep -oP '(&(green|yellow|red|clear|purple|blue)[^\r\n|\r|\n]*)')
  readarray -t testarray <<< "$tests"

# Create a temp file to hold the rows of the tests.
  TMPFILE_rows=$(mktemp)

# Itterate over test array and create table rows for each test. 
for var in "${testarray[@]}"
do
  readarray -t testparts <<< "$(echo "$var" \
	  | sed -n 's/^&\(green\|yellow\|red\|clear\|purple\|blue\)\s\(.*\)/\1\n\2/p' )"
  
  testColor="${testparts[0]}"
  set_imagedata $testColor
  set_textcolor $testColor
  
  export testMessage="${testparts[1]}"
  envsubst < "$TMPFILE_TEMPLATEROWJSON" >> "$TMPFILE_rows"
done

sed -i '$s/,$//' "$TMPFILE_rows"
export xymontestrows=$(<"$TMPFILE_rows")

# Insert all of the variables into the final message. 
TMPFILE=$(mktemp)
envsubst '$BBHOSTSVC $triggertimestamp $xymontestrows $linkurl $message' \
	< "$TMPFILE_TEMPLATEJSON" > "$TMPFILE"

# Post message to teams channel
curl -X POST -H 'Content-Type: application/json' -d @${TMPFILE} "$URI"

rm -f $TMPFILE_TEMPLATEJSON
rm -f $TMPFILE_TEMPLATEROWJSON
rm -f $TMPFILE_rows
rm -f $TMPFILE

