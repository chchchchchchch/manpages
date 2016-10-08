#!/bin/bash

  GROFF="groff -mandoc -T utf8 -P -cbuof"
  MANBASE="/usr/share/man/man"
  MANLIST=tmp.list
  HTMLDIR="html/en"; TMP=tmp.txt
  INDEX="$HTMLDIR/manpages.html"


# MAKE A LIST WITH AVAILABLE MAN PAGES
# ---------------------------------------------------------------------- #
  compgen -c > compgen.list

# SELECT FILES FROM THE MAN DIRECTORY
# ---------------------------------------------------------------------- #
  for MANSRC in `find ${MANBASE}* -name "*.*"`
   do
       MANNAME=`basename $MANSRC       | #
                sed "s/\.[0-9]*\.gz$//"` # 
      #echo $MANSRC
       if [ `grep "^${MANNAME}$" compgen.list | wc -l` -gt 0 ]
        then
             MANNAME=`grep "^${MANNAME}$" compgen.list`
             echo "${MANSRC}|${MANNAME}" >> $MANLIST
             echo "$MANNAME"
       fi
      #echo "----"
  done


# CONVERT ALL FILES FROM THE LIST
# ---------------------------------------------------------------------- #
   for MANSRC in `cat $MANLIST       | #
                  sort -t "|" -k 2,2 -u`
    do
       MANNAME=`echo $MANSRC | cut -d "|" -f 2`
        MANSRC=`echo $MANSRC | cut -d "|" -f 1`

       echo "----"; echo "$MANSRC" # PRINT SOME INFORMATION

       if [ `echo "$MANSRC" | grep "z$" | # CHECK IF .gz
             wc -l` -gt 0 ]; then CAT="zcat"; else CAT="cat";fi

    # WRITE TO TEMPORARY FILE
    # ------------------------------------------------------------------ #
       eval "$CAT" "$MANSRC"    | # RUN CAT ON MANSRC
       eval "$GROFF -rLL=2000n" | # RUN GROFF EXTRAWIDE
       recode utf-8..h0 > $TMP    # RECODE FOR HTML
 
    # FIND TITLE (= NAME + DESCRIPTION)
    # ------------------------------------------------------------------ #
       L=`grep -in "^NAME$" $TMP | head -n 1 | # GREP NAME (=LINE NUMBER)
          cut -d ":" -f 1`; L=`expr $L + 1`    # INCREASE LINE NUMBER + 1
       TITLE=`sed -n "${L}p" $TMP | # SELECT TITLE (=ONE AFTER NAME)
              recode h0..utf8     | # BACK TO UNICODE
              sed 's/^[ ]*//'`      # DELETE LEADING BLANKS
 
       eval "$CAT" "$MANSRC"  | # RUN CAT ON MANSRC
       eval "$GROFF -rLL=80n" | # RUN GROFF 80c
       recode utf-8..h0 > $TMP  # RECODE FOR HTML

          # SET HTML FILE
          # ------------------------------------------------ #
            HTML="$HTMLDIR/${MANNAME}.html"
 
          # WRITE HTML FILE
          # ------------------------------------------------ #
            echo "<html>"                           >  $HTML
            echo "<head><meta charset="utf-8"/>"    >> $HTML
            echo "<title>$TITLE</title></head>"     >> $HTML
            echo "<body><pre>"                      >> $HTML
            echo ""                                 >> $HTML
            cat $TMP                                >> $HTML
            echo ""                                 >> $HTML
            echo "</pre></body></html>"             >> $HTML 
    # ------------------------------------------------------------------ #
  done

# CLEAN UP
# ---------------------------------------------------------------------- #
  rm $TMP $MANLIST compgen.list

  exit 0;

