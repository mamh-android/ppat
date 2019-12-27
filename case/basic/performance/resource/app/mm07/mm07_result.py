#-----  Load neccessary modules -----
import os
import re
import string
#------------------------------------
inputdir = os.getcwd()+'/mm07_input'
outputdir = os.getcwd()+'/mm07_output'
# Input file list
filelist = os.listdir(inputdir)
# Define regular expression
r = re.compile(r'(?P<Filename>\w+).(?P<Fileformat>\D+)')

# Go through file list, deal with file separately
for filename in filelist:
    # Separate file name
    filename_split = r.split(filename)
    # Generate output file name
    outputfilename = filename_split[1]+'.csv'
    # Open input and output file
    fp1 = open(inputdir+'/'+filename,'r')
    fp2 = open(outputdir+'/'+outputfilename,'w')
    # Read file data
    s = fp1.read()
    #----------------------------------------
    strlist1 = re.findall(r'fps:\s+\d*.\d*',s)
    #str1 = strlist1[0]
    #str1_split = re.split(':\s+',str1)
    #Intro_FPS = str1_split[1]

    str2 = strlist1[0]
    str2_split = re.split(r':\s+',str2)
    Taiji_FPS = str2_split[1]

    str3 = strlist1[1]
    str3_split = re.split(r':\s+',str3)
    Hover_FPS = str3_split[1]
    #---------------------------------------
    strlist2 = re.findall(r'Frames per second\s+\d*.\d*',s)
 #   str4 = strlist2[0]
 #   str4_split = re.split(r'second\s+',str4)
 #   Simulation = str4_split[1]

 #   str5 = strlist2[1]
 #   str5_split = re.split(r'second\s+',str5)
 #   BatchCount = str5_split[1]
    
 #   str6 = strlist2[2]
 #   str6_split = re.split(r'second\s+',str6)
 #   TextureFilter = str6_split[1]

  #  str7 = strlist2[3]
  #  str7_split = re.split(r'second\s+',str7)
  #  Unified_shader = str7_split[1]


    # Write data to file
  #  list1 = ['ES20 MM07,','MM07 Intro,','fps,',Intro_FPS+'\n']
    list2 = [',','MM07 Taiji,','fps,',Taiji_FPS+'\n']
    list3 = [',','MM07 Hover,','fps,',Hover_FPS+'\n']
  #  list4 = [',','FeatureTest: SimulationMark Advanced World,','fps,',Simulation+'\n']
  #  list5 = [',','FeatureTest: Batch count,','fps,',BatchCount+'\n']
  #  list6 = [',','FeatureTest: Texture filter and Anti-Alias,','fps,',TextureFilter+'\n']
  #  list7 = [',','FeatureTest: Unified shader,','fps,',Unified_shader+'\n']
  #  fp2.writelines(list1)
    fp2.writelines(list2)
    fp2.writelines(list3)
 #   fp2.writelines(list4)
 #   fp2.writelines(list5)
 #   fp2.writelines(list6)
 #   fp2.writelines(list7)

    fp2.close()
    fp1.close()
    
    
    
        
    
    
