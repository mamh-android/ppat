#-----  Load neccessary modules -----
import os
import re
import string
#------------------------------------
inputdir = os.getcwd()+'/mm06_input'
outputdir = os.getcwd()+'/mm06_output'
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
    str1 = strlist1[0]
    str1_split = re.split(':\s+',str1)
    Intro_FPS = str1_split[1]

    str2 = strlist1[1]
    str2_split = re.split(r':\s+',str2)
    Samurai_FPS = str2_split[1]

    str3 = strlist1[2]
    str3_split = re.split(r':\s+',str3)
    Proxycon_FPS = str3_split[1]
    #---------------------------------------
    strlist2 = re.findall(r'Texels per second\s+\d*.\d*',s)
    str4 = strlist2[0]
    str4_split = re.split(r'second\s+',str4)
    FillRateSingleTexture = str(string.atof(str4_split[1])/1000/1000)

    str5 = strlist2[1]
    str5_split = re.split(r'second\s+',str5)
    FillRateDualTexture = str(string.atof(str5_split[1])/1000/1000)
    #----------------------------------------
    strlist3 = re.findall(r'Triangles per second\s+\d*.\d*',s)
    str6 = strlist3[2]
    str6_split = re.split(r'second\s+',str6)
    TriangleCountSimple = str(string.atof(str6_split[1])/1000/1000)

    str7 = strlist3[3]
    str7_split = re.split(r'second\s+',str7)
    TriangleCountLit = str(string.atof(str7_split[1])/1000/1000)
    #-----------------------------------------
    strlist4 = re.findall(r'Batches per second\s+\d*.\d*',s)
    str8 = strlist4[4]
    str8_split = re.split(r'second\s+',str8)
    BatchCount_noMatrix = str(string.atof(str8_split[1])/1000)

    str9 = strlist4[5]
    str9_split = re.split(r'second\s+',str9)
    BatchCount_Matrix = str(string.atof(str9_split[1])/1000)
    #------------------------------------------
    strlist5 = re.findall(r'Frames per second\s+\d*.\d*',s)
    str10 = strlist5[6]
    str10_split = re.split(r'second\s+',str10)
    CPU_Test = str10_split[1]

    # Write data to file
    list1 = ['ES11 MM06,','MM06 Intro,','fps,',Intro_FPS+'\n']
    list2 = [',','MM06 Samurai,','fps,',Samurai_FPS+'\n']
    list3 = [',','MM06 Proxycon,','fps,',Proxycon_FPS+'\n']
    list4 = [',','Fill Rate Single Texture,','M texels/s,',FillRateSingleTexture+'\n']
    list5 = [',','Fill Rate Dual Texture,','M texels/s,',FillRateDualTexture+'\n']
    list6 = [',','Triangle Count Simple,','M triangles/s,',TriangleCountSimple+'\n']
    list7 = [',','Triangle Count Lit,','M triangles/s,',TriangleCountLit+'\n']
    list8 = [',','Batch Count Without Load Matrix,','k batches/s,',BatchCount_noMatrix+'\n']
    list9 = [',','Batch Count With Load Matrix,','k batches/s,',BatchCount_Matrix+'\n']
    list10 = [',','CPU Test,','fps,',CPU_Test+'\n']
    fp2.writelines(list1)
    fp2.writelines(list2)
    fp2.writelines(list3)
    fp2.writelines(list4)
    fp2.writelines(list5)
    fp2.writelines(list6)
    fp2.writelines(list7)
    fp2.writelines(list8)
    fp2.writelines(list9)
    fp2.writelines(list10)

    fp2.close()
    fp1.close()
    
    
    
        
    
    
