import sys, os, json, time, xml.etree.cElementTree as ET,re,shlex

def parse_arg(argv):
	if sys.argv[1] == '-r':
		#if sys.argv[2] == 'true':
			run(argv)
		#else:
		#	print "not run PAT"
		#	sys.exit(1)
	else:
		print "Arg is wrong"
		print_usage()
		sys.exit(1)
def run(argv):
	if sys.argv[7] == '--dev':
		board = sys.argv[8].split(':')[0].split('_')[0]
		if board == 'pxa988dkb':
			os.chdir("/home/buildfarm/988")
		elif board == 'pxa1088dkb':
			os.chdir("/home/buildfarm/1088")
		else:
			print "Can't support PPAT for" + sys.argv[7]
			sys.exit(1)
	fileName = "list.xml"
	tree = ET.ElementTree(ET.parse(fileName).getroot())
	purpose=""
	#parse list.xml
	if sys.argv[3] == '-d':
		updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_image_path\"]", sys.argv[4])
	else:
		print "Arg is wrong: image_path"
		print_usage()
		sys.exit(1)
	if sys.argv[17] == '-p':
		for arg in sys.argv[18:]:
			purpose +=arg + " "
		print purpose
		updateXML(tree,"list.xml", "Arg/Property[@name=\"Purpose\"]", purpose)
	else:
		print sys.argv[17] + "Arg is wrong"
		print_usage()
		sys.exit(1)
	if sys.argv[5] == '-b':
		updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_os_version\"]", sys.argv[6].split('-')[1])
	else:
		print " Arg is wrong: branch_name"
		print_usage()
		sys.exit(1)
	if sys.argv[7] == '--dev':
		board = sys.argv[8].split('_')[0]
		updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_board\"]", board)	
		if board.find('1088') > 0:
			#print "There is no 1088dkb device to run PPAT"
			#sys.exit(1)
			updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_platform\"]", "HELN")
		elif board.find('988') > 0:
			print "There is no 988dkb device to run PPAT"
			sys.exit(1)
			#updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_platform\"]", "EMEI")
		elif board.find('986') > 0:
			updateXML(tree,"list.xml", "Arg/Property[@name=\"atf_platform\"]", "KULN")
	else:
		print "Arg is wrong: device"
		print_usage()
		sys.exit(1)
	if sys.argv[15] == '--tc':
		if sys.argv[11] == '--assigner':
			#testCases = "{" +",".join(sys.argv[18:]) + "}"
			#res = re.sub(r'([A-Za-z0-9]\w+)', r'"\1"', testCases)
			#length = len(sys.argv[18])
			addTestCaseList(tree,"list.xml", "TestCaseList", sys.argv[16], purpose, sys.argv[10], sys.argv[12], sys.argv[4], sys.argv[14])	
	else:
		print "Arg is wrong: testcase"
		print_usage()
		sys.exit(1)	
	updateXML(tree, "list.xml", "Arg/Property[@name=\"atf_time\"]", time.strftime('%Y-%m-%d@%H-%M-%S',time.localtime(time.time())))
	print os.system("./ATF ATD_config.xml")

def updateXML(tree, fileName, elementName, textValue):
    for elem in tree.iterfind(elementName):
    	elem.text = textValue
    tree.write("ATD_config.xml", encoding="utf-8")

def addTestCaseList(tree, fileName, elementName, testcases, purpose, blf, assigner, image_path, build_num):
	testCaseList = json.loads(testcases)
	for tc in testCaseList["TestCaseList"]:
		for elem in tree.iterfind(elementName):
			child = ET.SubElement(elem, "TestCase")
			name = ET.SubElement(child, "Name")
			name.text=tc["Name"]           
			timeout = ET.SubElement(child, "timeout")
			timeout.text="60000"
		
			category = ET.SubElement(child, "category")
			category.text = ";Functionality Test;"
		
			taskId = ET.SubElement(child, "taskname")
			taskId.text = build_num

			ass = ET.SubElement(child, "assigner")
			ass.text = assigner
			
			blf_b = ET.SubElement(child, "blf")
			blf_b.text = blf

			if testCaseList.has_key("inputs"):
				inputs = ET.SubElement(child, "cmds")
				inputs.text = testCaseList["inputs"]	
		
	tree.write("ATD_config.xml", encoding="utf-8")		

def print_usage():
	print "Please use \'launch_ppat.py -r true -p reason_for_test -d image_dest_dir -b branch_name -dev device -blf blf_name -assigner tasksubmitter -bn build_number -tc testcaselist_from_web_to_json\'"

if __name__ == "__main__":
	parse_arg(sys.argv[1:])
