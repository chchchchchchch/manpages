#!/bin/bash

 # TODO: id for anchor link

  MANBASE="/usr/share/man/man"
  HTMLDIR="html/en"
 #GROFF="groff -ekpstR -mtty-char -mandoc -Tutf8 -rLL=80n"
  GROFF="groff -mandoc -T utf8 -P -cbuof"

  TMP=tmp.txt

  echo > collect.txt

  for MANSRC in `find ${MANBASE}* -name "*.*"`
   do
      echo "----"; echo "$MANSRC"
      if [ `echo "$MANSRC" | grep "z$" | #
            wc -l` -gt 0 ]; then
            CAT="zcat"; else CAT="cat"
      fi

      eval "$CAT" "$MANSRC"    | #
      eval "$GROFF -rLL=2000n" | #
      recode utf-8..h0 > $TMP    #

      L=`grep -in "^NAME$" $TMP | head -n 1 | #
         cut -d ":" -f 1`; L=`expr $L + 1`

      TITLE=`sed -n "${L}p" $TMP | recode h0..utf8 | sed 's/^[ ]*//'`

      if [ `echo $TITLE | wc -c` -gt 1 ];then

            NAMES=`echo $TITLE | #
                   sed 's/ [-—]* .*$//' | #
                   sed 's/^[ ]*//'`
            DESCRIPTION=`echo $TITLE | #
                         sed 's/^.* [-—]* //'`
            echo "$TITLE"; echo
            LISTITEM="<span class=\"m\">"

            eval "$CAT" "$MANSRC"  | #
            eval "$GROFF -rLL=80n" | #
            recode utf-8..h0           > $TMP

            for NAME in `echo $NAMES | #
                         sed 's/,/\n/g'`
             do
                HTML="$HTMLDIR/${NAME}.html"
                echo "$NAME"
                LISTITEM="${LISTITEM}\
                <a href=\"${NAME}.html\">$NAME</a>, "

                echo "<html>"                        >  $HTML
                echo "<head><meta charset="utf-8"/>" >> $HTML
                echo "<title>$TITLE</title></head>"  >> $HTML
                echo "<body><pre>"                   >> $HTML
                echo ""                              >> $HTML
                cat $TMP                             >> $HTML
                echo ""                              >> $HTML
                echo "</pre></body></html>"          >> $HTML

            done
            echo "$DESCRIPTION"
            LISTITEM=`echo ${LISTITEM} | #
                      sed 's/,$//'`" - \
           <span class=\"d\">$DESCRIPTION</span> </span>"

            echo $LISTITEM >> collect.txt
      fi


  done


exit 0;


