#!/usr/bin

while(true)
do
  echo "start:===== `date` ====="
  tasklist //FI "IMAGENAME eq dart.exe"
  taskkill //F //FI "IMAGENAME eq dart.exe"
  nohup dart ./bin/main.dart >>./main.out.log 2>&1 &
  nohup dart ./bin/test.dart >>./test.out.log 2>&1 &
  echo "end:===== `date` ====="
  
  #sleep 1h
  sleep 40m
done
  
