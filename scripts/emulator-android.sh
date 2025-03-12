#!/usr/bin/env bash

adb shell cmd overlay enable com.android.internal.systemui.navbar.gestural
adb shell settings put global auto_time 0
adb shell settings put global auto_time_zone 0
adb shell settings put system global time_12_24 24
adb shell settings put global sysui_demo_allowed 1
case "${THEME_MODE}" in
  light)
    adb shell cmd uimode night no
    ;;
  *)
    adb shell cmd uimode night yes
    ;;
esac
adb shell am broadcast -a com.android.systemui.demo -e command enter
adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 1312
adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
