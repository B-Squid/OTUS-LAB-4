# OTUS-LAB-4
 Bash, awk, sed, grep и другие

 Решил делать вариант 1 (watchdog с перезагрузкой процесса/сервиса) со *
 Честно несколько дней рыл материалы, т.к. хотел пойти по пути нативного event-driven. Не нашел, и поскольку нигде не упоминалось про установку доп. инструментов, решил делать на основе существующих в ОС. Тем более использование сторонних утилит могло бы сильно облегчить задачу, что конечно же не является целью задания :)
Также в качестве нагрузки решил писать логи (которые в принципе можно ротировать :). Логи пишутся в папку запуска скрипта. Писалось на Debian 9/bash 4.4.12 .
