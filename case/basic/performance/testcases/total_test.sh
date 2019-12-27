TEST_COUNT=3
TESTCASE=(	home_flick_portrait
			launcher_flick_portrait
			home_launcher_switch
			gallery_flick_portrait
			gallery_flick_landscape
			contact_scroll
)
#################################################################################################
			
i=0
echo "========	Total Test begin	========"
echo ""
echo ""
while [ $i -lt ${#TESTCASE[@]} ]
do
	cd ${TESTCASE[i]}
	j=0
	while [ $j -lt $TEST_COUNT ]
	do
		./${TESTCASE[i]}.sh
		sleep 5
		
		j=$((j+1))
	done
	cd ..
	
	i=$((i+1))
done
echo "========	Total Test End	========"