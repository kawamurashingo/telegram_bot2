#!/bin/bash

# telegram bot id
BOT_ID="XXXX:XXXX"

DIR=`dirname $0`

cd ${DIR}

test -d ./FILE || mkdir ./FILE
test -d ./DSC || mkdir ./DSC

# delete old dir
rm -rf ./FILE/`date +%Y%m%d -d'30 day ago'`*
rm -rf ./DSC/`date +%Y%m%d -d'30 day ago'`*

FILE_DATE=`date +%Y%m%d%H%M`
OLD_FILE_DATE=`ls -ltr ./FILE/ |tail -n1 |awk '{print $9}'`

# get google calender schedule
python3 get_events.py | sed -e 's:<html-blob>::g' -e 's:</html-blob>::g' -e "s:<br>:\n:g" > schedule.txt
sed -i -E 's@^.*(https?://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]).*$@\1@' schedule.txt

# make text
sed -e "s/DATE/`date +%Y-%m-%d --date tomorrow`/" reverse.sed > make_reverse.sed
sed -n "/`date +%Y-%m-%d --date tomorrow`/,/^$/p" schedule.txt  | sed -f make_reverse.sed | sed -e "s:`date +%Y-%m-%d --date tomorrow`:`date +%m/%d --date tomorrow`:" -e "s/~.*//" > make.txt

test -f make.txt.`date +%Y%m%d` && diff make.txt make.txt.`date +%Y%m%d` && exit 1
test -f make.txt.`date +%Y%m%d` && diff make.txt make.txt.`date +%Y%m%d` | grep "<" || (cp -f make.txt make.txt.`date +%Y%m%d` && exit 2) 

# make file
test -d ./FILE/${FILE_DATE} || mkdir -p ./FILE/${FILE_DATE}

# get client
python3 spreadsheet_client.py |sed -e 's/],/\n/g' -e 's/]//g' -e 's/\[//g' -e "s/'//g" -e "s/ //g" > client

# get member
python3 spreadsheet_member.py |sed -e 's/],/\n/g' -e 's/]//g' -e 's/\[//g' -e "s/'//g" -e "s/ //g" > member

# duplication check
cat client |awk -F',' '{print $1}' |sort |uniq -d | grep -P "\D" && exit 3
cat member |awk -F',' '{print $1}' |sort |uniq -d | grep -P "\D" && exit 4

while read line
do
echo $line  |grep -q Title && ID=`grep "^\`echo $line |awk -F'　' '{print $1}' |sed -e "s/Title://"\`" member |awk -F',' '{print $2}'`
echo $line  |grep -q Title && MEM=`grep "^\`echo $line |awk -F'　' '{print $1}' |sed -e "s/Title://"\`" member |awk -F',' '{print $1}'`
echo $line  |grep -q Title && FILE_NAME=`echo $line |sed -e "s/Title://" -e "s/　/_/g"`
echo $line  |grep -q Title && grep "`echo $line |awk -F'　' '{print $2}'`" client >> ./FILE/${FILE_DATE}/${ID}_${FILE_NAME}
echo $line  |grep -q Title || echo $line >> ./FILE/${FILE_DATE}/${ID}_${FILE_NAME}

done < make.txt


test -d ./DSC/${FILE_DATE} || mkdir -p ./DSC/${FILE_DATE}

# post telegram
for i in `ls -tr ./FILE/${FILE_DATE} |grep -v "キャンセル"`
do

diff ./FILE/${FILE_DATE}/$i ./FILE/${OLD_FILE_DATE}/$i && continue

ID=`echo $i |awk -F'_' '{print $1}'`
MEM=`echo $i |awk -F'_' '{print $2}'`

DATE=`tail -n1 ./FILE/${FILE_DATE}/$i`
CLI=`head -n1 ./FILE/${FILE_DATE}/$i|awk -F',' '{print $2" 様  "$3"  "$4"\\\\n"$5}'`

TXT=`cat ./FILE/${FILE_DATE}/$i | sed -e '1d' -e '$d' -e 's/$/ \\\\n/'`

echo "
$DATE \\n
$TXT \\n
$CLI \\n
\\n
\\n" >> ./DSC/${FILE_DATE}/${ID}_${MEM}

done

for i in `ls ./DSC/${FILE_DATE}`
do

ID=`echo $i |awk -F'_' '{print $1}'`
MEM=`echo $i |awk -F'_' '{print $2}'`

grep "not found" ./DSC/${FILE_DATE}/$i && sed -i -e "s/not found/場所確認中\\\\n※場所が決まりましたらご連絡致します/" ./DSC/${FILE_DATE}/$i

TXT=`cat ./DSC/${FILE_DATE}/$i`

DSC="
$MEM さん \\n
前日確認です。 \\n
\\n
$TXT
ご確認よろしくお願い致します。
"

curl -s  -H 'Accept: application/json' -H "Content-type: application/json" -X POST "https://api.telegram.org/bot${BOT_ID}/sendMessage?chat_id=${ID}" -k -d @- <<EOF
{
    "text": "${DSC}"
}
EOF

echo ""

done

# rm -rf ./FILE/`date +%Y%m%d -d'30 day ago'`*
# rm -rf ./DSC/`date +%Y%m%d -d'30 day ago'`*

cp -f make.txt make.txt.`date +%Y%m%d`

test -f make.txt.`date +%Y%m%d -d'1 day ago'` && rm -f make.txt.`date +%Y%m%d -d'1 day ago'`

rm -f ./client
rm -f ./member

exit 0
