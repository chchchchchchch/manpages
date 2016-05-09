#!/bin/bash

  MANDIR="/usr/share/man/man1/"

  for PROG in `compgen -c       | # LIST ALL PROGRAMS
               sort`              # SORT
   do
      MANPAGE=`man -w $PROG 2> /dev/null`
      if [ `echo $MANPAGE | grep "z$" | wc -l` -gt 0 ]; then
            CAT="zcat"; else CAT="cat"
      fi
      if [ `echo $MANPAGE | wc -c` -gt 1 ]; then
            echo $PROG
          # HTML=`echo ${PROG} | tr [:upper:] [:lower:]`.html
            HTML=${PROG}.html

            MD5OLD=`md5sum $HTML | cut -d " " -f 1`
            TITLE=`man -f $PROG | head -1 | cut -d "-" -f 2-`
            echo "<html><head>"                  >  ${HTML}.tmp
            echo "<title>$PROG - $TITLE</title>" >> ${HTML}.tmp
            echo '<link rel="stylesheet" \
                   type="text/css"       \
                   media="all"           \
                   href="man.css">' | #
            tr -s ' '                            >> ${HTML}.tmp
            echo "</head>"                       >> ${HTML}.tmp
            echo "<body>"                        >> ${HTML}.tmp
            echo "<pre>"                         >> ${HTML}.tmp
            $CAT $MANPAGE                    | \
            groff -mandoc -T ascii -P -cbuof | \
            recode utf-8..h0                     >> ${HTML}.tmp
            echo "</pre>"                        >> ${HTML}.tmp
            echo "</body>"                       >> ${HTML}.tmp
            echo "</html>"                       >> ${HTML}.tmp
            MD5NEW=`md5sum ${HTML}.tmp | cut -d " " -f 1`
           if [ X$MD5NEW == X$MD5OLD ]; then 
                echo "$PROG up-to-date"
                rm ${HTML}.tmp
           else 
                echo "$PROG somehow different"
                mv ${HTML}.tmp $HTML
           fi
           echo
      fi
  done

 exit 0;

