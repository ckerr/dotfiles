# Used to get a date format of %Y-%m-%d and 24 hour clock time
PREFERRED_TIME_LOCALE='en_US.utf8@isodate'
if locale -a | grep --quiet "${PREFERRED_TIME_LOCALE}"; then
  export LC_TIME="${PREFERRED_TIME_LOCALE}"
else
  echo "Preferred time locale '${PREFERRED_TIME_LOCALE}' is not installed"
  echo "to install on debian: FIXME"
fi
unset PREFERRED_TIME_LOCALE

# 6743  2020-04-05 15:19  vi en_US@isodate
# 6744  2020-04-05 15:21  sudo localedef -i en_US@isodate -f UTF-8 en_US.UTF-8@isodate
# 6745  2020-04-05 15:21  locale -a | grep en_US
# 6746  2020-04-05 15:22  LC_TIME=en_US.utf8@isodate ls -l
# 6747  2020-04-05 15:22  LC_TIME=en_US.UTF-8@isodate ls -l
# 6748  2020-04-05 15:23  ls /usr/share/locales
# 6749  2020-04-05 15:25  sudo rmdir /usr/local/share/i18n
# 6750  2020-04-05 15:26  sud cp en_US@isodate /usr/share/i18n/locales
# 6751  2020-04-05 15:26  sudo cp en_US@isodate /usr/share/i18n/locales
# 6752  2020-04-05 15:26  sudo rm /usr/share/i18n/locales/en_US@isodate
# 6753  2020-04-05 15:27  sudo mkdir /usr/local/share/i18n
# 6754  2020-04-05 15:27  sudo mkdir /usr/local/share/i18n/locales
# 6755  2020-04-05 15:27  sudo cp en_US@isodate /usr/local/share/i18n/locales
# 6756  2020-04-05 15:28  vim /usr/share/i18n/SUPPORTED
# 6757  2020-04-05 15:29  ls /usr/share/i18n/locales/en_US
# 6758  2020-04-05 15:29  sudo vi /usr/local/share/i18n/supported
# 6759  2020-04-05 15:29  view /usr/share/i18n/locales
# 6760  2020-04-05 15:29  view /usr/share/i18n/SUPPORTED
# 6761  2020-04-05 15:31  LC_TIME=en_US@isodate.UTF-8 ls -la
# 6762  2020-04-05 15:31  LC_TIME=en_US.utf8@isodate.UTF-8 ls la
# 6763  2020-04-05 15:31  LC_TIME=en_US.utf8@isodate.UTF-8 ls -la
# 6764  2020-04-05 15:32  LANG=en_US.UTF-8@isodate.UTF-8 ls -la
# 6765  2020-04-05 15:33  LANG=en_US.UTF-8@isodate.UTF-8 keepassxc
# 6766  2020-04-05 15:33  LANG=en_US@isodate.UTF-8 keepassxc
# 6767  2020-04-05 15:33  LANG=en_US@isodate keepassxc
# 6768  2020-04-05 15:33  LANG=en_US.UTF-8@isodate keepassxc
# 6769  2020-04-05 15:35  LC_TIME=en_US.UTF-8@isodate keepassxc
# 6770  2020-04-05 15:35  LC_TIME=en_US.UTF-8@isodate date
# 6771  2020-04-05 15:35  date -I
# 6772  2020-04-05 15:36  date +%

