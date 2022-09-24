#!/bin/bash
# Usage:
#    test_cscope.sh <the-word>
################################
# AWK scripts                  #
################################
read -d '' scriptVariable << 'EOF'
        function color1(txt) { return "\033[34m" txt "\033[0m"; }
        function color2(txt) { return "\033[35m" txt "\033[0m"; }
        function color3(txt) { return "\033[32m" txt "\033[0m"; }
        function color4(txt) { return "\033[37m" txt "\033[0m"; }
        function color5(txt) { return "\033[33m" txt "\033[0m"; }

        BEGIN {}
        ($1 ~ "/") {

            file   = $1; $1 = "";
            lnum   = $3; $3 = "";
            caller = $2; $2 = "";

            isFunc = 0;
            tmp = match($0, /(\w+(\s+)?){2,}\([^!@#$+%^]+?\)/);
            if (tmp) {
                tmp = match($0, /;$/);
                if (! tmp) {
                    tmp=match($0, / = /);
                    if (! tmp)
                        isFunc = 1;
                }
            }

            if (isFunc)
                print color1(file) ":" color2(lnum) ":0: " color3(caller) color5($0);
            else
                print color1(file) ":" color2(lnum) ":0: " color3(caller) color4($0);
        }
        END {}
EOF
################################
# End of AWK Scripts           #
################################

#cscope -d -L4 <word>
cscope -dL0 $1 | awk "$scriptVariable"
