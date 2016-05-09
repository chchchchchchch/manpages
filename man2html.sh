#!/bin/bash

  GROFF="groff -mandoc -T utf8 -P -cbuof"
  MANBASE="/usr/share/man/man"
  HTMLDIR="html/en"; TMP=tmp.txt
  INDEX="$HTMLDIR/manpages.html"


# CONVERT ALL FILES YOU FIND IN THE MAN DIRECTORY
# ---------------------------------------------------------------------- #

  for MANSRC in `find ${MANBASE}* -name "*.*" | head -n 10`
   do
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

    # IF TITLE IS SET
    # ------------------------------------------------------------------ #
      if [ `echo $TITLE | wc -c` -gt 1 ];then

        echo "$TITLE";                # PRINT SOME INFORMATION

        NAMES=`echo $TITLE          | # DISPLAY FULL TITLE 
               sed 's/ [-—]* .*$//' | # DELETE ALL AFTER ' - '
               sed 's/^[ ]*//'`       # DELETE LEADING BLANKS
        DESCRIPTION=`echo $TITLE        | # DISPLAY FULL TITLE
                     sed 's/^.* [-—]* //'` # DELETE ALL IN FRONT OF ' - '

      # WRITE TO TEMPORARY FILE
      # ---------------------------------------------------------------- #
        eval "$CAT" "$MANSRC"  | # RUN CAT ON MANSRC
        eval "$GROFF -rLL=80n" | # RUN GROFF 80c
        recode utf-8..h0 > $TMP  # RECODE FOR HTML

      # MAKE IDENTICAL HTML PAGE FOR EACH NAME
      # ---------------------------------------------------------------- #
        for NAME in `echo $NAMES   | # NAMES SEPARATED BY ,
                     sed 's/,/\n/g'` # KOMMA TO NEWLINES
         do
          # SET HTML FILE
          # ------------------------------------------------ #
            HTML="$HTMLDIR/${NAME}.html"

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
        done
      fi
      # ---------------------------------------------------------------- #
  done

# CLEAN UP
# ---------------------------------------------------------------------- #
  rm $TMP


# GENERATE LIST
# ---------------------------------------------------------------------- #

  echo "<html><head><title>manpage index</title>\
        </head><body><p>" | #
  tr -s ' ' | sed 's/> </></g' > $INDEX

  for HTML in `ls $HTMLDIR | grep ".html$"`
   do
      LI="<span class=\"m\">"
      TITLE=`grep '<title>' $HTMLDIR/$HTML     | # GREP <title>
             cut -d ">" -f 2 | cut -d "<" -f 1`  # SELECT BETWEEN ><
      echo $TITLE
      NAMES=`echo $TITLE          | # DISPLAY FULL TITLE 
             sed 's/ [-—]* .*$//' | # DELETE ALL AFTER ' - '
             sed 's/^[ ]*//'      | # DELETE LEADING BLANKS
             recode utf8..h0`       # RECODE FOR HTML
      INFO=`echo $TITLE           | # DISPLAY FULL TITLE
            sed 's/^.* [-—]* //'  | # DELETE ALL IN FRONT OF ' - '
            recode utf8..h0`        # RECODE FOR HTML

        for NAME in `echo $NAMES   | # NAMES SEPARATED BY ,
                     sed 's/,/\n/g'` # KOMMA TO NEWLINES
         do
            ID=`echo $NAME | md5sum | cut -c 1-6`
            LI="${LI}\
              <a href=\"${NAME}.html\" id=\"$ID\">$NAME</a>, "
        done
        LI=`echo ${LI} | #
            sed 's/,$//'`" - \
       <span class=\"d\">$INFO</span> </span>"
        echo $LI >> $INDEX
  done
  echo '</p></body></html>' >> $INDEX



exit 0;

