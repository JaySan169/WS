template(name="OnlyMsg" type="string" string="%msg:::drop-last-lf%\n")

if( $programname == '{{COMPONENT}}') then {
action(type="omfile" file="/var/log/{{COMPONENT}}.log" template="OnlyMsg")
& stop
}
