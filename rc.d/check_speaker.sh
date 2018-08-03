. ${RCD}/functions

function play_1()
{
  {
    mplayer Media/1.wav
  } &> /dev/null
}

function play_2()
{
  {
    mplayer Media/2.wav
  } &> /dev/null
}

function play_3()
{
  {
    mplayer Media/3.wav
  } &> /dev/null
}

confirm "请移除音源回路线?[Y|N]: "
ans=$?
if [ $ans -ne 0 ]; then
    while [ $ans -ne 0 ]; do
        confirm "请移除音源回路线?[Y|N]: "
        ans=$?
    done
fi

while [ 1 ]; do
  random=$(((RANDOM % 3 ) + 1))
  # echo $random
  case $random in
  [1]*)
    play_1
    ;;
  [2]*)
    play_2
    ;;
  [3]*)
    play_3
    ;;
  *)
    ;;
  esac

  echo "请输入喇叭播出的数字声:[1]|[2]|[3]|[4(无声音)]"
  read num
  # echo $num
  if [ $num = 1 ] || [ $num = 2 ] || [ $num = 3 ] || [ $num = 4 ]; then
    if [ $num = 4 ]; then
      red_message "喇叭测试失败..."
      confirm "确认重新测试喇叭(Y)或结束测试(N):  "
      ans=$?
      #echo $failed_log

      while [[ $ans -ne 0 && $ans -ne 1 ]]; do
          confirm "确认重新测试喇叭(Y)或结束测试(N):  "
          ans=$?
      done
      if [ "$ans" -ne 0 ]; then
        # . ${RCD}/L10_sfc_failed.sh
        exit 1
        break
      elif [ "$ans" -eq 0 ]; then
        continue
      fi
    elif [ $num -ne $random ]; then
      red_message "验证失败，喇叭将重新播放数字声\\n"
      continue

    else
      green_message "喇叭测试通过...\\n"
      exit 0
      break
    fi
  else
    echo "请输入正确数字:[1]|[2]|[3]|[4(无声音)]"
    continue
  fi
done
