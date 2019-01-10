#!/bin/bash

TODAY=$(date +%Y-%m-%d)
DATADIR=/nas/data/
BACKUPDIR=/nas/backup/

function listYearlyBackups() {
	for i in 0 1 2 3 4 5
		do ls ${BACKUPDIR} | egrep "$(date +%Y -d "${i} year ago")-[0-9]{2}-[0-9]{2}" | sort -u | head -n 1
	done
}
function listMonthlyBackups() {
	for i in 0 1 2 3 4 5 6 7 8 9 10 11 12
		do ls ${BACKUPDIR} | egrep "$(date +%Y-%m -d "${i} month ago")-[0-9]{2}" | sort -u | head -n 1
	done
}
function listWeeklyBackups() {
	for i in 0 1 2 3 4
		do ls ${BACKUPDIR} | grep "$(date +%Y-%m-%d -d "last monday -${i} weeks")"
	done
}
function listDailyBackups() {
	for i in 0 1 2 3 4 5 6
		do ls ${BACKUPDIR} | grep "$(date +%Y-%m-%d -d "-${i} day")"
	done
}
function getAllBackups() {
	listYearlyBackups
	listMonthlyBackups
	listWeeklyBackups
	listDailyBackups
}
function listUniqueBackups() {
	getAllBackups | sort -u
}
function listBackupsToDelete() {
	ls ${BACKUPDIR} | grep -v -e "$(echo -n $(listUniqueBackups) |sed "s/ /\\\|/g")"
}

cd ${BACKUPDIR}
listBackupsToDelete | while read file_to_delete; do
	rm -rf ${file_to_delete}
done

SCRIPTDIR=/nas/data/backup_scripts
LASTDAYPATH=${BACKUPDIR}/$(ls ${BACKUPDIR} | tail -n 1)
TODAYPATH=${BACKUPDIR}/${TODAY}

if [[ ! -e ${TODAYPATH} ]]; then
	mkdir -p ${TODAYPATH}
fi

rsync -a --link-dest ${LASTDAYPATH} ${DATADIR} ${TODAYPATH} $@

${SCRIPTDIR}/deleteOldBackups.sh