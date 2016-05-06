#!/bin/sh
#
# EUROSTUDENT MAILER by Richard Bruna (c) 2016
#
# Description:
#
# Parse mail from file, send mail with message and get mailer log
# 
# Note:
#
# dos2unix
# cat uzivatel.csv  | cut -d\, -f2 | sed 's/["]//g' | sed 's/[ ]*$//g' > maillist.txt
#
# Subject: -> echo 'Zapojte se do šetření EUROSTUDENT VI' | base64
#
# Tune:
#
# LANG=cs_CZ.UTF-8
# LC_CTYPE="cs_CZ.UTF-8"
#

ENABLE=0

LIST='list.txt'
LOG='log.txt'
TOTAL=`cat $LIST 2>/dev/null | wc -l`
SENT=0

# PRERUN

#test maillist exist
if ! [ -f $LIST ]; then echo "Missing list.txt!"; exit 1; fi
#clear logfile
echo > $LOG

# START

#log header
echo -e '--------------------------------------------------\n' >> $LOG
#log program header
echo -e ' EUROSTUDENT VI MAILER\n' >> $LOG
#log start date
echo -e ' START' `date` '\n' >> $LOG
#log total number
echo -e ' CELKOVY POCET:\t\t' $TOTAL >> $LOG

#CONTROL

#remove duplicates
#echo 'odstranuji duplicity..'
cat $LIST | sort | uniq > "$LIST".tmp; mv "$LIST".tmp $LIST
#print duplicate number
DUP=$(($TOTAL - `cat $LIST | wc -l`))
echo -e ' DUPLIKAT:\t\t' $DUP >> $LOG
#remove bad format
#echo 'odstranuji neplatny format..'
TOTAL=`cat $LIST | wc -l`
cat $LIST | sed '/^[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,4\}$/!d' > "$LIST".tmp
#create blacklist
#echo 'vytvarim blacklist..'
diff --unchanged-group-format='' $LIST "$LIST".tmp > blacklist.txt;
#update mainlist
mv "$LIST".tmp $LIST
#print bad format number
echo -e ' NEPLATNY FORMAT:\t' $(($TOTAL - `cat $LIST | wc -l`)) >> $LOG
#create pseudo random sort
#echo 'generuji pseudo-nahodny seznam..'
for i in $(seq 1 7); do
	cat $LIST | sort --random-source=/dev/urandom -R | sort --random-source=/dev/urandom -R > "$LIST".tmp; mv "$LIST".tmp $LIST
done
#print total sent
echo -e ' CELKEM ODESLANO:\t' $SENT '\n' >> $LOG

#SEND MAIL

#echo 'zacinam odesilat..'
while read EMAIL; do
	if [ "$ENABLE" = '1' ]; then
		#echo posilam .. $MAIL
		#send email with DSN and correct username
		sendmail -N success -r eurostudent@msmt.cz $EMAIL << EOL
From: Eurostudent VI <eurostudent@msmt.cz>
To: $EMAIL 
Subject: =?utf-8?B?WmFwb2p0ZSBzZSBkbyDFoWV0xZllbsOtIEVVUk9TVFVERU5UIFZJCg==?=
MIME-Version: 1.0
Content-Type: text/html; charset=utf-8

<html>
<head><meta charset="utf-8"></head>
<body>
<br>
<div align="justify" style="width:90%">
Vážená studentko / vážený studente,
<br><br>
byl(a) jste vybrán(a) pro účast v  šetření EUROSTUDENT VI.  Toto šetření postojů a životních podmínek vysokoškolských studentů probíhá v řadě evropských zemí a stejně jako v předchozích vlnách se k němu připojuje i Česká republika. Na základě Vašich odpovědí bude možné zjistit aktuální postoje a životní podmínky studentů studujících na vysokých školách v České republice v bakalářských a magisterských studijních programech.
<br><br>
Šetření organizuje Ministerstvo školství mládeže a tělovýchovy ČR (<a target="_blank" href="http://www.msmt.cz">www.msmt.cz</a>) ve spolupráci se Studentskou komorou Rady vysokých škol (<a target="_blank" href="http://www.skrvs.cz">www.skrvs.cz</a>).  Základní výsledky budou na stránkách MŠMT dostupné na podzim 2016.
<br><br>
Dovoluji si Vás požádat o vyplnění dotazníku, k němuž se dostanete kliknutím na níže uvedený odkaz a zadáním e-mailové adresy, na niž Vám přišel tento e-mail (v případě, že si univerzitní poštu přeposíláte, zkontrolujte si prosím, na který e-mail Vám byla pozvánka původně poslána). Následně Vám bude zasláno unikátní heslo, které použijete pro vstup do dotazníku. Dotazník je plně anonymní, jeho vyplnění Vám zabere asi 30 minut a k částečně vyplněnému dotazníku se můžete kdykoli vrátit (je tedy možné vyplňování dotazníku přerušit a pokračovat později). 
<br><br>
Odkaz: <a target="_blank" href="https://eurostudent.msmt.cz">eurostudent.msmt.cz</a>
<br><br>
O kompletní vyplnění dotazníku prosíme do 30. dubna 2016.
<br><br>
V případě jakýchkoli dotazů se na nás neváhejte obrátit na adrese <a href="mailto:eurostudent@msmt.cz?subject=Eurostudent%20VI%20Dotaz">eurostudent@msmt.cz</a>.
<br><br>
Děkuji Vám za Váš čas, který budete vyplnění dotazníku věnovat, a přeji Vám mnoho úspěchů ve Vašem studiu.
<br><br>
S přátelským pozdravem
</div><br><div align="right" style="width:90%">
Jakub Fischer (odborný garant projektu a prorektor Vysoké školy ekonomické v Praze)
</div>
</body>
</html>
EOL
		#delay sec before next
		sleep 3
		#log update counter
		SENT=$(($SENT + 1))
		sed -i "s/\(CELKEM ODESLANO:	\)\(.*\)/\1 $SENT/" $LOG
	fi
done < $LIST

#log end date
echo -e ' STOP' `date` '\n' >> $LOG
#log footer
echo -e '--------------------------------------------------\n' >> $LOG

#EXIT

exit 0

