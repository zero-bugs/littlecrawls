#!/usr/bin

while(true)
do
  echo "start:===== `date` ====="
  ps -ef | grep dart | grep -v grep | awk '{print $2}'|xargs -I {} kill -9 {}
  nohup dart ./bin/main.dart >>./main.out.log 2>&1 &
  nohup dart ./bin/test.dart >>./test.out.log 2>&1 &
  echo "end:===== `date` ====="
  
  sleep 1h
done
  
