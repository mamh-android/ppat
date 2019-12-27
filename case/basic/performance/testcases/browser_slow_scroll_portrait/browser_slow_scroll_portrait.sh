. ../../utils/UI_utils.sh
while read WEBSITE
do
	echo $WEBSITE
	. ./prepare.sh  $WEBSITE
	. ./run.sh
	. ./cleanup.sh
done < website_list.txt