#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import stat
import optparse
import shutil
import zipfile
import threading
import time
import tempfile
import pprint
import platform
import ctypes
import fnmatch
import filecmp
import re
import ftplib

__version__ = "3.0"

#ftp daily build burn
class FtpDailyBurn():
    def __init__(self, imagedate, product, blf):
        #os的类型，Linux还是windows
        self.systemtype = platform.system()

#http daily build burn
class HttpDailyBurn():
    def __init__(self, imagedate, product, blf):
        #os的类型，Linux还是windows
        self.systemtype = platform.system()

#samba daily build burn class
class SambaDailyBurn():
    def __init__(self, imagedate, product, blf):
        #os的类型，Linux还是windows
        self.systemtype = platform.system()

        self.imagedate = imagedate
        self.product = product
        self.blf = blf

        #是否打印输出log
        self.quiet = False

        #是否强制copy
        self.copyforce = False
        #print all image name if set this option
        self.listimage = False

        #默认是当前路径
        self.destpath = ""
        self.onlyburn = False
        self.onlycopy = False

        #是否擦写
        self.eraseflash = False
        #是否只是擦写
        self.onlyeraseflash = False
        #是否烧写后自动重启
        self.resetafterburning = False

        #swdl.zip name
        self.swdlzipname = "Software_Downloader.zip"
        #softwaredownloader name
        if self.systemtype == "Linux":
            self.swdlname = "swdl_linux"
            self.autobuildpath= "/autobuild"
        elif self.systemtype == "Windows":
            self.swdlname = "SWDownloader.exe"
            self.autobuildpath= "\\autobuild"
        else:
            self.swdlname = ""
            self.autobuildpath = ""

        # autobuild + android = 默认的autobuild images的路径
        self.android = "android"

        #local path,where source image are
        self.local = "/autobuild"

        self.Image_Enable_pattern = "Image_Enable"
        self.Image_ID_Name_pattern = "Image_ID_Name"
        self.Image_Tim_Included_partten = "Image_Tim_Included"
        self.Image_Path_pattern = "Image_Path"
        self.Erase_All_Flash = "Erase_All_Flash"
        self.UE_Boot_Option = "UE_Boot_Option"

        self.findfile = FindFile()

        self.printcolor = PrintColor()

        #blf 里的image name
        self.blfimagename_L = []

        #不烧写的image
        self.disableimage_L = []
        #只烧写的image
        self.enableimage_L = []

        #image enable or disable num -->0/1 enable/disable
        self.blfimageable_D = {}

        #blf 里的image num --> name
        self.blfimagenum_D = {}

        #blf 里的image id name --> num 映射
        self.blfimageidname_D = {}

        #blf 里的image num --> time included
        self.blfimagetimincluded_D = {}

        self.is_parent = False

        #源image路径下的blf路径/绝对路径
        self.localblfpath = "" #只有路径
        self.localblffile= "" #路径+blf文件名

        #目的路径下的blf路径/绝对路径
        self.destblfpath = "" #只有路径
        self.destblffile= "" #路径+blf文件名

        #目的路径下的swdl路径/绝对路径
        self.destswdlpath = "" #只有路径.烧image时要切入这个目录中
        self.destswdlfile = ""

        #源路径下的swdl.zip路径/绝对路径
        self.localswdlzippath = "" #只有路径
        self.localswdlzipfile= "" #路径+swdlzip文件名

        self.destswdlzippath = "" #只有路径
        self.destswdlzipfile = "" #路径+swdlzip文件名

        #image base path
        self.platformpath = ""

        self.swdldriver = SwdlDriver()

        #列出选项的最大个数
        self.printlistmax = 20

        #线程池的个数,在复制/下载images时会用到多线程
        self.jobsnum = 0

        self.host = "10.38.116.40"
        self.username = "pat"
        self.password = "powerpat"

    #end __init__()

    def start(self):
        if self.listimage:
            if self._prepare_imagedate_product() != 0:
                return 1
            self.list_allimagename()
            return 0

        if self.onlycopy and self.onlyburn:
            self.printcolor.printerror('onlycopy or onlyburn?')
            return 1

        # copy images and burn images
        #1,
        if self._prepare_imagedate_product() != 0:
            return 1
        #2.prepare copy images.准备destpath路径。复制blf文件／修改blf文件
        if self._prepare_copy_images() != 0:
            return 1

        if self.onlycopy:
            #3.start copy images
            self._start_copy_images()
        else:
            #3.start copy images
            self._start_copy_images()
            #4.start burn images
            self._start_burn_images()

        return 0

    """preepare imagedtae and product"""
    def _prepare_imagedate_product(self):
        if not self.imagedate and not self.product:
            #imagedate 和 product 都没有,先选择 platformpath
            # /autobuild/pxa988
            # /autobuild/pxa1908
            if self.select_platformpath() != 0:
                return 1

            if self.select_imagedate() != 0:
                return 1

            #imagedate设置好了就在imagedate找不同的product的目录
            if self.select_product() != 0:
                return 1
        elif self.imagedate and not self.product:
            #imagedate 有了要在不同的platform 目录下搜索这个imagedate的folder
            if self.find_imagedate() != 0:
                return 1

            #imagedate设置好了就在imagedate找不同的product的目录
            if self.select_product() != 0:
                return 1
        elif not self.imagedate and self.product:
            #product 有了要在不同的platform/imagedate 目录下搜索这个product的folder
            #确定platform
            if self.find_product() != 0:
                return 1

            #选择imagedate
            if self.select_imagedate() != 0:
                return 1
        else:
            #都有的情况
            #imagedate 有了要在不同的platform 目录下搜索这个imagedate的folder
            if self.find_imagedate() != 0:
                return 1

            if self.find_product() != 0:
                return 1

        #到此 "imagedate:", "platform:", "product:"这三个都有了, 然后设置一下local
        self.local = os.path.join(self.platformpath, self.imagedate, self.product)
        self.localswdlzippath = os.path.join(self.platformpath, self.imagedate)
        self.localswdlzipfile= os.path.join(self.platformpath, self.imagedate, self.swdlzipname)
        return 0

    """prepare blf file name"""
    def _prepare_blf(self):
        if self.find_dailybuild_blf(self.local, self.blf, None) != 0:
            #没找到这个blf文件时，尝试通配搜索其他的blf文件
            self.printcolor.printwarning("try to search '*.blf'")
            if self.find_dailybuild_blf(self.local, "", "*.blf") != 0:
                #没blf文件我怎么知道你需要copy哪些image啊？！
                return 1
        return 0

    def find_product(self,autobuildpath="", platformpath="", imagedate="", product=""):
        #/autobuild
        autobuildpath = self.autobuildpath if autobuildpath == "" else autobuildpath
        platformpath = self.platformpath if platformpath == "" else platformpath
        imagedate = self.imagedate if imagedate == "" else imagedate
        product = self.product if product == "" else product

        #/autobuild/android
        androidpath = os.path.join(autobuildpath, self.android)

        if not self.findfile.smbisdir(androidpath):
            self.printcolor.printerror("[%s]is not a dir or not exist!" % (androidpath))
            return 1

        #哪个platform中有此product
        platform_has_product_L = []

        if platformpath:
            if imagedate:
                platformimagedatepath = os.path.join(platformpath, imagedate)
                platformimagedateproductpath = os.path.join(platformimagedatepath, product)
                if self.findfile.smbisdir(platformimagedateproductpath):
                    platform_has_product_L.append(platformpath)
            else:
                idate_L = self.findfile.smblistdir(platformpath)
                for idate in idate_L:
                    platformimagedatepath = os.path.join(platformpath, idate)
                    platformimagedateproductpath = os.path.join(platformimagedatepath, product)
                    if self.findfile.smbisdir(platformimagedateproductpath):
                        platform_has_product_L.append(platformpath)
        else:
            platform_L = self.findfile.smblistdir(androidpath)
            for platformfolder in platform_L:
                platformpath = os.path.join(androidpath, platformfolder)
                if imagedate:
                    platformimagedatepath = os.path.join(platformpath, imagedate)
                    platformimagedateproductpath = os.path.join(platformimagedatepath, product)
                    if self.findfile.smbisdir(platformimagedateproductpath):
                        platform_has_product_L.append(platformpath)
                else:
                    idate_L = self.findfile.smblistdir(platformpath)
                    for idate in idate_L:
                        platformimagedatepath = os.path.join(platformpath, idate)
                        platformimagedateproductpath = os.path.join(platformimagedatepath, product)
                        #会出现MemoryError的错误？？？？怎么破？？？
                        #重新改写了smbisdir（）函数，用open打开来判断是否是一个目录。
                        #opendir打开会出现MemoryError
                        if self.findfile.smbisdir(platformimagedateproductpath):
                            platform_has_product_L.append(platformpath)

        platform_has_product_L = list(set(platform_has_product_L))
        platform_has_product_L_len = len(platform_has_product_L)

        if not platform_has_product_L:
            self.printcolor.printerror("not found product: '%s' in [%s]" % (product, os.path.join(platformpath, imagedate)))
            return 1
        elif platform_has_product_L_len > 1:
            self.printcolor.printinfo("found product:'%s' in different platform path,which do you want? [%s - %s] or exit?" % (product, 0, platform_has_product_L_len - 1))
            if platform_has_product_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%4s]" % i,(platform_has_product_L[i])
                self.printcolor.printwarning("so many %s! I cann't list all, just list top %s" % (product, self.printlistmax))
                return 1
            for i in range(0, platform_has_product_L_len):
                print "[%4s]" % i,(platform_has_product_L[i])

            choice = raw_input("please input [%s - %s]" % (0, platform_has_product_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printwarning("exit")
                sys.exit(1)
            if index > platform_has_product_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)

            self.platformpath = platform_has_product_L[index]
        else:
            self.platformpath = platform_has_product_L[0]
        return 0

    def find_imagedate(self,autobuildpath="", platformpath="", imagedate="", product=""):
        #/autobuild
        autobuildpath = self.autobuildpath if autobuildpath == "" else autobuildpath
        platformpath = self.platformpath if platformpath == "" else platformpath
        imagedate = self.imagedate if imagedate == "" else imagedate
        product = self.product if product == "" else product

        #/autobuild/android
        androidpath = os.path.join(autobuildpath, self.android)

        if not self.findfile.smbisdir(androidpath):
            self.printcolor.printerror("[%s]is not a dir or not exist!" % (androidpath))
            return 1

        #/autobuild/android/pxa988/2014-10-23_pxa988-kk4.4
        #platformpath + imagedate
        imagedatepath_L = []
        if platformpath:
            imagedatepath = os.path.join(platformpath, imagedate)
            if product:
                productpath = os.path.join(imagedatepath, product)
                if os.path.isdir(productpath):
                    imagedatepath_L.append(imagedatepath)
            else:
                if os.path.isdir(imagedatepath):
                    imagedatepath_L.append(imagedatepath)
        else:
            platform_L = self.findfile.smblistdir(androidpath)
            for platformfolder in platform_L:
                platformpath = os.path.join(androidpath, platformfolder)
                imagedatepath = os.path.join(platformpath, imagedate)
                if product:
                    productpath = os.path.join(imagedatepath, product)
                    if self.findfile.smbisdir(productpath):
                        imagedatepath_L.append(imagedatepath)
                else:
                    if self.findfile.smbisdir(imagedatepath):
                        imagedatepath_L.append(imagedatepath)
        imagedatepath_L_len = len(imagedatepath_L)

        if not imagedatepath_L:
            #没有找到指定的imagedate的folder
            self.printcolor.printwarning("not found '%s' in [%s]" % (imagedate, androidpath))
            self.printcolor.printwarning("will try to search '%s' in [%s]" % (imagedate, androidpath))
            platform_L = self.findfile.smblistdir(androidpath)

            #存放类似/autobuild/android/pxa988/2014-06-12_pxa988-kk4.4_T7_beta2的一个list
            platformimagedatepath_L = []
            for platformfolder in platform_L:
                platformpath = os.path.join(androidpath, platformfolder)
                idate_L = self.findfile.smblistdir(platformpath)
                for idate in idate_L:
                    if idate == imagedate or idate in imagedate or imagedate in idate:
                        platformimagedatepath = os.path.join(platformpath, idate)
                        if self.findfile.smbisdir(platformimagedatepath):
                            if product:
                                productpath = os.path.join(platformimagedatepath, product)
                                if self.findfile.smbisdir(productpath):
                                    platformimagedatepath_L.append(platformimagedatepath)
                            else:
                                platformimagedatepath_L.append(platformimagedatepath)
                    else:
                        #来个相似搜索,之后具体实现
                        pass

            platformimagedatepath_L_len = len(platformimagedatepath_L)
            if not platformimagedatepath_L:
                self.printcolor.printerror("not search out '%s' in [%s]" % (imagedate, androidpath))
                return 1
            elif platformimagedatepath_L_len >= 1:
                self.printcolor.printinfo("found more '%s' in [%s],which do you want? [%s - %s] or exit?" % (imagedate, androidpath, 0, platformimagedatepath_L_len - 1))
                if platformimagedatepath_L_len > self.printlistmax:
                    for i in range(0, self.printlistmax):
                        print "[%4s]%10s %s" % (i,os.path.basename(os.path.dirname(platformimagedatepath_L[i])), os.path.basename(platformimagedatepath_L[i]))
                    self.printcolor.printwarning("so many '%s'! I cann't list all, just list top %s" % (imagedate, self.printlistmax))
                    return 1

                for i in range(0, platformimagedatepath_L_len):
                    print "[%4s]%10s %s" % (i,os.path.basename(os.path.dirname(platformimagedatepath_L[i])), os.path.basename(platformimagedatepath_L[i]))
                choice = raw_input("please input [%s - %s]" % (0, platformimagedatepath_L_len - 1))
                try:
                    index = int(choice)
                except:
                    self.printcolor.printwarning("exit")
                    sys.exit(1)
                if index > platformimagedatepath_L_len - 1 or index < 0:
                    self.printcolor.printerror("[%s]out of index" % index)
                    sys.exit(1)

                self.platformpath = os.path.dirname(platformimagedatepath_L[index])
                self.imagedate = os.path.basename(platformimagedatepath_L[index])
                self.printcolor.printinfo("your choice is [%s], %s, %s" % (index, self.platformpath, self.imagedate))
        elif imagedatepath_L_len > 1:
            #找到了多个imagedate的folder
            self.printcolor.printinfo("found more '%s' in [%s],which do you want? [%s - %s] or exit?" % (imagedate, androidpath, 0, imagedatepath_L_len - 1))
            if imagedatepath_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%4s]" % i, imagedatepath_L[i]

                self.printcolor.printwarning("so many '%s'! I cann't list all, just list top %s" % (imagedate, self.printlistmax))
                return 1
            for i in range(0, imagedatepath_L_len):
                print "[%4s]" % i, imagedatepath_L[i]

            choice = raw_input("please input [%s - %s]" % (0, imagedatepath_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printwarning("exit")
                sys.exit(1)
            if index > imagedatepath_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)

            self.platformpath = os.path.dirname(imagedatepath_L[index])
            self.imagedate = os.path.basename(imagedatepath_L[index])
        else:
            #找到了1个imagedate的folder
            self.platformpath = os.path.dirname(imagedatepath_L[0])
            self.imagedate = os.path.basename(imagedatepath_L[0])

        return 0

    def select_product(self, platformpath="", imagedate=""):
        platformpath = self.platformpath if platformpath == "" else platformpath
        imagedate = self.imagedate if imagedate == "" else imagedate

        #platformpath + imagedate
        platformimagedatepath = os.path.join(platformpath, imagedate)

        product_L = self.findfile.smblistdir(platformimagedatepath)
        product_L_len = len(product_L)

        productfolder_L = []
        for i in range(0, product_L_len):
            #platformpath + imagedate + product
            platformimagedateproductpath = os.path.join(platformimagedatepath, product_L[i])
            #判断是否是个目录不是就pass了
            if self.findfile.smbisdir(platformimagedateproductpath):
                productfolder_L.append(product_L[i])
        productfolder_L_len = len(productfolder_L)

        if not productfolder_L:
            self.printcolor.printerror("not found any product in [%s]" % (platformimagedatepath))
            return 1
        elif productfolder_L_len > 1:
            self.printcolor.printinfo("found more product in [%s], which do you want? [%s - %s] or exit?" % (platformimagedatepath, 0, productfolder_L_len-1) )
            if productfolder_L_len > self.printlistmax:
                for i in range(0,  self.printlistmax):
                    print "[%2s]" % i,productfolder_L[i]

                self.printcolor.printwarning("so many product! I cann't list all, just list top %s" % (self.printlistmax))
                return 1
            for i in range(0, productfolder_L_len):
                print "[%2s]" % i,productfolder_L[i]
            choice = raw_input("please input [%s - %s]" % (0, productfolder_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printwarning("exit")
                sys.exit(1)
            if index > productfolder_L_len -1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)
            self.product = productfolder_L[index]
            self.printcolor.printinfo("your choice product [%s]" % self.product)
        else:
            self.product = productfolder_L[0]
            self.printcolor.printinfo("your choice product [%s]" % self.product)
        return 0

    #imagedate and product 都没设置的话先选择 platform的路径
    #然后设置选择imagedate
    def select_imagedate(self, platformpath="", product=""):
        #/autobuild/android/pxa988这是platform路径
        platformpath = self.platformpath if platformpath == "" else platformpath

        product = self.product if product == "" else product

        #这里获得的只是包含imagedate的folder的名字。不是完整的路径
        imagedate_L = self.findfile.smblistdir(platformpath)
        imagedate_L_len = len(imagedate_L)

        imagedatefolder_L = []
        for i in range(0, imagedate_L_len):
            #到了这里把imagedate的路径拼完整啦。
            platformimagedate = os.path.join(platformpath, imagedate_L[i])
            if self.findfile.smbisdir(platformimagedate):
                if product:
                    platformimagedateproduct = os.path.join(platformimagedate, product)
                    if self.findfile.smbisdir(platformimagedateproduct):
                        imagedatefolder_L.append(imagedate_L[i])
                else:
                    imagedatefolder_L.append(imagedate_L[i])

        imagedatefolder_L_len = len(imagedatefolder_L)
        imagedatefolder_L.sort(reverse = True)
        #imagedatefolder_L 空的list
        if not imagedatefolder_L:
            self.printcolor.printerror("not found any imagedate in [%s]" % (platformpath))
            return 1
        elif imagedatefolder_L_len > 1:
            self.printcolor.printinfo("found %s imagedate folder in path [%s], which do you want? [%s - %s] or exit?" % (imagedatefolder_L_len, platformpath, 0, imagedatefolder_L_len-1) )
            if imagedatefolder_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%4s]" % i,imagedatefolder_L[i]
                self.printcolor.printwarning("so many imagedate! I cann't list all, just list top %s" % (self.printlistmax))
                return 1
            for i in range(0, imagedatefolder_L_len):
                print "[%4s]" % i,imagedatefolder_L[i]

            choice = raw_input("please input [%s - %s]" % (0, imagedatefolder_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printwarning("exit")
                sys.exit(1)
            if index > imagedatefolder_L_len -1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)
            self.imagedate = imagedatefolder_L[index]
            self.printcolor.printinfo("your choice imagedate [%s]" % self.imagedate)
        #imagedatefolder_L只包含一个的list
        else:
            self.imagedate = imagedatefolder_L[0]
            self.printcolor.printinfo("your choice imagedate [%s]" % self.imagedate)

        return 0

    #imagedate and product 都没设置的话先选择 platform的路径,然后会列出来所有的imagedate的folder供选择imagedate
    def select_platformpath(self, autobuildpath = ""):
        autobuildpath = self.autobuildpath if autobuildpath == "" else autobuildpath
        androidpath = os.path.join(autobuildpath, self.android)

        #判断是否是个folder，并且也判断了是否存在了
        if not self.findfile.smbisdir(androidpath):
            self.printcolor.printerror("[%s]is not a dir or not exist!" % (androidpath))
            return 1

        #列出androidpath目录下的所有的文件，包括文件夹。暂时没有过滤。目前应该都是文件夹。
        platform_L = self.findfile.smblistdir(androidpath)
        platform_L_len = len(platform_L)

        if not platform_L:
            self.printcolor.printerror("not found any platform in [%s]s" % (androidpath))
            return 1

        self.printcolor.printinfo("found %s platform, which do you want? [%s - %s] or exit?" % (platform_L_len, 0, platform_L_len - 1) )
        for i in range(0, platform_L_len):
            #这里没有过滤是否是个folder。暂时不过滤了。目前应该都是folder。
            print "[%2s]" % i, platform_L[i]

        choice = raw_input("please input [%s - %s] " %(0, platform_L_len - 1))
        try:
            index = int(choice)
        except ValueError as e:
            self.printcolor.printwarning("exit")
            sys.exit(1)
        if index > platform_L_len-1 or index < 0:
            self.printcolor.printerror("[%s]out of index" % index)
            sys.exit(1)
        self.platformpath = os.path.join(androidpath, platform_L[index])
        self.printcolor.printinfo("your choice platform [%s]" % self.platformpath)
        return 0

    '''burn images, linux use swdl_linux, windows use .exe'''
    def _start_burn_images(self):
        if not self.swdldriver.checkdriver():
            self.printcolor.printerror("Not install driver,will get driver from ftp server")
            if self.swdldriver.installdriver() != 0:
                self.printcolor.printerror("Install driver fail")
                return 1
            self.printcolor.printinfo("Get driver and install driver successfully")
        if self.systemtype == "Linux":
            os.chmod(self.destswdlfile, stat.S_IRWXU + stat.S_IRWXG + stat.S_IRWXO)
            destswdlabspath = os.path.abspath(self.destswdlpath)
            os.chdir(self.destswdlpath)
            command = "sudo ./%s -D %s -S" % (self.swdlname, self.destblffile)
            ret = os.system(command)
            self.printcolor.printinfo("blffile: [%s]" % (self.destblffile))
            self.printcolor.printinfo("swdlpath:[%s]" % (destswdlabspath))
            self.printcolor.printinfo("command: [cd %s && %s]" % (destswdlabspath, command))
        elif self.systemtype == "Windows":
            destswdlabspath = os.path.abspath(self.destswdlpath)
            os.chdir(self.destswdlpath)
            command = "%s %s" % (self.swdlname, self.destblffile)
            ret = os.system(command)
            self.printcolor.printinfo("blffile: [%s]" % (self.destblffile))
            self.printcolor.printinfo("swdlpath:[%s]" % (destswdlabspath))
            self.printcolor.printinfo("command: [cd %s && %s]" % (destswdlabspath, command))
        return 0

    #准备copyimages。这里会把destpath创建了。blf复制了
    def _prepare_copy_images(self, local="", blf=""):
        local = self.local if local == "" else local
        blf = self.blf if blf == "" else blf

        #1.(1)先精确的查找blf在local下的位置
        if not self.findfile.smbexists(self.localblffile):
            if self.find_dailybuild_blf(local, blf, None) != 0:
                #(2)没找到这个blf文件时，尝试通配搜索其他的blf文件
                self.printcolor.printwarning("try to search other *.blf file")
                if self.find_dailybuild_blf(local, "*.blf", "*.blf") != 0:
                    #没blf文件我怎么知道你需要copy哪些image啊？！
                    return 1

        #2.然后根据blf找image文件了.有了blf文件才好知道需要哪些image
        self.blfimagename_L = self.get_blfimagename_L() #这个有可能有重名的image
        self.blfimageable_D = self.get_blfimageable_D()
        self.blfimagenum_D = self.get_blfimagenum_D()
        self.blfimageidname_D = self.get_blfimageidname_D()
        self.blfimagetimincluded_D = self.get_blfimagetimincluded_D()
        self.localimagefile_L = self.get_localimagefile_L()

        #3.destpath没设置，直接返回
        if self.destpath == "":
            #直接return呢还是给一次机会呢？是创建一个，还是让用户输入呢？为空就获得一个临时目录,create a temp dir
            self.printcolor.printwarning("not set destpath,you can use --dest-path")
            #image date 有的话就在当前目录下建立个imagedate的目录
            if self.imagedate:
                #有product的情况下
                if self.product:
                    self.destpath = os.path.join(os.path.join(".", self.imagedate), self.product)
                    self.printcolor.printinfo("will create a folder: %s" % self.destpath)
                #没有product的情况下
                else:
                    self.destpath = os.path.join(".", self.imagedate)
                    self.printcolor.printerror("not set product,will create a temp folder: %s" % self.destpath)
            #没有的话创建临时的目录
            else:
                self.destpath = tempfile.mkdtemp()
                self.printcolor.printerror("will create a temp folder: %s" % self.destpath)

        #4.destpath设置了，判断存在与否和设置的对不对，不可能是个文件吧？！
        if not os.path.exists(self.destpath):
            self.printcolor.printinfo("%s not exist,create it" % self.destpath)
            os.makedirs(self.destpath)
        else:
            self.printcolor.printinfo("%s exists,not need create" % self.destpath)

        if os.path.isdir(self.destpath):

            #在destpath目录下找swdl
            if self.find_dest_swdl(self.destpath) != 0:
                self.printcolor.printinfo("download %s --> %s" % (self.localswdlzipfile, self.destpath))
                #这里smb的模式需要先把.zip文件下载到本地
                self.destswdlzippath = self.destpath
                self.destswdlzipfile = os.path.join(self.destpath, self.swdlzipname)#路径+swdlzip文件名
                self.findfile.download(self.localswdlzipfile, self.destswdlzipfile)

                #重新设置一下localswdlzipfile的路径
                self.localswdlzipfile = self.destswdlzipfile

                #unzip swdl.zip to this folder
                self.printcolor.printinfo("unzip %s --> %s" % (self.localswdlzipfile, self.destpath))
                self.findfile.unzip(self.localswdlzipfile, self.destpath)
                if self.find_dest_swdl(self.destpath) != 0:
                    return 1

            #(1)然后创建在里面创建个 blf的目录用来存放blf文件
            self.destblfpath = os.path.join(self.destswdlpath, "blf")
            if not os.path.exists(self.destblfpath):
                try:
                    os.mkdir(self.destblfpath)
                except OSError as e:
                    self.printcolor.printerror("%s" % e)
                    return 1

            #(2)blf转换为绝对路径
            self.destblffile = os.path.abspath(os.path.join(self.destblfpath, self.blf))
            if self.findfile.smbexists(self.destblffile):
                #存在
                if self.is_difffile(self.localblffile, self.destblffile):
                    #不一样的文件
                    if self.copyforce:
                        #强制覆盖
                        self.findfile.download(self.localblffile, self.destblffile)
                    else:
                        self.printcolor.printwarning("%s exists, if you want force download use --force" % self.destblffile)
                else:
                    self.printcolor.printwarning("%s is same, no need to copy" % self.blf)
            else:
                #不存在
                self.printcolor.printinfo("download %s --> %s" % (self.localblffile, self.destblfpath))
                self.findfile.download(self.localblffile, self.destblffile)

            #(3)修改blf文件
            self.modify_destblffile(self.destblffile)

            #(4)判断image存放的位置，是父目录还是同级目录
            self.set_is_parent(self.destblffile)
        else:
            self.printcolor.printwarning("%s is a file not a dir, use --dest-path" % self.destpath)
            return 1
        return 0

    def _start_copy_images(self):
        if self.jobsnum > 0:
            #use multithreading
            threadpool = ThreadPool(self.jobsnum)
            if self.is_parent:
                parentpath = os.path.dirname(self.destblfpath)
                for local_image in self.localimagefile_L:
                    threadpool.queueTask(self._copy, (local_image, parentpath), None)
            else:
                for local_image in self.localimagefile_L:
                    threadpool.queueTask(self._copy, (local_image, self.destblfpath), None)
            threadpool.joinAll()
        else:
            #not use multithreading
            if self.is_parent:
                parentpath = os.path.dirname(self.destblfpath)
                for local_image in self.localimagefile_L:
                    self._copy((local_image, parentpath))
            else:
                for local_image in self.localimagefile_L:
                    self._copy((local_image, self.destblfpath))

    def _copy(self, data):
        srcfile = data[0]#源文件路径+名字
        srcfilename = os.path.basename(srcfile)

        destpath = data[1]#目的路径、或者路径+名字
        destfile = os.path.join(destpath, srcfilename)

        if os.path.exists(destfile):
            if self.is_difffile(srcfile, destfile):
                if self.copyforce:
                    self.printcolor.printinfo("download %s --> %s" % (srcfile, destpath))
                    self.findfile.download(srcfile, destfile)
                else:
                    self.printcolor.printwarning("%s exists, if you want force download use --force options" % destfile)
            else:
                self.printcolor.printwarning("%s, %s same, no need to download" % (srcfile, destfile))
        else:
            self.printcolor.printinfo("download %s --> %s" % (srcfile, destpath))
            self.findfile.download(srcfile, destfile)

    def is_samefile(self, f1, f2):
        #return filecmp.cmp(f1,f2)
        return False

    def is_difffile(self, f1, f2):
        return not self.is_samefile(f1,f2)

    def find_dest_swdl(self, dest="", swdlname=""):
        dest = self.destswdlpath if dest == "" else dest
        swdlname = self.swdlname if swdlname == "" else swdlname
        #精确查找,这时候就需要findfile.localfile()，而不是findfile.smabfile()了
        destswdl_L = self.findfile.localfile(dest, swdlname, None)
        destswdl_L_len = len(destswdl_L)
        if not destswdl_L:
            #不可能吧？没找到
            self.printcolor.printerror("not found %s in [%s]" % (swdlname, dest))
            return 1
        elif destswdl_L_len > 1:
            #不可能吧？找到多个
            self.printcolor.printinfo("found more %s ,which do you want? [%s - %s] or exit?" % (swdlname, 0, destswdl_L_len - 1))
            if destswdl_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%2s]" % i, destswdl_L[i]
                self.printcolor.printwarning("so many %s! I cann't list all, just list top %s" % (swdlname, self.printlistmax))
                return 1
            for i in range(0, destswdl_L_len):
                print "[%2s]" % i, destswdl_L[i]
            choice = raw_input("please input [0 - %s] " % (destswdl_L_len -1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printinfo("exit")
                sys.exit(1)
            if index > destswdl_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)

            self.destswdlfile = destswdl_L[index]#路径+文件名
            self.destswdlpath = os.path.dirname(self.destswdlfile)#只有路径
            self.printcolor.printinfo("your choice swdl [%s]" % (self.product))
        else:
            #只找到一个
            self.destswdlfile = destswdl_L[0]#路径+文件名
            self.destswdlpath = os.path.dirname(self.destswdlfile)#只有路径
            self.printcolor.printinfo("your choice swdl [%s]" % (self.product))
        return 0

    def find_dailybuild_blf(self, local="", blf="", pattern=None):
        blf = self.blf if blf == "" else blf
        local = self.local if local == "" else local

        #local path 里的blf
        blf_L = self.findfile.smbfile(local, blf, pattern)
        blf_L_len = len(blf_L)
        if not blf_L:
            #没用在local路径里找到blf文件，直接return
            self.printcolor.printwarning("not found this blf: %s" % blf)
            return 1
        elif blf_L_len > 1:
            #找到多个blf文件
            self.printcolor.printinfo("found more blf[%s] file,which do you want? [%s - %s] or exit?" % (blf,0, blf_L_len-1))
            for i in range(0, blf_L_len):
                print "[%2s]" % i,os.path.basename(blf_L[i])
            choice = raw_input("please input [0 - %s] " % (blf_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printinfo("exit")
                sys.exit(1)
            if index > blf_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)
            self.localblffile = blf_L[index]#路径+blf
            #通配搜索的情况下需要重设blf名字
            self.blf = os.path.basename(self.localblffile)
            self.localblfpath = os.path.dirname(self.localblffile) #只有路径

            self.printcolor.printinfo("your choice blf [%s]" % self.blf)
        else:
            #找到了一个blf文件
            self.localblffile = blf_L[0]#路径+blf

            #通配搜索的情况下需要重设blf名字
            searchblf = os.path.basename(self.localblffile)
            if searchblf != self.blf:
                print "[0]", blf_L[0]
                choice = raw_input("This blf you want? please input [0] " )
                try:
                    index = int(choice)
                except ValueError as e:
                    self.printcolor.printinfo("exit")
                    sys.exit(1)
                if index != 0:
                    self.printcolor.printwarning("exit")
                    sys.exit(1)
                self.blf = searchblf
                self.printcolor.printinfo("your choice blf [%s]" % self.blf)

            self.localblfpath = os.path.dirname(self.localblffile) #只有路径
        return 0

    """判断 image存放的位置，是和blf文件在同一目录还是其父目录
        需要一个blf文件的全路径"""
    def set_is_parent(self, blf=""):
        blf = slef.localblffile if blf == "" else blf
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Path_pattern and ("../" in line or "..\\" in line):
                self.is_parent=True
                return True
        self.is_parent=False
        return False

    '''获取通过local，和blf 获取image的路径'''
    def get_localimagefile_L(self, local="", blf=""):
        blf = self.localblffile if blf == "" else blf
        local = self.local if local=="" else local
        local_image_L = []
        lines_L = self.findfile.get_smbfile_lines_L(blf)
        for line in lines_L:
            if self.Image_Path_pattern in line:
                image = line.split("=")[1]
                imagename = []
                if "../" in image:
                    imagename = image.split("../")
                elif '..\\' in image:
                    imagename = image.split("..\\")
                else:
                    imagename = image.split(" ")
                imagename = imagename[-1].strip()
                local_image_L.extend(self.findfile.smbfile(local, imagename))
        return local_image_L

    '''通过blf文件获得image的名字'''
    def get_blfimagename_L(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        local_image_L = []

        lines_L = self.findfile.get_smbfile_lines_L(blf)
        for line in lines_L:
            if self.Image_Path_pattern in line:
                image = line.split("=")[1]
                imagename = []
                if "../" in image:
                    imagename = image.split("../")
                elif '..\\' in image:
                    imagename = image.split("..\\")
                else:
                    imagename = image.split(" ")

                imagename = imagename[-1].strip()
                local_image_L.append(imagename)

        return local_image_L

    def list_allimagename(self, local="", blf=""):
        blf = self.blf if blf == "" else blf
        local = self.local if local == "" else local

        if self.find_dailybuild_blf(self.local, self.blf, None) != 0:
            #没找到这个blf文件时，尝试通配搜索其他的blf文件
            self.printcolor.printwarning("try to search other *.blf file")
            if self.find_dailybuild_blf(self.local, "", "*.blf") != 0:
                #没blf文件我怎么知道你需要copy哪些image啊？！
                return 1

        self.blfimagenum_D = self.get_blfimagenum_D()
        self.blfimageidname_D = self.get_blfimageidname_D()
        self.blfimageable_D = self.get_blfimageable_D()
        self.blfimagetimincluded_D = self.get_blfimagetimincluded_D()

        num_L = self.blfimagenum_D.keys()
        num_L.sort()
        self.printcolor.printinfo("list all image [ID:?] [Enable:?] [Tim_Include:?] [ImgID:?] = name in blf: %s" % (self.blf))
        for num in num_L:
            print "[ID: %2s] [Enable: %s] [Tim_Include: %s] [ImgID: %s] = %s" \
            % (num, self.blfimageable_D[num],self.blfimagetimincluded_D[num], self.blfimageidname_D[num], self.blfimagenum_D[num])
        self.printcolor.printinfo("list all image [ID:?] [Enable:?] [Tim_Include:?] [ImgID:?] = name in blf: %s" % (self.blf))
        return 0

    def get_blfimagenum_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        image_num_D = {}
        lines_L = self.findfile.get_smbfile_lines_L(blf)
        for line in lines_L:
            if self.Image_Path_pattern in line:
                # 11_Image_Path = cache.img
                imagenum = int(line.split("_")[0].strip())

                image = line.split("=")[1]
                imagename = []
                if "../" in image:
                    imagename = image.split("../")
                elif '..\\' in image:
                    imagename = image.split("..\\")
                else:
                    imagename = image.split(" ")
                imagename = imagename[-1].strip()

                image_num_D.setdefault(imagenum, imagename)
        return image_num_D

    """get image ID_name"""
    def get_blfimageidname_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        imagenum_idname_D = {}
        lines_L = self.findfile.get_smbfile_lines_L(blf)
        for line in lines_L:
            if self.Image_ID_Name_pattern in line:
                # 25_Image_ID_Name = CACH
                imagenum = int(line.split("_")[0].strip())
                id_name = line.split("=")[1].strip()
                imagenum_idname_D.setdefault(imagenum, id_name)
        return imagenum_idname_D

    """get image enable"""
    def get_blfimageable_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        image_able_D = {}
        lines_L = self.findfile.get_smbfile_lines_L(blf)
        for line in lines_L:
            if self.Image_Enable_pattern in line:
                # 1_Image_Enable = 1
                imagenum = int(line.split("_")[0].strip())
                able = line.split("=")[1].strip()
                image_able_D.setdefault(imagenum, able)
        return image_able_D

    """get Tim included"""
    def get_blfimagetimincluded_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        tim_num_D = {}
        lines_L = self.findfile.get_smbfile_lines_L(blf)
        for line in lines_L:
            #1_Image_Tim_Included = 1
            if self.Image_Tim_Included_partten in line:
                imagenum = int(line.split("_")[0].strip())
                tim_included = line.split("=")[1].strip()
                tim_num_D.setdefault(imagenum, tim_included)
        return tim_num_D

    """get disable/enable images num list,
        命令行参数可以传数字，也可以传ID—name"""
    def get_disable_enable_imagenum_L(self, num_or_id):
        try:
            #如果是整数
            num = int(num_or_id)
            num_L = [num]
        except ValueError:
            #image的idname可能对应多个num值
            num_L = []
            for num,idname in self.blfimageidname_D.iteritems():
                #都转换为大写
                if idname == num_or_id.upper():
                    num_L.append(num)
        return num_L

    def modify_destblffile(self, destblffile=""):
        #修改目的路径下的blf文件
        destblffile = self.destblffile if destblffile =="" else destblffile
        fd = open(destblffile, "r")
        lines_L = fd.readlines()
        lines_L_len = len(lines_L)
        fd.close()

        if self.disableimage_L:
            """If you disable this item,other items that have same value in Tim column will be disabled automatically
            Since they have same Tim include property and they should have same status to ensure after burning flash successfully."""
            newblfname = "%s_disable" % self.blf

            #先整理一下需要disabled的image对应的num，得到一个list
            disableimagenum_L = []
            for num_or_id in self.disableimage_L:
                #获取所有的disable的num是一个list
                num_L = self.get_disable_enable_imagenum_L(num_or_id)
                disableimagenum_L.extend(num_L)
            #去重
            disableimagenum_L = list(set(disableimagenum_L))
            #处理tim之后的num的list
            disableimagenum_tim_L = []
            for num in disableimagenum_L:
                #获取tim include的数，大于0的需要处理一下
                timincluded = self.blfimagetimincluded_D.get(num, -1)
                if timincluded == 0:
                    disableimagenum_tim_L.apppend(num)
                elif timincluded > 0:
                    for (numkey, timvalue) in self.blfimagetimincluded_D.items():
                        if timvalue == timincluded:
                            disableimagenum_tim_L.append(numkey)
            #再次把新的的处理过tim的list去重
            disableimagenum_L = list(set(disableimagenum_tim_L))

            for i in range(0, lines_L_len):
                #遍历所有需要disabled的image对应的num的list
                for num in disableimagenum_L:
                    pattern = "%s_%s" % (num, self.Image_Enable_pattern)
                    if pattern == lines_L[i].split("=")[0].strip():
                        lines_L[i] = "%s = %s\r\n" % (pattern, 0)
                        #remove blfimagename in the blf name.IOError 36, File name too long.
                        newblfname = "%s_%s" % (newblfname, num)
                        self.printcolor.printinfo("will disable image: [%2s]%s" % (num, self.blfimagenum_D[num]))
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(disable images):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.enableimage_L:
            newblfname = "%s_enable" % self.blf

            #先整理一下需要enabled的image对应的num，得到一个list
            enableimagenum_L = []
            for num_or_id in self.enableimage_L:
                #获取所有的enable的num是一个list
                num_L = self.get_disable_enable_imagenum_L(num_or_id)
                enableimagenum_L.extend(num_L)
            #去重
            enableimagenum_L = list(set(enableimagenum_L))
            #处理tim之后的num的list
            enableimagenum_tim_L = []
            for num in enableimagenum_L:
                #获取tim include的数，大于0的需要处理一下
                timincluded = self.blfimagetimincluded_D.get(num, -1)
                if timincluded == 0:
                    enableimagenum_tim_L.apppend(num)
                elif timincluded > 0:
                    for (numkey, timvalue) in self.blfimagetimincluded_D.items():
                        if timvalue == timincluded:
                            enableimagenum_tim_L.append(numkey)
            #再次把新的的处理过tim的list去重
            enableimagenum_L = list(set(enableimagenum_tim_L))

            for i in range(0, lines_L_len):
                #遍历所有需要disabled的image对应的num的list
                for num in enableimagenum_L:
                    pattern = "%s_%s" % (num, self.Image_Enable_pattern)
                    if pattern == lines_L[i].split("=")[0].strip():
                        lines_L[i] = "%s = %s\r\n" % (pattern, 1)
                        #remove blfimagename in the blf name.IOError 36, File name too long.
                        newblfname = "%s_%s" % (newblfname, num)
                        self.printcolor.printinfo("will enable image: [%2s]%s" % (num, self.blfimagenum_D[num]))
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(enable images):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.eraseflash:
            newblfname = "%s_erase_all_flash" % self.blf
            for i in range(0, lines_L_len):
                pattern = "%s" % (self.Erase_All_Flash)
                if pattern in lines_L[i].split("=")[0].strip():
                    lines_L[i] = "%s = %s\r\n" % (pattern, 1)
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(Erase All Flash):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.onlyeraseflash:
            newblfname = "%s_only_erase_all_flash" % self.blf
            for i in range(0, lines_L_len):
                pattern = "%s" % (self.Erase_All_Flash)
                if pattern == lines_L[i].split("=")[0].strip():
                    lines_L[i] = "%s = %s\r\n" % (pattern, 2)
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(Only Erase All Flash):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.resetafterburning:
            newblfname = "%s_reset_after_burning" % self.blf
            for i in range(0, lines_L_len):
                pattern = "%s" % (self.UE_Boot_Option)
                if pattern == lines_L[i].split("=")[0].strip():
                    lines_L[i] = "%s = %s\r\n" % (pattern, 1)
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(ResetUE After Burning):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        return 0

    def set_disableimage(self, d):
        #分割字符串，获得image num
        d_L = d.split(",")
        disableimage_L = []
        for index, item in enumerate(d_L):
            try:
                disableimage_L.append(item)
            except ValueError as e:
                pass
        self.disableimage_L =disableimage_L

    def set_enableimage(self, d):
        #分割字符串，获得image num
        d_L = d.split(",")
        enableimage_L = []
        for index, item in enumerate(d_L):
            try:
                enableimage_L.append(item)
            except ValueError as e:
                pass
        self.enableimage_L = enableimage_L

    def set_autobuildpath(self, autobuildpath):
        self.autobuildpath = autobuildpath

    def set_destpath(self, destpath):
        self.destpath = destpath

    def set_onlycopy(self, onlycopy):
        self.onlycopy=onlycopy

    def set_onlyburn(self, onlyburn):
        self.onlyburn=onlyburn

    def set_copyforce(self, f):
        self.copyforce = f

    def set_listimage(self, listimage):
        self.listimage = listimage

    def set_eraseflash(self, eraseornot):
        self.eraseflash = eraseornot

    def set_onlyeraseflash(self, onlyeraseornot):
        self.onlyeraseflash = onlyeraseornot

    def set_resetafterburning(self, reset):
        self.resetafterburning = reset

    def set_printlistmax(self, m):
        self.printlistmax = m

    """print log or not"""
    def set_quiet(self, quiet):
        self.quiet = quiet
        self.printcolor.set_quiet(quiet)

    def set_jobsnum(self, j):
        self.jobsnum = j

    def set_host(self, host):
        self.host = host
        self.findfile.set_host(host)

    def set_username(self, username):
        self.username = username
        self.findfile.set_username(username)

    def set_password(self, password):
        self.password = password
        self.findfile.set_password(password)

#end samba daily burn class

#mount daily build burn class
class MountDailyBurn():
    def __init__(self, imagedate, product, blf):
        #os的类型，Linux还是windows
        self.systemtype = platform.system()

        self.imagedate = imagedate
        self.product = product
        self.blf = blf

        #是否打印输出log
        self.quiet = False

        self.copyforce = False

        #print all image name if set this option
        self.listimage = False

        #默认是当前路径
        self.destpath = ""
        self.onlyburn = False
        self.onlycopy = False

        #是否擦写
        self.eraseflash = False
        #是否只是擦写
        self.onlyeraseflash = False
        #是否烧写后自动重启
        self.resetafterburning = False

        #swdl.zip name
        self.swdlzipname = "Software_Downloader.zip"
        #softwaredownloader name
        if self.systemtype == "Linux":
            self.swdlname = "swdl_linux"
            self.mountpath= os.path.join("/","autobuild")
        elif self.systemtype == "Windows":
            self.swdlname = "SWDownloader.exe"
            self.mountpath= os.path.join("\\\\10.38.116.40","autobuild")
        else:
            self.mountpath = ""
            self.swdlname = ""

        # autobuild + android = 默认的autobuild images的路径
        self.android = "android"

        #local path,where source image are
        self.local = os.path.join(self.mountpath, "android", self.imagedate, self.product)

        self.Image_Enable_pattern = "Image_Enable"
        self.Image_ID_Name_pattern = "Image_ID_Name"
        self.Image_Tim_Included_partten = "Image_Tim_Included"
        self.Image_Path_pattern = "Image_Path"
        self.Erase_All_Flash = "Erase_All_Flash"
        self.UE_Boot_Option = "UE_Boot_Option"

        self.findfile = FindFile()

        self.printcolor = PrintColor()

        #blf 里的image name
        self.blfimagename_L = []

        #不烧写的image
        self.disableimage_L = []
        #只烧写的image
        self.enableimage_L = []

        #image enable or disable num -->0/1 enable/disable
        self.blfimageable_D = {}

        #blf 里的image num --> name
        self.blfimagenum_D = {}

        #blf 里的image id name --> num 映射
        self.blfimageidname_D = {}

        #blf 里的image num --> time included
        self.blfimagetimincluded_D = {}

        self.is_parent = False

        #源image路径下的blf路径/绝对路径
        self.localblfpath = "" #只有路径
        self.localblffile= "" #路径+blf文件名

        #目的路径下的blf路径/绝对路径
        self.destblfpath = "" #只有路径
        self.destblffile= "" #路径+blf文件名

        #目的路径下的swdl路径/绝对路径
        self.destswdlpath = "" #只有路径.烧image时要切入这个目录中
        self.destswdlfile = ""

        #源路径下的swdl.zip路径/绝对路径
        self.localswdlzippath = "" #只有路径
        self.localswdlzipfile= "" #路径+swdlzip文件名

        #image base path
        self.platformpath = ""

        self.swdldriver = SwdlDriver()

        self.printlistmax = 20

        #线程池的个数
        self.jobsnum = 0
    #end __init__()

    def start(self):
        if self.listimage:
            if self._prepare_imagedate_product() != 0:
                return 1
            self.list_allimagename()
            return 0

        if self.onlycopy and self.onlyburn:
            self.printcolor.printerror('onlycopy or onlyburn?')
            return 1

        # copy images and burn images
        #1,
        if self._prepare_imagedate_product() != 0:
            return 1
        #2.prepare copy images.准备destpath路径。复制blf文件／修改blf文件
        if self._prepare_copy_images() != 0:
            return 1

        if self.onlycopy:
            #3.start copy images
            self._start_copy_images()
        else:
            #3.start copy images
            self._start_copy_images()
            #4.start burn images
            self._start_burn_images()

        return 0


    """preepare imagedtae and product"""
    def _prepare_imagedate_product(self):
        if not self.imagedate and not self.product:
            #imagedate 和 product 都没有,先选择 platformpath
            # /autobuild/pxa988
            # /autobuild/pxa1908
            if self.select_platformpath() != 0:
                return 1

            if self.select_imagedate() != 0:
                return 1

            #imagedate设置好了就在imagedate找不同的product的目录
            if self.select_product() != 0:
                return 1
        elif self.imagedate and not self.product:
            #imagedate 有了要在不同的platform 目录下搜索这个imagedate的folder
            if self.find_imagedate() != 0:
                return 1

            #imagedate设置好了就在imagedate找不同的product的目录
            if self.select_product() != 0:
                return 1
        elif not self.imagedate and self.product:
            #product 有了要在不同的platform/imagedate 目录下搜索这个product的folder
            #确定platform
            if self.find_product() != 0:
                return 1

            #选择imagedate
            if self.select_imagedate() != 0:
                return 1
        else:
            #都有的情况
            #imagedate 有了要在不同的platform 目录下搜索这个imagedate的folder
            if self.find_imagedate() != 0:
                return 1

            if self.find_product() != 0:
                return 1

        #到此 "imagedate:", "platform:", "product:"这三个都有了, 然后设置一下local
        self.local = os.path.join(self.platformpath, self.imagedate, self.product)
        self.localswdlzippath = os.path.join(self.platformpath, self.imagedate)
        self.localswdlzipfile= os.path.join(self.platformpath, self.imagedate, self.swdlzipname)
        return 0

    """prepare blf file name"""
    def _prepare_blf(self):
        if self.find_dailybuild_blf(self.local, self.blf, None) != 0:
            #没找到这个blf文件时，尝试通配搜索其他的blf文件
            self.printcolor.printwarning("try to search '*.blf'")
            if self.find_dailybuild_blf(self.local, "", "*.blf") != 0:
                #没blf文件我怎么知道你需要copy哪些image啊？！
                return 1
        return 0

    def find_product(self,mountpath="", platformpath="", imagedate="", product=""):
        #/autobuild
        mountpath = self.mountpath if mountpath == "" else mountpath
        platformpath = self.platformpath if platformpath == "" else platformpath
        imagedate = self.imagedate if imagedate == "" else imagedate
        product = self.product if product == "" else product

        #/autobuild/android
        androidpath = os.path.join(mountpath, "android")

        if not os.path.exists(androidpath):
            self.printcolor.printerror("[%s]not exists this path!" % (androidpath))
            return 1

        if not os.path.isdir(androidpath):
            self.printcolor.printerror("[%s]is not a dir!" % (androidpath))
            return 1

        #哪个platform中有此product
        platform_has_product_L = []

        if platformpath:
            if imagedate:
                platformimagedatepath = os.path.join(platformpath, imagedate)
                platformimagedateproductpath = os.path.join(platformimagedatepath, product)
                if os.path.isdir(platformimagedateproductpath):
                    platform_has_product_L.append(platformpath)
            else:
                for idate in os.listdir(platformpath):
                    platformimagedatepath = os.path.join(platformpath, idate)
                    platformimagedateproductpath = os.path.join(platformimagedatepath, product)
                    if os.path.isdir(platformimagedateproductpath):
                        platform_has_product_L.append(platformpath)
        else:
            platform_L = os.listdir(androidpath)
            for platformfolder in platform_L:
                platformpath = os.path.join(androidpath, platformfolder)
                if imagedate:
                    platformimagedatepath = os.path.join(platformpath, imagedate)
                    platformimagedateproductpath = os.path.join(platformimagedatepath, product)
                    if os.path.isdir(platformimagedateproductpath):
                        platform_has_product_L.append(platformpath)
                else:
                    for idate in os.listdir(platformpath):
                        platformimagedatepath = os.path.join(platformpath, idate)
                        platformimagedateproductpath = os.path.join(platformimagedatepath, product)
                        if os.path.isdir(platformimagedateproductpath):
                            platform_has_product_L.append(platformpath)

        platform_has_product_L = list(set(platform_has_product_L))
        platform_has_product_L_len = len(platform_has_product_L)

        if not platform_has_product_L:
            self.printcolor.printerror("not found product: '%s' in [%s]" % (product, os.path.join(platformpath, imagedate)))
            return 1
        elif platform_has_product_L_len > 1:
            self.printcolor.printinfo("found product:'%s' in different platform path,which do you want? [%s - %s] or exit?" % (product, 0, platform_has_product_L_len - 1))
            if platform_has_product_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%4s]" % i,(platform_has_product_L[i])
                self.printcolor.printwarning("so many %s! I cann't list all, just list top %s" % (product, self.printlistmax))
                return 1
            for i in range(0, platform_has_product_L_len):
                print "[%4s]" % i,(platform_has_product_L[i])

            choice = raw_input("please input [%s - %s]" % (0, platform_has_product_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printwarning("exit")
                sys.exit(1)
            if index > platform_has_product_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)

            self.platformpath = platform_has_product_L[index]
        else:
            self.platformpath = platform_has_product_L[0]
        return 0

    def find_imagedate(self,mountpath="", platformpath="", imagedate="", product=""):
        #/autobuild
        mountpath = self.mountpath if mountpath == "" else mountpath
        platformpath = self.platformpath if platformpath == "" else platformpath
        imagedate = self.imagedate if imagedate == "" else imagedate
        product = self.product if product == "" else product

        #/autobuild/android
        androidpath = os.path.join(mountpath, "android")

        if not os.path.exists(androidpath):
            self.printcolor.printerror("[%s]not exists this path!" % (androidpath))
            return 1

        if not os.path.isdir(androidpath):
            self.printcolor.printerror("[%s]is not a dir!" % (androidpath))
            return 1

        #/autobuild/android/pxa988/2014-10-23_pxa988-kk4.4
        #platformpath + imagedate
        imagedatepath_L = []


        if platformpath:
            imagedatepath = os.path.join(platformpath, imagedate)
            if product:
                productpath = os.path.join(imagedatepath, product)
                if os.path.isdir(productpath):
                    imagedatepath_L.append(imagedatepath)
            else:
                if os.path.isdir(imagedatepath):
                    imagedatepath_L.append(imagedatepath)
        else:
            platform_L = os.listdir(androidpath)
            for platformfolder in platform_L:
                platformpath = os.path.join(androidpath, platformfolder)
                imagedatepath = os.path.join(platformpath, imagedate)
                if product:
                    productpath = os.path.join(imagedatepath, product)
                    if os.path.isdir(productpath):
                        imagedatepath_L.append(imagedatepath)
                else:
                    if os.path.isdir(imagedatepath):
                        imagedatepath_L.append(imagedatepath)

        imagedatepath_L_len = len(imagedatepath_L)

        if not imagedatepath_L:
            #没有找到指定的imagedate的folder
            self.printcolor.printwarning("not found '%s' in [%s]" % (imagedate, androidpath))
            self.printcolor.printwarning("will try to search '%s' in [%s]" % (imagedate, androidpath))
            platform_L = os.listdir(androidpath)

            #存放类似/autobuild/android/pxa988/2014-06-12_pxa988-kk4.4_T7_beta2的一个list
            platformimagedatepath_L = []
            for platformfolder in platform_L:
                platformpath = os.path.join(androidpath, platformfolder)
                idate_L = os.listdir(platformpath)
                for idate in idate_L:
                    if idate == imagedate or idate in imagedate or imagedate in idate:
                        platformimagedatepath = os.path.join(platformpath, idate)
                        if os.path.isdir(platformimagedatepath):
                            if product:
                                productpath = os.path.join(platformimagedatepath, product)
                                if os.path.isdir(productpath):
                                    platformimagedatepath_L.append(platformimagedatepath)
                            else:
                                platformimagedatepath_L.append(platformimagedatepath)
                    else:
                        #来个相似搜索
                        pass

            platformimagedatepath_L_len = len(platformimagedatepath_L)
            if not platformimagedatepath_L:
                self.printcolor.printerror("not search out '%s' in [%s]" % (imagedate, androidpath))
                return 1
            elif platformimagedatepath_L_len >= 1:
                self.printcolor.printinfo("found more '%s' in [%s],which do you want? [%s - %s] or exit?" % (imagedate, androidpath, 0, platformimagedatepath_L_len - 1))
                if platformimagedatepath_L_len > self.printlistmax:
                    for i in range(0, self.printlistmax):
                        print "[%4s]%10s %s" % (i,os.path.basename(os.path.dirname(platformimagedatepath_L[i])), os.path.basename(platformimagedatepath_L[i]))
                    self.printcolor.printwarning("so many '%s'! I cann't list all, just list top %s" % (imagedate, self.printlistmax))
                    return 1

                for i in range(0, platformimagedatepath_L_len):
                    print "[%4s]%10s %s" % (i,os.path.basename(os.path.dirname(platformimagedatepath_L[i])), os.path.basename(platformimagedatepath_L[i]))
                choice = raw_input("please input [%s - %s]" % (0, platformimagedatepath_L_len - 1))
                try:
                    index = int(choice)
                except:
                    self.printcolor.printwarning("exit")
                    sys.exit(1)
                if index > platformimagedatepath_L_len - 1 or index < 0:
                    self.printcolor.printerror("[%s]out of index" % index)
                    sys.exit(1)

                self.platformpath = os.path.dirname(platformimagedatepath_L[index])
                self.imagedate = os.path.basename(platformimagedatepath_L[index])
                self.printcolor.printinfo("your choice is [%s], %s, %s" % (index, self.platformpath, self.imagedate))
        elif imagedatepath_L_len > 1:
            #找到了多个imagedate的folder
            self.printcolor.printinfo("found more '%s' in [%s],which do you want? [%s - %s] or exit?" % (imagedate, androidpath, 0, imagedatepath_L_len - 1))
            if imagedatepath_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%4s]" % i, imagedatepath_L[i]

                self.printcolor.printwarning("so many '%s'! I cann't list all, just list top %s" % (imagedate, self.printlistmax))
                return 1
            for i in range(0, imagedatepath_L_len):
                print "[%4s]" % i, imagedatepath_L[i]

            choice = raw_input("please input [%s - %s]" % (0, imagedatepath_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printwarning("exit")
                sys.exit(1)
            if index > imagedatepath_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)

            self.platformpath = os.path.dirname(imagedatepath_L[index])
            self.imagedate = os.path.basename(imagedatepath_L[index])
        else:
            #找到了1个imagedate的folder
            self.platformpath = os.path.dirname(imagedatepath_L[0])
            self.imagedate = os.path.basename(imagedatepath_L[0])

        return 0

    def select_product(self, platformpath="", imagedate=""):
        platformpath = self.platformpath if platformpath == "" else platformpath
        imagedate = self.imagedate if imagedate == "" else imagedate

        #platformpath + imagedate
        platformimagedatepath = os.path.join(platformpath, imagedate)

        product_L = os.listdir(platformimagedatepath)
        product_L_len = len(product_L)

        productfolder_L = []
        for i in range(0, product_L_len):
            #platformpath + imagedate + product
            platformimagedateproductpath = os.path.join(platformimagedatepath, product_L[i])
            #判断是否是个目录不是就pass了
            if os.path.isdir(platformimagedateproductpath):
                productfolder_L.append(product_L[i])
        productfolder_L_len = len(productfolder_L)

        if not productfolder_L:
            self.printcolor.printerror("not found any product in [%s]" % (platformimagedatepath))
            return 1
        elif productfolder_L_len > 1:
            self.printcolor.printinfo("found more product in [%s], which do you want? [%s - %s] or exit?" % (platformimagedatepath, 0, productfolder_L_len-1) )
            if productfolder_L_len > self.printlistmax:
                for i in range(0,  self.printlistmax):
                    print "[%2s]" % i,productfolder_L[i]

                self.printcolor.printwarning("so many product! I cann't list all, just list top %s" % (self.printlistmax))
                return 1
            for i in range(0, productfolder_L_len):
                print "[%2s]" % i,productfolder_L[i]
            choice = raw_input("please input [%s - %s]" % (0, productfolder_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printwarning("exit")
                sys.exit(1)
            if index > productfolder_L_len -1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)
            self.product = productfolder_L[index]
            self.printcolor.printinfo("your choice product [%s]" % self.product)
        else:
            self.product = productfolder_L[0]
            self.printcolor.printinfo("your choice product [%s]" % self.product)
        return 0

    #imagedate and product 都没设置的话先选择 platform的路径
    #然后设置选择imagedate
    def select_imagedate(self, platformpath="", product=""):
        #/autobuild/android/pxa988这是platform路径
        platformpath = self.platformpath if platformpath == "" else platformpath

        product = self.product if product == "" else product

        imagedate_L = os.listdir(platformpath)
        imagedate_L_len = len(imagedate_L)

        imagedatefolder_L = []
        for i in range(0, imagedate_L_len):
            platformimagedate = os.path.join(platformpath, imagedate_L[i])
            if os.path.isdir(platformimagedate):
                if product:
                    platformimagedateproduct = os.path.join(platformimagedate, product)
                    if os.path.isdir(platformimagedateproduct):
                        imagedatefolder_L.append(imagedate_L[i])
                else:
                    imagedatefolder_L.append(imagedate_L[i])

        imagedatefolder_L_len = len(imagedatefolder_L)
        imagedatefolder_L.sort(reverse = True)
        if not imagedatefolder_L:
            self.printcolor.printerror("not found any imagedate in [%s]" % (platformpath))
            return 1
        elif imagedatefolder_L_len > 1:
            self.printcolor.printinfo("found %s imagedate folder in path [%s], which do you want? [%s - %s] or exit?" % (imagedatefolder_L_len, platformpath, 0, imagedatefolder_L_len-1) )
            if imagedatefolder_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%4s]" % i,imagedatefolder_L[i]
                self.printcolor.printwarning("so many imagedate! I cann't list all, just list top %s" % (self.printlistmax))
                return 1
            for i in range(0, imagedatefolder_L_len):
                print "[%4s]" % i,imagedatefolder_L[i]

            choice = raw_input("please input [%s - %s]" % (0, imagedatefolder_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printwarning("exit")
                sys.exit(1)
            if index > imagedatefolder_L_len -1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)
            self.imagedate = imagedatefolder_L[index]
            self.printcolor.printinfo("your choice imagedate [%s]" % self.imagedate)
        else:
            self.imagedate = imagedatefolder_L[0]
            self.printcolor.printinfo("your choice imagedate [%s]" % self.imagedate)

        return 0

    #imagedate and product 都没设置的话先选择 platform的路径
    #然后设置选择imagedate
    def select_platformpath(self, mountpath = ""):
        mountpath = self.mountpath if mountpath == "" else mountpath
        androidpath = os.path.join(mountpath, "android")

        #判断是否是个folder，并且也判断了是否存在了
        if not os.path.isdir(androidpath):
            self.printcolor.printerror("[%s]is not a dir or not exist!" % (androidpath))
            return 1

        #列出androidpath目录下的所有的文件，包括文件夹。暂时没有过滤。目前应该都是文件夹。
        platform_L = os.listdir(androidpath)
        platform_L_len = len(platform_L)

        if not platform_L:
            self.printcolor.printerror("not found any platform in [%s]s" % (androidpath))
            return 1

        self.printcolor.printinfo("found %s platform, which do you want? [%s - %s] or exit?" % (platform_L_len, 0, platform_L_len - 1) )
        for i in range(0, platform_L_len):
            #这里没有过滤是否是个folder。暂时不过滤了。目前应该都是folder。
            print "[%2s]" % i, platform_L[i]

        choice = raw_input("please input [%s - %s] " %(0, platform_L_len - 1))
        try:
            index = int(choice)
        except ValueError as e:
            self.printcolor.printwarning("exit")
            sys.exit(1)
        if index > platform_L_len-1 or index < 0:
            self.printcolor.printerror("[%s]out of index" % index)
            sys.exit(1)
        self.platformpath = os.path.join(androidpath, platform_L[index])
        self.printcolor.printinfo("your choice platform [%s]" % self.platformpath)
        return 0

    '''burn images, linux use swdl_linux, windows use .exe'''
    def _start_burn_images(self):
        if not self.swdldriver.checkdriver():
            self.printcolor.printerror("Not install driver,will get driver from ftp server")
            if self.swdldriver.installdriver() != 0:
                self.printcolor.printerror("Install driver fail")
                return 1
            self.printcolor.printinfo("Get driver and install driver successfully")
        if self.systemtype == "Linux":
            os.chmod(self.destswdlfile, stat.S_IRWXU + stat.S_IRWXG + stat.S_IRWXO)
            destswdlabspath = os.path.abspath(self.destswdlpath)
            os.chdir(self.destswdlpath)
            command = "sudo ./%s -D %s -S" % (self.swdlname, self.destblffile)
            ret = os.system(command)
            self.printcolor.printinfo("blffile: [%s]" % (self.destblffile))
            self.printcolor.printinfo("swdlpath:[%s]" % (destswdlabspath))
            self.printcolor.printinfo("command: [cd %s && %s]" % (destswdlabspath, command))
        elif self.systemtype == "Windows":
            destswdlabspath = os.path.abspath(self.destswdlpath)
            os.chdir(self.destswdlpath)
            command = "%s %s" % (self.swdlname, self.destblffile)
            ret = os.system(command)
            self.printcolor.printinfo("blffile: [%s]" % (self.destblffile))
            self.printcolor.printinfo("swdlpath:[%s]" % (destswdlabspath))
            self.printcolor.printinfo("command: [cd %s && %s]" % (destswdlabspath, command))
        return 0

    #准备copyimages。这里会把destpath创建了。blf复制了
    def _prepare_copy_images(self, local="", blf=""):
        local = self.local if local == "" else local
        blf = self.blf if blf == "" else blf

        #1.(1)先精确的查找blf在local下的位置
        if not os.path.exists(self.localblffile):
            if self.find_dailybuild_blf(local, blf, None) != 0:
                #(2)没找到这个blf文件时，尝试通配搜索其他的blf文件
                self.printcolor.printwarning("try to search other *.blf file")
                if self.find_dailybuild_blf(local, "*.blf", "*.blf") != 0:
                    #没blf文件我怎么知道你需要copy哪些image啊？！
                    return 1

        #2.然后根据blf找image文件了.有了blf文件才好知道需要哪些image
        self.blfimagename_L = self.get_blfimagename_L() #这个有可能有重名的image
        self.blfimageable_D = self.get_blfimageable_D()
        self.blfimagenum_D = self.get_blfimagenum_D()
        self.blfimageidname_D = self.get_blfimageidname_D()
        self.blfimagetimincluded_D = self.get_blfimagetimincluded_D()
        self.localimagefile_L = self.get_localimagefile_L()

        #3.destpath没设置，直接返回
        if self.destpath == "":
            #直接return呢还是给一次机会呢？是创建一个，还是让用户输入呢？为空就获得一个临时目录,create a temp dir
            self.printcolor.printwarning("not set destpath,you can use --dest-path")
            #image date 有的话就在当前目录下建立个imagedate的目录
            if self.imagedate:
                #有product的情况下
                if self.product:
                    self.destpath =os.path.join(os.path.join(".", self.imagedate), self.product)
                    self.printcolor.printinfo("will create a folder: %s" % self.destpath)
                #没有product的情况下
                else:
                    self.destpath = os.path.join(".", self.imagedate)
                    self.printcolor.printerror("not set product,will create a temp folder: %s" % self.destpath)
            #没有的话创建临时的目录
            else:
                self.destpath = tempfile.mkdtemp()
                self.printcolor.printerror("will create a temp folder: %s" % self.destpath)

        #4.destpath设置了，判断存在与否和设置的对不对，不可能是个文件吧？！
        if not os.path.exists(self.destpath):
            self.printcolor.printinfo("%s not exist,create it" % self.destpath)
            os.makedirs(self.destpath)
        else:
            self.printcolor.printinfo("%s exists,not need create" % self.destpath)

        if os.path.isdir(self.destpath):

            #在destpath目录下找swdl
            if self.find_dest_swdl(self.destpath) != 0:
                #unzip swdl.zip to this folder
                self.printcolor.printinfo("unzip %s --> %s" % (self.localswdlzipfile, self.destpath))
                self.findfile.unzip(self.localswdlzipfile, self.destpath)
                if self.find_dest_swdl(self.destpath) != 0:
                    return 1

            #(1)然后创建在里面创建个 blf的目录用来存放blf文件
            self.destblfpath = os.path.join(self.destswdlpath, "blf")
            if not os.path.exists(self.destblfpath):
                try:
                    os.mkdir(self.destblfpath)
                except OSError as e:
                    self.printcolor.printerror("%s" % e)
                    return 1

            #(2)blf转换为绝对路径
            self.destblffile = os.path.abspath(os.path.join(self.destblfpath, self.blf))
            if os.path.exists(self.destblffile):
                #存在
                if self.is_difffile(self.localblffile, self.destblffile):
                    #不一样的文件
                    if self.copyforce:
                        #强制覆盖
                        shutil.copy(self.localblffile, self.destblfpath)
                    else:
                        self.printcolor.printwarning("%s exists, if you want force copy use --force" % self.destblffile)
                else:
                    self.printcolor.printwarning("%s is same, no need to copy" % self.blf)
            else:
                #不存在
                self.printcolor.printinfo("copy %s --> %s" % (self.localblffile, self.destblfpath))
                shutil.copy(self.localblffile, self.destblfpath)

            #(3)修改blf文件
            self.modify_destblffile(self.destblffile)

            #(4)判断image存放的位置，是父目录还是同级目录
            self.set_is_parent(self.destblffile)
        else:
            self.printcolor.printwarning("%s is a file not a dir, use --dest-path" % self.destpath)
            return 1
        return 0

    def _start_copy_images(self):
        if self.jobsnum > 0:
            #use multithreading
            threadpool = ThreadPool(self.jobsnum)
            if self.is_parent:
                parentpath = os.path.dirname(self.destblfpath)
                for local_image in self.localimagefile_L:
                    threadpool.queueTask(self._copy, (local_image, parentpath), None)
            else:
                for local_image in self.localimagefile_L:
                    threadpool.queueTask(self._copy, (local_image, self.destblfpath), None)
            threadpool.joinAll()
        else:
            #not use multithreading
            if self.is_parent:
                parentpath = os.path.dirname(self.destblfpath)
                for local_image in self.localimagefile_L:
                    self._copy((local_image, parentpath))
            else:
                for local_image in self.localimagefile_L:
                    self._copy((local_image, self.destblfpath))

    def _copy(self, data):
        srcfile = data[0]#源文件路径+名字
        srcfilename = os.path.basename(srcfile)

        destpath = data[1]#目的路径、或者路径+名字
        destfile = os.path.join(destpath, srcfilename)

        if os.path.exists(destfile):
            if self.is_difffile(srcfile, destfile):
                if self.copyforce:
                    self.printcolor.printinfo("copy %s --> %s" % (srcfile, destpath))
                    shutil.copy(srcfile, destpath)
                else:
                    self.printcolor.printwarning("%s exists, if you want force copy use --force options" % destfile)
            else:
                self.printcolor.printwarning("%s, %s same, no need to copy" % (srcfile, destfile))
        else:
            self.printcolor.printinfo("copy %s --> %s" % (srcfile, destpath))
            shutil.copy(srcfile, destpath)

    def is_samefile(self, f1, f2):
        return filecmp.cmp(f1,f2)

    def is_difffile(self, f1, f2):
        return not self.is_samefile(f1,f2)

    def find_dest_swdl(self, dest="", swdlname=""):
        dest = self.destswdlpath if dest == "" else dest
        swdlname = self.swdlname if swdlname == "" else swdlname
        #精确查找
        destswdl_L = self.findfile.localfile(dest, swdlname, None)
        destswdl_L_len = len(destswdl_L)
        if not destswdl_L:
            #不可能吧？没找到
            self.printcolor.printerror("not found %s in [%s]" % (swdlname, dest))
            return 1
        elif destswdl_L_len > 1:
            #不可能吧？找到多个
            self.printcolor.printinfo("found more %s ,which do you want? [%s - %s] or exit?" % (swdlname, 0, destswdl_L_len - 1))
            if destswdl_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%2s]" % i, destswdl_L[i]
                self.printcolor.printwarning("so many %s! I cann't list all, just list top %s" % (swdlname, self.printlistmax))
                return 1
            for i in range(0, destswdl_L_len):
                print "[%2s]" % i, destswdl_L[i]
            choice = raw_input("please input [0 - %s] " % (destswdl_L_len -1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printinfo("exit")
                sys.exit(1)
            if index > destswdl_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)

            self.destswdlfile = destswdl_L[index]#路径+文件名
            self.destswdlpath = os.path.dirname(self.destswdlfile)#只有路径
            self.printcolor.printinfo("your choice swdl [%s]" % (self.product))
        else:
            #只找到一个
            self.destswdlfile = destswdl_L[0]#路径+文件名
            self.destswdlpath = os.path.dirname(self.destswdlfile)#只有路径
            self.printcolor.printinfo("your choice swdl [%s]" % (self.product))
        return 0

    def find_dailybuild_blf(self, local="", blf="", pattern=None):
        blf = self.blf if blf == "" else blf
        local = self.local if local == "" else local

        #local path 里的blf
        blf_L = self.findfile.localfile(local, blf, pattern)
        blf_L_len = len(blf_L)
        if not blf_L:
            #没用在local路径里找到blf文件，直接return
            self.printcolor.printwarning("not found this blf: %s" % blf)
            return 1
        elif blf_L_len > 1:
            #找到多个blf文件
            self.printcolor.printinfo("found more blf[%s] file,which do you want? [%s - %s] or exit?" % (blf,0, blf_L_len-1))
            for i in range(0, blf_L_len):
                print "[%2s]" % i,os.path.basename(blf_L[i])
            choice = raw_input("please input [0 - %s] " % (blf_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printinfo("exit")
                sys.exit(1)
            if index > blf_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)
            self.localblffile = blf_L[index]#路径+blf
            #通配搜索的情况下需要重设blf名字
            self.blf = os.path.basename(self.localblffile)
            self.localblfpath = os.path.dirname(self.localblffile) #只有路径

            self.printcolor.printinfo("your choice blf [%s]" % self.blf)
        else:
            #找到了一个blf文件
            self.localblffile = blf_L[0]#路径+blf

            #通配搜索的情况下需要重设blf名字
            searchblf = os.path.basename(self.localblffile)
            if searchblf != self.blf:
                print "[0]", blf_L[0]
                choice = raw_input("This blf you want? please input [0] " )
                try:
                    index = int(choice)
                except ValueError as e:
                    self.printcolor.printinfo("exit")
                    sys.exit(1)
                if index != 0:
                    self.printcolor.printwarning("exit")
                    sys.exit(1)
                self.blf = searchblf
                self.printcolor.printinfo("your choice blf [%s]" % self.blf)

            self.localblfpath = os.path.dirname(self.localblffile) #只有路径
        return 0

    """判断 image存放的位置，是和blf文件在同一目录还是其父目录
        需要一个blf文件的全路径"""
    def set_is_parent(self, blf=""):
        blf = slef.localblffile if blf == "" else blf
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Path_pattern and ("../" in line or "..\\" in line):
                self.is_parent=True
                return True
        self.is_parent=False
        return False

    '''获取通过local，和blf 获取image的路径'''
    def get_localimagefile_L(self, local="", blf=""):
        blf = self.localblffile if blf == "" else blf
        local = self.local if local=="" else local
        local_image_L = []
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Path_pattern in line:
                image = line.split("=")[1]
                imagename = []
                if "../" in image:
                    imagename = image.split("../")
                elif '..\\' in image:
                    imagename = image.split("..\\")
                else:
                    imagename = image.split(" ")
                imagename = imagename[-1].strip()
                local_image_L.extend(self.findfile.localfile(local, imagename))
        fd.close()
        return local_image_L

    '''通过blf文件获得image的名字'''
    def get_blfimagename_L(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        local_image_L = []

        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Path_pattern in line:
                image = line.split("=")[1]
                imagename = []
                if "../" in image:
                    imagename = image.split("../")
                elif '..\\' in image:
                    imagename = image.split("..\\")
                else:
                    imagename = image.split(" ")

                imagename = imagename[-1].strip()
                local_image_L.append(imagename)
        fd.close()

        return local_image_L

    def list_allimagename(self, local="", blf=""):
        blf = self.blf if blf == "" else blf
        local = self.local if local == "" else local

        if self.find_dailybuild_blf(self.local, self.blf, None) != 0:
            #没找到这个blf文件时，尝试通配搜索其他的blf文件
            self.printcolor.printwarning("try to search other *.blf file")
            if self.find_dailybuild_blf(self.local, "", "*.blf") != 0:
                #没blf文件我怎么知道你需要copy哪些image啊？！
                return 1

        self.blfimagenum_D = self.get_blfimagenum_D()
        self.blfimageidname_D = self.get_blfimageidname_D()
        self.blfimageable_D = self.get_blfimageable_D()
        self.blfimagetimincluded_D = self.get_blfimagetimincluded_D()

        num_L = self.blfimagenum_D.keys()
        num_L.sort()
        self.printcolor.printinfo("list all image [ID:?] [Enable:?] [Tim_Include:?] [ImgID:?] = name in blf: %s" % (self.blf))
        for num in num_L:
            print "[ID: %2s] [Enable: %s] [Tim_Include: %s] [ImgID: %s] = %s" \
            % (num, self.blfimageable_D[num],self.blfimagetimincluded_D[num], self.blfimageidname_D[num], self.blfimagenum_D[num])
        self.printcolor.printinfo("list all image [ID:?] [Enable:?] [Tim_Include:?] [ImgID:?] = name in blf: %s" % (self.blf))
        return 0

    def get_blfimagenum_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        image_num_D = {}
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Path_pattern in line:
                # 11_Image_Path = cache.img
                imagenum = int(line.split("_")[0].strip())

                image = line.split("=")[1]
                imagename = []
                if "../" in image:
                    imagename = image.split("../")
                elif '..\\' in image:
                    imagename = image.split("..\\")
                else:
                    imagename = image.split(" ")
                imagename = imagename[-1].strip()

                image_num_D.setdefault(imagenum, imagename)
        fd.close()
        return image_num_D

    def get_blfimageidname_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        image_idname_D = {}
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_ID_Name_pattern in line:
                # 25_Image_ID_Name = CACH
                imagenum = int(line.split("_")[0].strip())
                id_name = line.split("=")[1].strip()
                image_idname_D.setdefault(imagenum, id_name)
        fd.close()
        self.printcolor.printinfo("ID_Name to num mapping: %s" % (image_idname_D))
        return image_idname_D

    def get_blfimageable_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        image_able_D = {}
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Enable_pattern in line:
                # 1_Image_Enable = 1
                imagenum = int(line.split("_")[0].strip())
                able = line.split("=")[1].strip()
                image_able_D.setdefault(imagenum, able)
        fd.close()
        return image_able_D

    def get_blfimagetimincluded_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        tim_num_D = {}
        fd = open(blf, "r")
        for line in fd.readlines():
            #1_Image_Tim_Included = 1
            if self.Image_Tim_Included_partten in line:
                imagenum = int(line.split("_")[0].strip())
                tim_included = line.split("=")[1].strip()
                tim_num_D.setdefault(imagenum, tim_included)
        fd.close()
        return tim_num_D

    """get disable/enable images num list"""
    def get_disable_enable_imagenum_L(self, num_or_id):
        try:
            #如果是整数
            num = int(num_or_id)
            num_L = [num]
        except ValueError:
            #image的idname可能对应多个num值
            num_L = []
            for num,idname in self.blfimageidname_D.iteritems():
                #都转换为大写
                if idname == num_or_id.upper():
                    num_L.append(num)
        return num_L

    def modify_destblffile(self, destblffile=""):
        #修改目的路径下的blf文件
        destblffile = self.destblffile if destblffile =="" else destblffile
        fd = open(destblffile, "r")
        lines_L = fd.readlines()
        lines_L_len = len(lines_L)
        fd.close()

        if self.disableimage_L:
            """If you disable this item,other items that have same value in Tim column will be disabled automatically
            Since they have same Tim include property and they should have same status to ensure after burning flash successfully."""
            newblfname = "%s_disable" % self.blf

            #先整理一下需要disabled的image对应的num，得到一个list
            disableimagenum_L = []
            for num_or_id in self.disableimage_L:
                #获取所有的disable的num是一个list
                num_L = self.get_disable_enable_imagenum_L(num_or_id)
                disableimagenum_L.extend(num_L)
            #去重
            disableimagenum_L = list(set(disableimagenum_L))
            #处理tim之后的num的list
            disableimagenum_tim_L = []
            for num in disableimagenum_L:
                #获取tim include的数，大于0的需要处理一下
                timincluded = self.blfimagetimincluded_D.get(num, -1)
                if timincluded == 0:
                    disableimagenum_tim_L.apppend(num)
                elif timincluded > 0:
                    for (numkey, timvalue) in self.blfimagetimincluded_D.items():
                        if timvalue == timincluded:
                            disableimagenum_tim_L.append(numkey)
            #再次把新的的处理过tim的list去重
            disableimagenum_L = list(set(disableimagenum_tim_L))

            for i in range(0, lines_L_len):
                #遍历所有需要disabled的image对应的num的list
                for num in disableimagenum_L:
                    pattern = "%s_%s" % (num, self.Image_Enable_pattern)
                    if pattern == lines_L[i].split("=")[0].strip():
                        lines_L[i] = "%s = %s\r\n" % (pattern, 0)
                        #remove blfimagename in the blf name.IOError 36, File name too long.
                        newblfname = "%s_%s" % (newblfname, num)
                        self.printcolor.printinfo("will disable image: [%2s]%s" % (num, self.blfimagenum_D[num]))
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(disable images):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.enableimage_L:
            newblfname = "%s_enable" % self.blf

            #先整理一下需要enabled的image对应的num，得到一个list
            enableimagenum_L = []
            for num_or_id in self.enableimage_L:
                #获取所有的enable的num是一个list
                num_L = self.get_disable_enable_imagenum_L(num_or_id)
                enableimagenum_L.extend(num_L)
            #去重
            enableimagenum_L = list(set(enableimagenum_L))
            #处理tim之后的num的list
            enableimagenum_tim_L = []
            for num in enableimagenum_L:
                #获取tim include的数，大于0的需要处理一下
                timincluded = self.blfimagetimincluded_D.get(num, -1)
                if timincluded == 0:
                    enableimagenum_tim_L.apppend(num)
                elif timincluded > 0:
                    for (numkey, timvalue) in self.blfimagetimincluded_D.items():
                        if timvalue == timincluded:
                            enableimagenum_tim_L.append(numkey)
            #再次把新的的处理过tim的list去重
            enableimagenum_L = list(set(enableimagenum_tim_L))

            for i in range(0, lines_L_len):
                #遍历所有需要disabled的image对应的num的list
                for num in enableimagenum_L:
                    pattern = "%s_%s" % (num, self.Image_Enable_pattern)
                    if pattern == lines_L[i].split("=")[0].strip():
                        lines_L[i] = "%s = %s\r\n" % (pattern, 1)
                        #remove blfimagename in the blf name.IOError 36, File name too long.
                        newblfname = "%s_%s" % (newblfname, num)
                        self.printcolor.printinfo("will enable image: [%2s]%s" % (num, self.blfimagenum_D[num]))
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(enable images):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.eraseflash:
            newblfname = "%s_erase_all_flash" % self.blf
            for i in range(0, lines_L_len):
                pattern = "%s" % (self.Erase_All_Flash)
                if pattern in lines_L[i].split("=")[0].strip():
                    lines_L[i] = "%s = %s\r\n" % (pattern, 1)
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(Erase All Flash):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.onlyeraseflash:
            newblfname = "%s_only_erase_all_flash" % self.blf
            for i in range(0, lines_L_len):
                pattern = "%s" % (self.Erase_All_Flash)
                if pattern == lines_L[i].split("=")[0].strip():
                    lines_L[i] = "%s = %s\r\n" % (pattern, 2)
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(Only Erase All Flash):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.resetafterburning:
            newblfname = "%s_reset_after_burning" % self.blf
            for i in range(0, lines_L_len):
                pattern = "%s" % (self.UE_Boot_Option)
                if pattern == lines_L[i].split("=")[0].strip():
                    lines_L[i] = "%s = %s\r\n" % (pattern, 1)
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(ResetUE After Burning):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        return 0

    def set_disableimage(self, d):
        #分割字符串，获得image num
        d_L = d.split(",")
        disableimage_L = []
        for index, item in enumerate(d_L):
            try:
                disableimage_L.append(item)
            except ValueError as e:
                pass
        self.disableimage_L =disableimage_L

    def set_enableimage(self, d):
        #分割字符串，获得image num
        d_L = d.split(",")
        enableimage_L = []
        for index, item in enumerate(d_L):
            try:
                enableimage_L.append(item)
            except ValueError as e:
                pass
        self.enableimage_L = enableimage_L

    def set_mountpath(self, mountpath):
        self.mountpath = mountpath

    def set_destpath(self, destpath):
        self.destpath = destpath

    def set_onlycopy(self, onlycopy):
        self.onlycopy=onlycopy

    def set_onlyburn(self, onlyburn):
        self.onlyburn=onlyburn

    def set_copyforce(self, f):
        self.copyforce = f

    def set_listimage(self, listimage):
        self.listimage = listimage

    def set_eraseflash(self, eraseornot):
        self.eraseflash = eraseornot

    def set_onlyeraseflash(self, onlyeraseornot):
        self.onlyeraseflash = onlyeraseornot

    def set_resetafterburning(self, reset):
        self.resetafterburning = reset

    def set_printlistmax(self, m):
        self.printlistmax = m

    """print log or not"""
    def set_quiet(self, quiet):
        self.quiet = quiet
        self.printcolor.set_quiet(quiet)

    def set_jobsnum(self, j):
        self.jobsnum = j
#end class MountDailyBurn()

#local build burn class
class LocalBurn():
    def __init__(self, local, blf, destpath="", onlyburn=False, onlycopy=False):
        #os的类型，Linux还是windows
        self.systemtype = platform.system()

        #是否打印输出log
        self.quiet = False

        #blf文件名
        self.blf=blf

        #local path,where source image are
        self.local=local

        self.copyforce = False

        #print all image name if set this option
        self.listimage = False

        #默认是当前路径
        self.destpath=destpath
        self.onlyburn=onlyburn
        self.onlycopy=onlycopy

        #是否擦写
        self.eraseflash = False
        #是否只是擦写
        self.onlyeraseflash = False
        #是否烧写后自动重启
        self.resetafterburning = False

        #swdl.zip name
        self.swdlzipname = "Software_Downloader.zip"
        #softwaredownloader name
        if self.systemtype == "Linux":
            self.swdlname = "swdl_linux"
        elif self.systemtype == "Windows":
            self.swdlname = "SWDownloader.exe"
        else:
            self.swdlname = ""

        self.Image_Enable_pattern = "Image_Enable"
        self.Image_ID_Name_pattern = "Image_ID_Name"
        self.Image_Tim_Included_partten = "Image_Tim_Included"
        self.Image_Path_pattern = "Image_Path"
        self.Erase_All_Flash = "Erase_All_Flash"
        self.UE_Boot_Option = "UE_Boot_Option"

        self.findfile = FindFile()
        self.printcolor = PrintColor()

        #blf 里的image name
        self.blfimagename_L = []

        #不烧写的image
        self.disableimage_L = []
        #只烧写的image
        self.enableimage_L = []

        #image enable or disable num -->0/1 enable/disable
        self.blfimageable_D = {}

        #blf 里的image num --> name
        self.blfimagenum_D = {}

        #blf 里的image id name --> num 映射
        self.blfimageidname_D = {}

        #blf 里的image num --> tim included,这个TIM不知道干啥的
        self.blfimagetimincluded_D = {}

        #local目录下的image path
        self.localimagefile_L = []

        self.is_parent = False

        #local路径下的blf路径/绝对路径
        self.localblfpath = "" #只有路径
        self.localblffile= "" #路径+blf文件名

        #目的路径下的blf路径/绝对路径
        self.destblfpath = "" #只有路径
        self.destblffile= "" #路径+blf文件名

        #local路径下的swdl路径/绝对路径
        self.localswdlpath = "" #只有路径
        self.localswdlfile= "" #路径+swdl文件名

        #目的路径下的swdl路径/绝对路径
        self.destswdlpath = "" #只有路径.烧image时要切入这个目录中
        self.destswdlfile = ""

        #local路径下的swdl.zip路径/绝对路径
        self.localswdlzippath = "" #只有路径
        self.localswdlzipfile= "" #路径+swdlzip文件名

        #目的路径下的swdl.zip路径/绝对路径
        self.destswdlzippath = "" #只有路径
        self.destswdlzipfile = "" #路径+swdlzip文件名

        self.swdldriver = SwdlDriver()

        self.printlistmax = 20

        #线程池的个数
        self.jobsnum = 0
    def start(self):
        if self.listimage:
            #print all image name in blf.
            self.list_allimagename()
            return 0
        if self.onlycopy and self.onlyburn:
            self.printcolor.printerror('onlycopy or onlyburn?')
            return 1
        elif self.onlycopy:
            self.printcolor.printinfo('start only copy images...')
            self.only_copy_images()
            return 0
        elif self.onlyburn:
            self.printcolor.printinfo('start only burn images...')
            self.only_burn_images()
            return 0
        else:
            self.printcolor.printinfo('other...copy images then burn')
            if self._prepare_copy_images() != 0:
                return 1
            self._start_copy_images()

            if self._prepare_copy_swdl() != 0:
                return 1

            self._start_copy_swdl()

            self._start_burn_images()
            return 0

    def only_burn_images(self, local="", blf=""):
        local = self.local if local == "" else local
        blf = self.blf if blf == "" else blf

        if self._prepare_burn_images(local,blf) != 0:
            return 1

        self._start_burn_images()

        return 0

    """主要针对一个out目录下的images"""
    def only_copy_images(self, local="", blf=""):
        local = self.local if local == "" else local
        blf = self.blf if blf == "" else blf

        if self._prepare_copy_images(local, blf) != 0:
            return 1

        #(4)copy images
        self._start_copy_images()
        #copy done


    '''burn images, linux use swdl_linux, windows use .exe'''
    def _start_burn_images(self):
        if not self.swdldriver.checkdriver():
            self.printcolor.printerror("Not install driver")
            if self.swdldriver.installdriver() != 0:
                self.printcolor.printerror("Install driver fail")
                return 1
            self.printcolor.printinfo("Get driver and install driver successfully")
        if self.systemtype == "Linux":
            os.chmod(self.destswdlfile, stat.S_IRWXU + stat.S_IRWXG + stat.S_IRWXO)
            destswdlabspath = os.path.abspath(self.destswdlpath)
            os.chdir(self.destswdlpath)
            command = "sudo ./%s -D %s -S" % (self.swdlname, self.destblffile)
            ret = os.system(command)
            self.printcolor.printinfo("blffile: [%s]" % (self.destblffile))
            self.printcolor.printinfo("swdlpath:[%s]" % (destswdlabspath))
            self.printcolor.printinfo("command: [cd %s && %s]" % (destswdlabspath, command))
        elif self.systemtype == "Windows":
            destswdlabspath = os.path.abspath(self.destswdlpath)
            os.chdir(self.destswdlpath)
            command = "%s %s" % (self.swdlname, self.destblffile)
            ret = os.system(command)
            self.printcolor.printinfo("blffile: [%s]" % (self.destblffile))
            self.printcolor.printinfo("swdlpath:[%s]" % (destswdlabspath))
            self.printcolor.printinfo("command: [cd %s && %s]" % (destswdlabspath, command))
        return 0

    '''before burn image，we should check if there is blf，swdl and images are in correct position'''
    def _prepare_burn_images(self, local="", blf=""):
        local = self.local if local == "" else local
        blf = self.blf if blf == "" else blf

        if self._prepare_copy_swdl() != 0:
            return 1

        #4.到此 在local下是找到swdl了。
        #4.找blf的位置
        if  self.find_local_blf(local, blf) != 0:
            #没找到这个blf文件时，尝试通配搜索其他的blf文件
            self.printcolor.printwarning("try to search other *.blf file")
            if self.find_local_blf(local, "*.blf", "*.blf") != 0:
                #没blf文件我怎么知道你需要copy哪些image啊？！
                return 1

        #判断image是是否在正确的位置上
        if self.check_images(self.localblffile):
            #可以直接烧了
            self.destswdlfile = self.localswdlfile
            self.destswdlpath = self.localswdlpath

            #转换成绝对路径
            self.destblffile  = os.path.abspath(self.localblffile)
            self.destblfpath  = self.localblfpath

            #修改blf文件，如果定义了disableimage/enableimage
            self.modify_destblffile()

            return 0
        else:
            #不正确的话复制到destpath目录里或者tmp目录下
            if self._prepare_copy_images(local, blf) != 0:
                return 1
            self._start_copy_images()

            #image复制好了 destpath也肯定设置好了
            self._start_copy_swdl()
            #copy swdl to destpath
        return 0

    def _prepare_copy_swdl(self, local="", blf=""):
        local = self.local if local == "" else local
        blf = self.blf if blf == "" else blf
        swdl_L = self.findfile.localfile(local, self.swdlname)
        swdl_L_len = len(swdl_L)
        #1先找swdl位置、没找到的话找swdl.zip的位置
        if not swdl_L:
            #(1).not found swdl, then find swdlzip/
            self.printcolor.printwarning("not found %s, then will try to find %s" % (self.swdlname, self.swdlzipname))
            swdlzip_L = self.findfile.localfile(local, self.swdlzipname)
            swdlzip_L_len = len(swdlzip_L)
            if not swdlzip_L:
                #(1.1) swdl.zip 也没找到的话估计是没法烧image了
                self.printcolor.printwarning("not found %s" % self.swdlzipname)
                return 1
            elif swdlzip_L_len > 1:
                #(1.2)找到了多个swdl.zip文件
                self.printcolor.printinfo("found more %s ,which do you want? [%s - %s] or exit?" % (self.swdlzipname, 0, swdlzip_L_len - 1))
                if swdlzip_L_len > self.printlistmax:
                    for i in range(0, self.printlistmax):
                        print "[%s]" % i, swdlzip_L[i]
                    return 1
                for i in range(0, swdlzip_L_len):
                    print "[%s]" % i, swdlzip_L[i]
                choice = raw_input("please input [%s - %s] " %(0, swdlzip_L_len - 1))
                try:
                    index = int(choice)
                except ValueError as e:
                    self.printcolor.printwarning("exit")
                    sys.exit(1)
                if index > swdlzip_L_len -1 or index < 0:
                    self.printcolor.printerror("[%s]out of index" % index)
                    sys.exit(1)
                self.localswdlzipfile = swdlzip_L[index]
                self.localswdlzippath = os.path.dirname(self.localswdlzipfile)
            else:
                #(1.3)只找到一个zip，这个就好办了
                self.printcolor.printinfo("not found %s, but found 1 %s" % (self.swdlname, self.swdlzipname))
                self.localswdlzipfile = swdlzip_L[0]
                self.localswdlzippath = os.path.dirname(self.localswdlzipfile)
            #到此是没找到swdl bin 文件 而是 找到swdl.zip 文件了，

            #把目的路径创建出来
            if self.destpath == "":
                #为空就获得一个临时目录作为destpath,create a temp dir
                self.destpath = tempfile.mkdtemp()
            if not os.path.exists(self.destpath):
                os.mkdir(self.destpath)

            #unzip swdl.zip to this folder
            self.findfile.unzip(self.localswdlzipfile, self.destpath)

            #在destpath目录下找swdl.self.destswdlpath,self.destswdlfile 都在此函数中设置了
            if self.find_dest_swdl(self.destpath) != 0:
                return 1
            #到此destswdlpath，destswdlfile都有了，localswdlfile和localswdlpath和它是一样的
            self.localswdlfile = self.destswdlfile
            self.localswdlpath = self.destswdlpath

            #可以直接返回了
            return 0
        #2.找到多个swdl文件，一般情况应该不会找到多个吧
        elif swdl_L_len > 1:
            self.printcolor.printinfo("found more %s ,which do you want? [%s - %s] or exit?" % (self.swdlname, 0, swdl_L_len - 1))
            if swdl_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%s]" % i, swdl_L[i]
                self.printcolor.printwarning("so many %s! I cann't list all, just list top %s" % (self.swdlname, self.printlistmax))
                return 1
            for i in range(0, swdl_L_len):
                print "[%s]" % i, swdl_L[i]
            choice = raw_input("please input [%s - %s] " %(0, swdl_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printinfo("exit")
                sys.exit(1)
            if index > swdl_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)

            self.localswdlfile= swdl_L[index] #路径+swdl文件名
            self.localswdlpath = os.path.dirname(self.localswdlfile) #只有路径

            self.printcolor.printinfo("your choice: %s" % self.localswdlfile)
            #把目的路径创建出来
            if self.destpath == "":
                #为空就获得一个临时目录作为destpath,create a temp dir
                self.destpath = tempfile.mkdtemp()
            if not os.path.exists(self.destpath):
                os.mkdir(self.destpath)
            #这个就是之后放swdl的目录
            self.destswdlpath = self.destpath

        #找到一个,这有可能就是上次烧过image的目录，之后判断blf文件，image的位置时候正确
        else:
            self.printcolor.printinfo("only found 1 %s" % self.swdlname)

            self.localswdlfile= swdl_L[0] #路径+swdl文件名
            self.localswdlpath = os.path.dirname(self.localswdlfile) #只有路径
            #把目的路径创建出来
            if self.destpath == "":
                #为空就获得一个临时目录作为destpath,create a temp dir
                self.destpath = tempfile.mkdtemp()
            if not os.path.exists(self.destpath):
                os.mkdir(self.destpath)
            #这个就是之后放swdl的目录
            self.destswdlpath = self.destpath
        return 0

    def _start_copy_swdl(self):
        self.destswdlfile = os.path.abspath(os.path.join(self.destswdlpath, self.swdlname))
        if os.path.exists(self.destswdlfile):
            #swdl存在
            if self.is_difffile(self.destswdlfile, self.localswdlfile):
                if self.copyforce:
                    shutil.copy(self.destswdlfile, self.destswdlpath)
                else:
                    self.printcolor.printwarning("%s exist, if you want force copy use --force")
            else:
                self.printcolor.printwarning("%s is same, no need to copy" % self.swdlname)
        else:
            #不存在
            shutil.copy(self.localswdlfile, self.destswdlpath)

    """check local image on correct position"""
    def check_images(self, blf=""):
        blffile = self.localblffile if blf == "" else blf
        blfpath = os.path.dirname(blffile)
        blfparentpath = os.path.normpath(os.path.join(blfpath, ".."))

        self.blfimagename_L = self.get_blfimagename_L(blffile)
        self.blfimageable_D = self.get_blfimageable_D(blffile)
        self.blfimagenum_D = self.get_blfimagenum_D(blffile)
        self.blfimagetimincluded_D = self.get_blfimagetimincluded_D(blffile)

        notexists_imagename_L = []
        #是否image要在blf的父目录
        if self.set_is_parent(blf):
            #是父目录
            for imagename in self.blfimagename_L:
                if not os.path.exists(os.path.join(blfparentpath, imagename)):
                    notexists_imagename_L.append(imagename)
        else:
            #不是父目录
            for imagename in self.blfimagename_L:
                if not os.path.exists(os.path.join(blfpath, imagename)):
                    notexists_imagename_L.append(imagename)

        if notexists_imagename_L:
            for imagename in notexists_imagename_L:
                self.printcolor.printwarning("miss [%s]" % imagename)
            return False
        return True

    def _prepare_copy_images(self, local="", blf=""):
        local = self.local if local == "" else local
        blf = self.blf if blf == "" else blf

        #1.(1)先精确的查找blf在local下的位置
        if not os.path.exists(self.localblffile):
            if self.find_local_blf(local, blf, None) != 0:
                #(2)没找到这个blf文件时，尝试通配搜索其他的blf文件
                self.printcolor.printwarning("try to search other *.blf file")
                if self.find_local_blf(local, "*.blf", "*.blf") != 0:
                    #没blf文件我怎么知道你需要copy哪些image啊？！
                    return 1

        #2.然后根据blf找image文件了.有了blf文件才好知道需要哪些image
        self.blfimagename_L = self.get_blfimagename_L() #这个有可能有重名的image
        self.blfimageable_D = self.get_blfimageable_D()
        self.blfimagenum_D = self.get_blfimagenum_D()
        self.blfimageidname_D = self.get_blfimageidname_D()
        self.blfimagetimincluded_D = self.get_blfimagetimincluded_D()
        self.localimagefile_L = self.get_localimagefile_L()

        #3.destpath没设置，直接返回
        if self.destpath == "":
            #直接return呢还是给一次机会呢？是创建一个，还是让用户输入呢？为空就获得一个临时目录,create a temp dir
            self.printcolor.printwarning("destpath not defined. Use --dest-path to set dest path")
            self.destpath = tempfile.mkdtemp()
            self.printcolor.printinfo("will create a temp folder: %s" % self.destpath)

        #4.destpath设置了，判断存在不设置的对不对，不能是个文件吧？！
        if not os.path.exists(self.destpath):
            os.mkdir(self.destpath)

        if os.path.isdir(self.destpath):
            #这个就是之后放swdl的目录
            self.destswdlpath = self.destpath
            #(1)然后创建在里面创建个 blf的目录用来存放blf文件
            self.destblfpath = os.path.join(self.destswdlpath, "blf")
            if not os.path.exists(self.destblfpath):
                try:
                    os.mkdir(self.destblfpath)
                except OSError as e:
                    self.printcolor.printerror("%s" % e)
                    return 1

            #(2)blf转换为绝对路径
            self.destblffile = os.path.abspath(os.path.join(self.destblfpath, self.blf))
            if os.path.exists(self.destblffile):
                #存在
                if self.is_difffile(self.localblffile, self.destblffile):
                    #不一样的文件
                    if self.copyforce:
                        #强制覆盖
                        shutil.copy(self.localblffile, self.destblfpath)
                    else:
                        self.printcolor.printwarning("%s exists, if you want force copy use --force" % self.destblffile)
                else:
                    self.printcolor.printwarning("%s is same, no need to copy" % self.blf)
            else:
                #不存在
                self.printcolor.printinfo("copy blf. %s --> %s" % (self.localblffile, self.destblfpath))
                shutil.copy(self.localblffile, self.destblfpath)

            #(3)修改blf文件
            self.modify_destblffile(self.destblffile)

            #(4)判断image存放的位置，是父目录还是同级目录
            self.set_is_parent(self.destblffile)

        else:
            self.printcolor.printwarning("%s is a file not a dir, use --dest-path" % self.destpath)
            return 1

        return 0

    def _start_copy_images(self):
        if self.jobsnum > 0:
            #use mutil thread
            threadpool = ThreadPool(self.jobsnum)
            if self.is_parent:
                parentpath = os.path.dirname(self.destblfpath)
                for local_image in self.localimagefile_L:
                    threadpool.queueTask(self._copy, (local_image, parentpath), None)
            else:
                for local_image in self.localimagefile_L:
                    threadpool.queueTask(self._copy, (local_image, self.destblfpath), None)
            threadpool.joinAll()
        else:
            #not use mutil thread
            if self.is_parent:
                parentpath = os.path.dirname(self.destblfpath)
                for local_image in self.localimagefile_L:
                    self._copy((local_image, parentpath))
            else:
                for local_image in self.localimagefile_L:
                    self._copy((local_image, self.destblfpath))

    def _copy(self, data):
        srcfile = data[0]#源文件路径+名字
        srcfilename = os.path.basename(srcfile)

        destpath = data[1]#目的路径、或者路径+名字
        destfile = os.path.join(destpath, srcfilename)

        if os.path.exists(destfile):
            if self.is_difffile(srcfile, destfile):
                if self.copyforce:
                    self.printcolor.printinfo("copy %s --> %s" % (srcfile, destpath))
                    shutil.copy(srcfile, destpath)
                else:
                    self.printcolor.printwarning("%s exists, if you want force copy use --force options" % destfile)
            else:
                self.printcolor.printwarning("%s, %s same, no need to copy" % (srcfile, destfile))
        else:
            self.printcolor.printinfo("copy %s --> %s" % (srcfile, destpath))
            shutil.copy(srcfile, destpath)

    def is_samefile(self, f1, f2):
        return filecmp.cmp(f1,f2)

    def is_difffile(self, f1, f2):
        return not self.is_samefile(f1,f2)

    def find_dest_swdl(self, dest="", swdlname=""):
        dest = self.destswdlpath if dest == "" else dest
        swdlname = self.swdlname if swdlname == "" else swdlname
        #精确查找
        destswdl_L = self.findfile.localfile(dest, swdlname, None)
        destswdl_L_len = len(destswdl_L)
        if not destswdl_L:
            #不可能吧？没找到
            self.printcolor.printwaring("not found %s" % swdlname)
            return 1
        elif destswdl_L_len > 1:
            #不可能吧？找到多个
            self.printcolor.printinfo("found more %s ,which do you want? [%s - %s] or exit?" % (swdlname, 0, destswdl_L_len - 1))
            if destswdl_L_len > self.printlistmax:
                for i in range(0, destswdl_L_len):
                    print "[%s]" % i, destswdl_L[i]
                self.printcolor.printwarning("so many %s! I cann't list all, just list top %s" % (swdlname, self.printlistmax))
                return 1
            for i in range(0, destswdl_L_len):
                print "[%s]" % i, destswdl_L[i]
            choice = raw_input("please input [0 - %s] " % (destswdl_L_len -1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printinfo("exit")
                sys.exit(1)
            if index > destswdl_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)

            self.destswdlfile = destswdl_L[index]#路径+文件名
            self.destswdlpath = os.path.dirname(self.destswdlfile)#只有路径
        else:
            #只找到一个
            self.destswdlfile = destswdl_L[0]#路径+文件名
            self.destswdlpath = os.path.dirname(self.destswdlfile)#只有路径
        return 0

    """精确的查找blf，通配搜索"""
    def find_local_blf(self, local="", blf="", pattern=None):
        local = self.local if local == "" else local
        blf = self.blf if blf == "" else blf

        #local path 里的blf
        blf_L = self.findfile.localfile(local, blf, pattern)
        blf_L_len = len(blf_L)
        if not blf_L:
            #没用在local路径里找到blf文件，直接return
            self.printcolor.printwarning("not found this blf: %s" % blf)
            return 1
        elif blf_L_len > 1:
            #找到多个blf文件
            self.printcolor.printinfo("found more blf[%s] file,which do you want? [%s - %s] or exit?" % (blf,0, blf_L_len-1))
            if blf_L_len > self.printlistmax:
                for i in range(0, self.printlistmax):
                    print "[%s]" % i,blf_L[i]
                self.printcolor.printwarning("so many blf files! I cann't list all, just list top %s" % self.printlistmax)
                return 2
            for i in range(0, blf_L_len):
                print "[%s]" % i,blf_L[i]
            choice = raw_input("please input [0 - %s] " % (blf_L_len - 1))
            try:
                index = int(choice)
            except ValueError as e:
                self.printcolor.printinfo("exit")
                sys.exit(1)
            if index > blf_L_len - 1 or index < 0:
                self.printcolor.printerror("[%s]out of index" % index)
                sys.exit(1)
            self.localblffile = blf_L[index]#路径+blf
            #通配搜索的情况下需要重设blf名字
            self.blf = os.path.basename(self.localblffile)
            self.localblfpath = os.path.dirname(self.localblffile) #只有路径
        else:
            #找到了一个blf文件
            self.localblffile = blf_L[0]#路径+blf

            #通配搜索的情况下需要重设blf名字
            searchblf = os.path.basename(self.localblffile)
            if searchblf != self.blf:
                print "[0]", blf_L[0]
                choice = raw_input("This blf you want? please input [0] " )
                try:
                    index = int(choice)
                except ValueError as e:
                    self.printcolor.printinfo("exit")
                    sys.exit(1)
                if index != 0:
                    self.printcolor.printwarning("exit")
                    sys.exit(1)
                self.blf = searchblf
                self.printcolor.printinfo("your choice: %s" % self.blf)

            self.localblfpath = os.path.dirname(self.localblffile) #只有路径
        return 0

    """判断 image存放的位置，是和blf文件在同一目录还是其父目录
        需要一个blf文件的全路径"""
    def set_is_parent(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Path_pattern and ("../" in line or "..\\" in line):
                self.is_parent=True
                return True
        self.is_parent=False
        return False

    '''获取通过local，和blf 获取image的路径'''
    def get_localimagefile_L(self, local="", blf=""):
        blf = self.localblffile if blf == "" else blf
        local = self.local if local=="" else local
        local_image_L = []
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Path_pattern in line:
                image = line.split("=")[1]
                imagename = []
                if "../" in image:
                    imagename = image.split("../")
                elif '..\\' in image:
                    imagename = image.split("..\\")
                else:
                    imagename = image.split(" ")
                imagename = imagename[-1].strip()
                local_image_L.extend(self.findfile.localfile(local, imagename))
        fd.close()
        return local_image_L

    '''通过blf文件获得image的名字'''
    def get_blfimagename_L(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        local_image_L = []

        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Path_pattern in line:
                image = line.split("=")[1]
                imagename = []
                if "../" in image:
                    imagename = image.split("../")
                elif '..\\' in image:
                    imagename = image.split("..\\")
                else:
                    imagename = image.split(" ")
                imagename = imagename[-1].strip()
                local_image_L.append(imagename)
        fd.close()

        return local_image_L

    def list_allimagename(self, local="", blf=""):
        local = self.local if local == "" else local
        blf = self.blf if blf == "" else blf
        #1.(1)先精确的查找blf在local下的位置
        if not os.path.exists(self.localblffile):
            if self.find_local_blf(local, blf, None) != 0:
                #(2)没找到这个blf文件时，尝试通配搜索其他的blf文件
                self.printcolor.printwarning("try to search other *.blf file")
                if self.find_local_blf(local, "*.blf", "*.blf") != 0:
                    #(3)没blf文件我怎么知道烧写image啊
                    return 1

        self.blfimagenum_D = self.get_blfimagenum_D()
        self.blfimageidname_D = self.get_blfimageidname_D()
        self.blfimageable_D = self.get_blfimageable_D()
        self.blfimagetimincluded_D = self.get_blfimagetimincluded_D()

        num_L = self.blfimagenum_D.keys()
        num_L.sort()
        self.printcolor.printinfo("list all image [ID:?] [Enable:?] [Tim_Include:?] [ImgID:?] = name in blf: %s" % (self.blf))
        for num in num_L:
            print "[ID: %2s] [Enable: %s] [Tim_Include: %s] [ImgID: %s] = %s" \
            % (num, self.blfimageable_D[num],self.blfimagetimincluded_D[num], self.blfimageidname_D[num], self.blfimagenum_D[num])
        self.printcolor.printinfo("list all image [ID:?] [Enable:?] [Tim_Include:?] [ImgID:?] = name in blf: %s" % (self.blf))

    def get_blfimagenum_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        image_num_D = {}
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Path_pattern in line:
                # 11_Image_Path = cache.img
                imagenum = int(line.split("_")[0].strip())

                image = line.split("=")[1]
                imagename = []
                if "../" in image:
                    imagename = image.split("../")
                elif '..\\' in image:
                    imagename = image.split("..\\")
                else:
                    imagename = image.split(" ")
                imagename = imagename[-1].strip()

                image_num_D.setdefault(imagenum, imagename)
        fd.close()
        return image_num_D

    def get_blfimageidname_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        image_idname_D = {}
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_ID_Name_pattern in line:
                # 25_Image_ID_Name = CACH
                imagenum = int(line.split("_")[0].strip())
                id_name = line.split("=")[1].strip()
                image_idname_D.setdefault(imagenum, id_name)
        fd.close()
        self.printcolor.printinfo("ID_Name to num mapping: %s" % (image_idname_D))
        return image_idname_D

    def get_blfimageable_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        image_able_D = {}
        fd = open(blf, "r")
        for line in fd.readlines():
            if self.Image_Enable_pattern in line:
                # 1_Image_Enable = 1
                imagenum = int(line.split("_")[0].strip())
                able = line.split("=")[1].strip()
                image_able_D.setdefault(imagenum, able)
        fd.close()
        return image_able_D

    def get_blfimagetimincluded_D(self, blf=""):
        blf = self.localblffile if blf == "" else blf
        tim_num_D = {}
        fd = open(blf, "r")
        for line in fd.readlines():
            #1_Image_Tim_Included = 1
            if self.Image_Tim_Included_partten in line:
                imagenum = int(line.split("_")[0].strip())
                tim_included = line.split("=")[1].strip()
                tim_num_D.setdefault(imagenum, tim_included)
        fd.close()
        return tim_num_D

    def get_disable_enable_imagenum_L(self, num_or_id):
        try:
            #如果是整数
            num = int(num_or_id)
            num_L = [num]
        except ValueError:
            #image的idname可能对应多个num值
            num_L = []
            for num,idname in self.blfimageidname_D.iteritems():
                #都转换为大写
                if idname == num_or_id.upper():
                    num_L.append(num)
        return num_L

    def modify_destblffile(self, destblffile=""):
        #修改目的路径下的blf文件
        destblffile = self.destblffile if destblffile =="" else destblffile
        fd = open(destblffile, "r")
        lines_L = fd.readlines()
        lines_L_len = len(lines_L)
        fd.close()

        if self.disableimage_L:
            newblfname = "%s_disable" % self.blf

            #先整理一下需要disabled的image对应的num，得到一个list
            disableimagenum_L = []
            for num_or_id in self.disableimage_L:
                #获取所有的disable的num是一个list
                num_L = self.get_disable_enable_imagenum_L(num_or_id)
                disableimagenum_L.extend(num_L)
            #去重
            disableimagenum_L = list(set(disableimagenum_L))
            #处理tim之后的num的list
            disableimagenum_tim_L = []
            for num in disableimagenum_L:
                #获取tim include的数，大于0的需要处理一下
                timincluded = self.blfimagetimincluded_D.get(num, -1)
                if timincluded == 0:
                    disableimagenum_tim_L.apppend(num)
                elif timincluded > 0:
                    for (numkey, timvalue) in self.blfimagetimincluded_D.items():
                        if timvalue == timincluded:
                            disableimagenum_tim_L.append(numkey)
            #再次把新的的处理过tim的list去重
            disableimagenum_L = list(set(disableimagenum_tim_L))

            for i in range(0, lines_L_len):
                #遍历所有需要disabled的image对应的num的list
                for num in disableimagenum_L:
                    pattern = "%s_%s" % (num, self.Image_Enable_pattern)
                    if pattern == lines_L[i].split("=")[0].strip():
                        lines_L[i] = "%s = %s\r\n" % (pattern, 0)
                        #remove blfimagename in the blf name.IOError 36, File name too long.
                        newblfname = "%s_%s" % (newblfname, num)
                        self.printcolor.printinfo("will disable image: [%2s]%s" % (num, self.blfimagenum_D[num]))
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(disable images):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.enableimage_L:
            newblfname = "%s_enable" % self.blf

            #先整理一下需要enabled的image对应的num，得到一个list
            enableimagenum_L = []
            for num_or_id in self.enableimage_L:
                #获取所有的enable的num是一个list
                num_L = self.get_disable_enable_imagenum_L(num_or_id)
                enableimagenum_L.extend(num_L)
            #去重
            enableimagenum_L = list(set(enableimagenum_L))
            #处理tim之后的num的list
            enableimagenum_tim_L = []
            for num in enableimagenum_L:
                #获取tim include的数，大于0的需要处理一下
                timincluded = self.blfimagetimincluded_D.get(num, -1)
                if timincluded == 0:
                    enableimagenum_tim_L.apppend(num)
                elif timincluded > 0:
                    for (numkey, timvalue) in self.blfimagetimincluded_D.items():
                        if timvalue == timincluded:
                            enableimagenum_tim_L.append(numkey)
            #再次把新的的处理过tim的list去重
            enableimagenum_L = list(set(enableimagenum_tim_L))

            for i in range(0, lines_L_len):
                #遍历所有需要disabled的image对应的num的list
                for num in enableimagenum_L:
                    pattern = "%s_%s" % (num, self.Image_Enable_pattern)
                    if pattern == lines_L[i].split("=")[0].strip():
                        lines_L[i] = "%s = %s\r\n" % (pattern, 1)
                        #remove blfimagename in the blf name.IOError 36, File name too long.
                        newblfname = "%s_%s" % (newblfname, num)
                        self.printcolor.printinfo("will enable image: [%2s]%s" % (num, self.blfimagenum_D[num]))
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(enable images):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.eraseflash:
            newblfname = "%s_erase_all_flash" % self.blf
            for i in range(0, lines_L_len):
                pattern = "%s" % (self.Erase_All_Flash)
                if pattern in lines_L[i].split("=")[0].strip():
                    lines_L[i] = "%s = %s\r\n" % (pattern, 1)
                    self.printcolor.printinfo("Erase All Flash.")
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(Erase All Flash):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.onlyeraseflash:
            newblfname = "%s_only_erase_all_flash" % self.blf
            for i in range(0, lines_L_len):
                pattern = "%s" % (self.Erase_All_Flash)
                if pattern == lines_L[i].split("=")[0].strip():
                    lines_L[i] = "%s = %s\r\n" % (pattern, 2)
                    self.printcolor.printinfo("Only Erase All Flash.")
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(Only Erase All Flash):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        if self.resetafterburning:
            newblfname = "%s_reset_after_burning" % self.blf
            for i in range(0, lines_L_len):
                pattern = "%s" % (self.UE_Boot_Option)
                if pattern == lines_L[i].split("=")[0].strip():
                    lines_L[i] = "%s = %s\r\n" % (pattern, 1)
                    self.printcolor.printinfo("ResetUE After Burning.")
            newblfname = "%s.blf" % (newblfname)
            newblffile = os.path.join(self.destblfpath, newblfname)

            self.printcolor.printinfo("will write to new blf file(ResetUE After Burning):\n %s" % (newblffile))
            fd = open(newblffile, "w")
            fd.writelines(lines_L)
            fd.close()

            self.blf = newblfname
            self.destblffile = os.path.abspath(newblffile)

        return 0

    def set_disableimage(self, d):
        #分割字符串，获得image num
        d_L = d.split(",")
        disableimage_L = []
        for index, item in enumerate(d_L):
            try:
                disableimage_L.append(item)
            except ValueError as e:
                pass
        self.disableimage_L = disableimage_L

    def set_enableimage(self, d):
        #分割字符串，获得image num
        d_L = d.split(",")
        enableimage_L = []
        for index, item in enumerate(d_L):
            try:
                enableimage_L.append(item)
            except ValueError as e:
                pass
        self.enableimage_L = enableimage_L

    def set_destpath(self, path):
        self.destpath=path

    def set_onlycopy(self, onlycopy):
        self.onlycopy=onlycopy

    def set_onlyburn(self, onlyburn):
        self.onlyburn=onlyburn

    def set_copyforce(self, f):
        self.copyforce = f

    def set_listimage(self, l):
        self.listimage = l

    def set_eraseflash(self, eraseornot):
        self.eraseflash = eraseornot

    def set_onlyeraseflash(self, onlyeraseornot):
        self.onlyeraseflash = onlyeraseornot

    def set_resetafterburning(self, reset):
        self.resetafterburning = reset

    """set print list max num"""
    def set_printlistmax(self, m):
        self.printlistmax = m

    """print log or not"""
    def set_quiet(self, quiet):
        self.quiet = quiet
        self.printcolor.set_quiet(quiet)

    """set the threadpool max num"""
    def set_jobsnum(self, num):
        self.jobsnum = num
#end class LocalBurn()

class FindFile():
    def __init__(self, path="", filename="" ):
        #os的类型，Linux还是windows
        self.systemtype = platform.system()

        self.path = path
        self.filename=filename

        self.smbdomain = "MARVEL"

        self.host = "10.38.116.40"
        self.username = "pat"
        self.password = "powerpat"

    def set_path(path):
        self.path=path

    def set_filename(filename):
        self.filename=filename

    def set_smbdomain(domain):
        self.smbdomain=domain

    def set_host(self, host):
        self.host = host

    def set_username(self, username):
        self.username = username

    def set_password(self, password):
        self.password = password

    def __do_auth(self, server, security, workgroup, username, password):
        #//10.38.116.40/autobuild /autobuild cifs dom=MARVEL,username=pat,password=powerpat   0   2
        return (self.smbdomain, self.username, self.password)

    """find the local file"""
    def localfile(self, path = "", filename = "", pattern = None):
        path = self.path if path == "" else path
        filename = self.filename if filename == "" else filename
        filepath_L = []
        if pattern is None:
            for root, dirs, files in os.walk(path):
                for f in files:
                    if f == filename:
                        filepath_L.append(os.path.join(root, f))
        else:
            for root, dirs, files in os.walk(path):
                for f in files:
                    if fnmatch.fnmatch(f, pattern):
                        filepath_L.append(os.path.join(root, f))
        return filepath_L

    """find smb file"""
    def smbfile(self, path = "", filename = "", pattern = None):
        #这个是带smb://的path
        smbpath = self.path if path == "" else path
        #这个是正常的path
        path = self.path if path == "" else path

        filename = self.filename if filename == "" else filename

        filesmbpath_L = []

        #如果是windows系统就不能用samba这种方式了
        if self.systemtype == "Windows":
            path = self.path if smbpath == "" else smbpath

            #window下路径要加上host，这是为了统一
            path = "\\\\%s\\%s" % (self.host, path)
            filename = self.filename if filename == "" else filename
            filepath_L = []
            if pattern is None:
                for root, dirs, files in os.walk(path):
                    #window下要把host去掉，这是为了统一
                    root = root.replace("\\\\%s\\" % (self.host), "")
                    for f in files:
                        if f == filename:
                            filepath_L.append(os.path.join(root, f))
            else:
                for root, dirs, files in os.walk(path):
                    #window下要把host去掉，这是为了统一
                    root = root.replace("\\\\%s\\" % (self.host), "")
                    for f in files:
                        if fnmatch.fnmatch(f, pattern):
                            filepath_L.append(os.path.join(root, f))
            return filepath_L
        else:
            #try to import smbc,貌似ubutnu默认安装这个了
            try:
                import smbc
            except ImportError as e:
                print e
                return filesmbpath_L

        #smbpath做一些特殊的处理和判断，path就不用
        if smbpath[0:5] == "smb://":
            pass
        else:
            if smbpath[0] == "/":
                smbpath = "smb://%s%s" % (self.host, smbpath)
            else:
                smbpath = "smb://%s/%s" % (self.host, smbpath)

        filesmbpath_L = []
        ctx = smbc.Context(debug=0, auth_fn=self.__do_auth)
        try:
            #这里只能打开smbpath
            fd = ctx.opendir(smbpath)
        except smbc.NoEntryError as e:
            print e,smbpath
        except smbc.TimedOutError as e:
            print e,smbpath
        else:
            entries = fd.getdents()
            for entry in entries:
                if path[-1] == "/":
                    #这里只要path，都统一一下
                    smbfilepath = path + entry.name
                else:
                    smbfilepath = path + "/" + entry.name
                # smbc_type == 7 this is a dir
                if entry.smbc_type == 7 and entry.name != "." and entry.name != "..":
                    filesmbpath_L.extend(self.smbfile(smbfilepath, filename, pattern))
                # smbc_type == 8 this is a file
                elif entry.smbc_type == 8:
                    #pattern is None就需要精确匹配
                    if pattern is None:
                        if entry.name == filename:
                            filesmbpath_L.append(smbfilepath)
                    else:
                        if fnmatch.fnmatch(entry.name, pattern):
                            filesmbpath_L.append(smbfilepath)

        return filesmbpath_L

    """download file from samba server"""
    def download(self, smbfile, destfile):
        #如果是windows系统就不能用samba这种方式了
        if self.systemtype == "Windows":
            smbfile = "\\\\%s\\%s" % (self.host, smbfile)
            shutil.copy(smbfile, destfile)
            return 0
        else:
            #try to import smbc,貌似ubutnu默认安装这个了
            try:
                import smbc
            except ImportError as e:
                print e
                return False
        if smbfile[0:5] == "smb://":
            pass
        else:
            if smbfile[0] == "/":
                smbfile = "smb://%s%s" % (self.host, smbfile)
            else:
                smbfile = "smb://%s/%s" % (self.host, smbfile)

        ctx = smbc.Context(auth_fn=self.__do_auth)
        try:
            fd_smb = ctx.open(smbfile)
        except smbc.NoEntryError as e:
            return 1
        except smbc.TimedOutError as e:
            return 1
        else:
            fd_local = open(destfile , "w")
            fd_local.write(fd_smb.read())
            fd_local.close()
        return 0

    def smbisdir(self, smbpath):
        smbpath = self.path if smbpath == "" else smbpath

        #如果是windows系统就不能用samba这种方式了
        if self.systemtype == "Windows":
            smbpath = "\\\\%s\\%s" % (self.host, smbpath)
            return os.path.isdir(smbpath)
        else:
            #try to import smbc,貌似ubutnu默认安装这个了
            try:
                import smbc
            except ImportError as e:
                print e
                return False
        if smbpath[0:5] == "smb://":
            pass
        else:
            if smbpath[0] == "/":
                smbpath = "smb://%s%s" % (self.host, smbpath)
            else:
                smbpath = "smb://%s/%s" % (self.host, smbpath)

        ctx = smbc.Context(debug=0, auth_fn=self.__do_auth)
        try:
            fd = ctx.open(smbpath)
        except smbc.NoEntryError as e:
            return False
        except RuntimeError as e:
            #(21, 'Is a directory')
            if e[0] == 21:
                return True
            else:
                return False
        except ValueError as e:
            #很奇怪为什么会报这个错误？？
            return False
        else:
            fd.close()
            return False

    def smbisfile(self, path):
        smbpath = self.path if path == None else path

        #如果是windows系统就不能用samba这种方式了
        if self.systemtype == "Windows":
            smbpath = "\\\\%s\\%s" % (self.host, smbpath)
            return os.path.isfile(smbpath)
        else:
            #try to import smbc,貌似ubutnu默认安装这个了
            try:
                import smbc
            except ImportError as e:
                print e
                return False
        if smbpath[0:5] == "smb://":
            pass
        else:
            if smbpath[0] == "/":
                smbpath = "smb://%s%s" % (self.host, smbpath)
            else:
                smbpath = "smb://%s/%s" % (self.host, smbpath)

        ctx = smbc.Context(debug=0, auth_fn=self.__do_auth)
        try:
            fd = ctx.open(smbpath)
        except smbc.NoEntryError as e:
            #(2, 'No such file or directory')
            return False
        except RuntimeError as e:
            #(21, 'Is a directory')
            return False
        except ValueError as e:
            #很奇怪为什么会报这个错误？？
            return False
        else:
            fd.close()
            return True

    """判断文件或者目录是否存在"""
    def smbexists(self, path):
        smbpath = self.path if path == None else path

        #如果是windows系统就不能用samba这种方式了
        if self.systemtype == "Windows":
            smbpath = "\\\\%s\\%s" % (self.host, smbpath)
            return os.path.exists(smbpath)
        else:
            #try to import smbc,貌似ubutnu默认安装这个了
            try:
                import smbc
            except ImportError as e:
                print e
                return False
        if smbpath[0:5] == "smb://":
            pass
        else:
            if smbpath != "" and smbpath[0] == "/":
                smbpath = "smb://%s%s" % (self.host, smbpath)
            else:
                smbpath = "smb://%s/%s" % (self.host, smbpath)

        ctx = smbc.Context(debug=0, auth_fn=self.__do_auth)
        try:
            fd = ctx.open(smbpath)
        except smbc.NoEntryError as e:
            #(2, 'No such file or directory')
            return False
        except RuntimeError as e:
            #(21, 'Is a directory')
            if e[0] == 21:
                return True
            else:
                return False
        except ValueError as e:
            #很奇怪为什么会报这个错误？？
            return False
        else:
            fd.close()
            return True

    """给定一个samba路径(像这样的：/autobuild/android/)，列出所有的文件，文件夹，出去.和.."""
    def smblistdir(self, path):
        smbpath = self.path if path == None else path

        #只包含文件夹的名字，不带路径
        filesmbpath_L = []

        #如果是windows系统就不能用samba这种方式了
        if self.systemtype == "Windows":
            smbpath = "\\\\%s\\%s" % (self.host, smbpath)
            return os.listdir(smbpath)
        else:
            #try to import smbc,貌似ubutnu默认安装这个了
            try:
                import smbc
            except ImportError as e:
                print e
                return False
        if smbpath[0:5] == "smb://":
            pass
        else:
            if smbpath[0] == "/":
                smbpath = "smb://%s%s" % (self.host, smbpath)
            else:
                smbpath = "smb://%s/%s" % (self.host, smbpath)


        ctx = smbc.Context(debug=0, auth_fn=self.__do_auth)
        try:
            fd = ctx.opendir(smbpath)
        except smbc.NoEntryError as e:
            return filesmbpath_L
        except RuntimeError as e:
            return filesmbpath_L
        else:
            entries = fd.getdents()
            for entry in entries:
                #暂时不过滤目录smbc_type == 7 ，舍去.和..目录
                if entry.name != "." and entry.name != "..":
                    filesmbpath_L.append(entry.name)

        return filesmbpath_L


    """
    读取一个文件，一般会是blf文件。
    可以是smb服务器上的,这样只能用read()，然后需要split()获取一个行内容的list
    如果是本地的文件，就直接readlines(),然后直接获得了一个行内容的list
    """
    def get_smbfile_lines_L(self, smbpath):
        if self.systemtype == "Windows":
            smbpath = "\\\\%s\\%s" % (self.host, smbpath)
            fd = open(smbpath, "r")
            lines_L = fd.readlines()
            fd.close()
            return lines_L
        else:
            #try to import smbc,貌似ubutnu默认安装这个了
            try:
                import smbc
            except ImportError as e:
                print e
                return False
        if smbpath[0:5] == "smb://":
            pass
        else:
            if smbpath[0] == "/":
                smbpath = "smb://%s%s" % (self.host, smbpath)
            else:
                smbpath = "smb://%s/%s" % (self.host, smbpath)

        ctx = smbc.Context(debug=0, auth_fn=self.__do_auth)
        try:
            fd = ctx.open(smbpath)
        except smbc.NoEntryError as e:
            #(2, 'No such file or directory')
            return []
        except RuntimeError as e:
            #(21, 'Is a directory')
            return []
        except ValueError as e:
            #很奇怪为什么会报这个错误？？
            return []
        else:
            #读取文件，并分割
            lines_L = fd.read().split("\n")
            fd.close()
            return lines_L

    """unzip zip file to dest folder"""
    def unzip(self, zpfile, destDir):
        zfile = zipfile.ZipFile(zpfile)
        for name in zfile.namelist():
            (dirName, fileName) = os.path.split(name)
            #check if the directory exists
            newDir = os.path.join(destDir, dirName)
            if not os.path.exists(newDir):
                os.mkdir(newDir)
            if not fileName == '':
                #file
                fd = open(os.path.join(destDir, name), 'wb')
                fd.write(zfile.read(name))
                fd.flush()
                fd.close()
        zfile.close()
#end class FindFile()

class SwdlDriver():
    def __init__(self):
        self.systemtype = platform.system()
        self.host = "10.38.32.174"
        self.username = "anonymous"
        self.password = ""
        #ftp://10.38.32.174/share/wtptp_driver.zip

        self.wtptpdriverzipname = "wtptp_driver.zip"
        self.wtptpdriverzippath = "/share"
        self.wtptpdriverzipfile = os.path.join(self.wtptpdriverzippath, self.wtptpdriverzipname)

        self.findfile = FindFile()

        self.localwtptpdriverzipfile = ""
        self.localwtptpdriverzippath = ""


    def get_ftp_driver_zip(self, ftpfile = ""):
        ftpfile = self.wtptpdriverzipfile if ftpfile == "" else ftpfile
        if self.systemtype == "Linux":
            tmppath = tempfile.mkdtemp()
            tmpfile = os.path.join(tmppath, self.wtptpdriverzipname)

            localfile = open(tmpfile, "wb")
            ftp = ftplib.FTP(self.host, self.username, self.password, timeout=30)
            ftp.retrbinary("RETR %s" % ftpfile, localfile.write)
            ftp.quit()
            localfile.close()

            self.localwtptpdriverzipfile = tmpfile
            self.localwtptpdriverzippath = tmppath

            return 0
        elif self.systemtype == "Windows":
            return 0
        else:
            return 0

    def make_wtptp_driver(self):
        #判断存在
        if os.path.exists(self.localwtptpdriverzipfile):
            #解压zip文件
            self.findfile.unzip(self.localwtptpdriverzipfile, self.localwtptpdriverzippath)
            makefile_L = self.findfile.localfile(self.localwtptpdriverzippath, "Makefile")

            if not makefile_L:
                return 1
            else :
                makefilefile = makefile_L[0]
                makefilepath = os.path.dirname(makefile_L[0])

                oldcwd = os.getcwd()

                os.chdir(makefilepath)
                ret = os.system("make")
                if ret == 0:
                    self.installdriver("./wtptp.ko")

                os.chdir(oldcwd)
            return 0
        else:
            return 1

    def installdriver(self, driverko = ""):
        if self.systemtype == "Linux":
            if self.checkdriver():
                return 0
            else:
                if driverko:
                    ret = os.system("sudo insmod %s" % driverko)
                else:
                    #先下载zip文件
                    if self.get_ftp_driver_zip() != 0:
                        return 1
                    ret = self.make_wtptp_driver()

                return ret
        elif self.systemtype == "Windows":
            return 0
        else:
            return 1

    def reinstalldriver(self, driverko = ""):
        if self.systemtype == "Linux":
            if self.checkdriver():
                self.uninstalldriver()
            if driverko:
                ret = os.system("sudo insmod %s" % driverko)
            else:
                #先下载zip文件
                if self.get_ftp_driver_zip() != 0:
                    return 1
                ret = self.make_wtptp_driver()
            return ret
        elif self.systemtype == "Windows":
            return 0
        else:
            return 1

    def uninstalldriver(self, driverko="wtptp"):
        if self.systemtype == "Linux":
            ret = os.system("sudo rmmod %s" % driverko)
        elif self.systemtype == "Windows":
            pass
        else:
            pass

    def checkdriver(self, driverko="wtptp"):
        if self.systemtype == "Linux":
            ret = os.system("lsmod|grep '%s' 1>/dev/null 2>/dev/null" % driverko)
            return True if ret == 0 else False
        elif self.systemtype == "Windows":
            return os.path.exists("C:\\Windows\\System32\\drivers\\WTPTP.sys")
        else:
            return False
#end class SwdlDriver()

class PrintColor():
    def __init__(self, level="", color="", quiet=False):
        self.quiet = quiet
        self.level = level
        self.color = color
        self.systemtype = platform.system()
        if self.systemtype == "Windows":
            self.STD_INPUT_HANDLE = -10
            self.STD_OUTPUT_HANDLE= -11
            self.STD_ERROR_HANDLE = -12

            self.FOREGROUND_BLACK  = 0x0
            self.FOREGROUND_BLUE   = 0x01 # text color contains blue
            self.FOREGROUND_GREEN  = 0x02 # text color contains green
            self.FOREGROUND_CYAN   = 0x03 # text color contains cyan
            self.FOREGROUND_RED    = 0x04 # text color contains red
            self.FOREGROUND_PINK   = 0x05 # text color contains pink
            self.FOREGROUND_YELLOW = 0x06 # text color contains yellow
            self.FOREGROUND_WHITE  = 0x07 # text color contains red
            self.FOREGROUND_GRAY   = 0x08 # text color contains red

            self.FOREGROUND_HBLUE   = 0x09 # text color contains highlight blue
            self.FOREGROUND_HGREEN  = 0x0a # text color contains highlight green
            self.FOREGROUND_CYAN    = 0x0b # text color contains cyan
            self.FOREGROUND_HRED    = 0x0c # text color contains highlight red
            self.FOREGROUND_HPINK   = 0x0d # text color contains highlight pink
            self.FOREGROUND_HYELLOW = 0x0e # text color contains highlight yellow
            self.FOREGROUND_HWHITE  = 0x0f # text color contains highlight white
            self.std_out_handle = ctypes.windll.kernel32.GetStdHandle(self.STD_OUTPUT_HANDLE)
        elif self.systemtype == "Linux":
            self.FOREGROUND_BLACK   = 30 # black
            self.FOREGROUND_HBLUE   = 34 # text color contains highlight blue
            self.FOREGROUND_HGREEN  = 32 # text color contains highlight green
            self.FOREGROUND_CYAN    = 36 # text color contains cyan
            self.FOREGROUND_HRED    = 31 # text color contains highlight red
            self.FOREGROUND_HPINK   = 35 # text color contains highlight pink
            self.FOREGROUND_HYELLOW = 33 # text color contains highlight yellow
            self.FOREGROUND_HWHITE  = 37 # text color contains highlight white
        else:
            self.FOREGROUND_BLACK   = 0
            self.FOREGROUND_HBLUE   = 0
            self.FOREGROUND_HGREEN  = 0
            self.FOREGROUND_CYAN    = 0
            self.FOREGROUND_HRED    = 0
            self.FOREGROUND_HPINK   = 0
            self.FOREGROUND_HYELLOW = 0
            self.FOREGROUND_HWHITE  = 0
    def set_color(self, color):
        if self.systemtype == "Linux":
            sys.stdout.write("\033[1;%sm" % (color))
        elif self.systemtype == "Windows":
            ctypes.windll.kernel32.SetConsoleTextAttribute(self.std_out_handle, color)
        else:
            return
    def reset_color(self):
        if self.systemtype == "Linux":
            sys.stdout.write("\033[0m")
        elif self.systemtype == "Windows":
            self.set_color(self.FOREGROUND_RED | self.FOREGROUND_GREEN | self.FOREGROUND_BLUE)
        else:
            return

    def printblue(self, print_text):
        self.set_color(self.FOREGROUND_HBLUE)
        sys.stdout.write(print_text)
        self.reset_color()
    def printgreen(self, print_text):
        self.set_color(self.FOREGROUND_HGREEN)
        sys.stdout.write(print_text)
        self.reset_color()
    def printred(self, print_text):
        self.set_color(self.FOREGROUND_HRED)
        sys.stdout.write(print_text)
        self.reset_color()
    def printyellow(self, print_text):
        self.set_color(self.FOREGROUND_HYELLOW)
        sys.stdout.write(print_text)
        self.reset_color()
    def printwhite(self, print_text):
        self.set_color(self.FOREGROUND_HYELLOW)
        sys.stdout.write(print_text)
        self.reset_color()

    def printcolor(self, msg, level="", color=""):
        if self.quiet:
            return

        level = self.level if level=="" else level
        color = self.color if color=="" else color
        if color == "green":
            self.printgreen(level)
            print msg
        elif color == "red":
            self.printred(level)
            print msg
        elif color == "blue":
            self.printblur(level)
            print msg
        elif color == "yellow":
            self.printyellow(level)
            print msg
        elif color == "white":
            self.printwhite(level)
            print msg
        else:
            print "%s%s" %(level, msg)

    def printinfo(self, msg):
        if self.quiet:
            return
        self.printgreen("[   info]")
        print msg
    def printwarning(self, msg):
        if self.quiet:
            return
        self.printyellow("[warning]")
        print msg
    def printerror(self, msg):
        if self.quiet:
            return
        self.printred("[  error]")
        print msg

    def set_quiet(self, q):
        self.quiet = q
#end class PrintColor()

class ThreadPool:

    """Flexible thread pool class.  Creates a pool of threads, then
    accepts tasks that will be dispatched to the next available
    thread."""

    def __init__(self, numThreads):

        """Initialize the thread pool with numThreads workers."""

        self.__threads = []
        self.__resizeLock = threading.Condition(threading.Lock())
        self.__taskLock = threading.Condition(threading.Lock())
        self.__tasks = []
        self.__isJoining = False
        self.setThreadCount(numThreads)

    def setThreadCount(self, newNumThreads):

        """ External method to set the current pool size.  Acquires
        the resizing lock, then calls the internal version to do real
        work."""

        # Can't change the thread count if we're shutting down the pool!
        if self.__isJoining:
            return False

        self.__resizeLock.acquire()
        try:
            self.__setThreadCountNolock(newNumThreads)
        finally:
            self.__resizeLock.release()
        return True

    def __setThreadCountNolock(self, newNumThreads):

        """Set the current pool size, spawning or terminating threads
        if necessary.  Internal use only; assumes the resizing lock is
        held."""

        # If we need to grow the pool, do so
        while newNumThreads > len(self.__threads):
            newThread = ThreadPoolThread(self)
            self.__threads.append(newThread)
            newThread.start()
        # If we need to shrink the pool, do so
        while newNumThreads < len(self.__threads):
            self.__threads[0].goAway()
            del self.__threads[0]

    def getThreadCount(self):

        """Return the number of threads in the pool."""

        self.__resizeLock.acquire()
        try:
            return len(self.__threads)
        finally:
            self.__resizeLock.release()

    def queueTask(self, task, args=None, taskCallback=None):

        """Insert a task into the queue.  task must be callable;
        args and taskCallback can be None."""

        if self.__isJoining == True:
            return False
        if not callable(task):
            return False

        self.__taskLock.acquire()
        try:
            self.__tasks.append((task, args, taskCallback))
            return True
        finally:
            self.__taskLock.release()

    def getNextTask(self):

        """ Retrieve the next task from the task queue.  For use
        only by ThreadPoolThread objects contained in the pool."""

        self.__taskLock.acquire()
        try:
            if self.__tasks == []:
                return (None, None, None)
            else:
                return self.__tasks.pop(0)
        finally:
            self.__taskLock.release()

    def joinAll(self, waitForTasks = True, waitForThreads = True):

        """ Clear the task queue and terminate all pooled threads,
        optionally allowing the tasks and threads to finish."""

        # Mark the pool as joining to prevent any more task queueing
        self.__isJoining = True

        # Wait for tasks to finish
        if waitForTasks:
            while self.__tasks != []:
                time.sleep(.1)

        # Tell all the threads to quit
        self.__resizeLock.acquire()
        try:
            # Wait until all threads have exited
            if waitForThreads:
                for t in self.__threads:
                    t.goAway()
                for t in self.__threads:
                    t.join()
                    del t

            self.__setThreadCountNolock(0)
            self.__isJoining = True

            # Reset the pool for potential reuse
            self.__isJoining = False
        finally:
            self.__resizeLock.release()

class ThreadPoolThread(threading.Thread):

    """ Pooled thread class. """

    threadSleepTime = 0.1

    def __init__(self, pool):

        """ Initialize the thread and remember the pool. """

        threading.Thread.__init__(self)
        self.__pool = pool
        self.__isDying = False

    def run(self):

        """ Until told to quit, retrieve the next task and execute
        it, calling the callback if any.  """

        while self.__isDying == False:
            cmd, args, callback = self.__pool.getNextTask()
            # If there's nothing to do, just sleep a bit
            if cmd is None:
                time.sleep(ThreadPoolThread.threadSleepTime)
            elif callback is None:
                cmd(args)
            else:
                callback(cmd(args))

    def goAway(self):

        """ Exit the run loop next time through."""

        self.__isDying = True
#end class ThreadPoolThread(threading.Thread)

def parseargs():
    example = """

simple use:
    python %prog -b HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_1GB.blf -p pxa1L88dkb_def -d 2014-10-15_pxa988-kk4.4

    python %prog -m
    python %prog -m -d 2014-11-06
    python %prog -m -d 2014-11-06 -b HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_1GB.blf
    python %prog -m -d 2014-10-15 -b HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_1GB.blf -p pxa1L88dkb_def
    python %prog -m -d 2014-10-15_pxa988-kk4.4 -b HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_1GB.blf -p pxa1L88dkb_def
    python %prog -m -d 2014-10-15_pxa988-kk4.4 -b HELN_LTE_CSFB_Nontrusted_eMMC_533MHZ_1GB.blf -p pxa1L88dkb_def --mount-path /home/mamh/autobuild

    python %prog --local /home/mamh/myimagepath -b blffilename
    python %prog --local /home/mamh/myimagepath -b blffilename -S SYSY,USRY

mount command:
    sudo mount.cifs //10.38.116.40/autobuild/ /autobuild -o user=pat,pass=powerpat,domain=MARVEL
or
    sudo mount -t cifs //10.38.116.40/autobuild/ /autobuild -o user=pat,pass=powerpat,domain=MARVEL
    """
    usage = "%prog [options] args" + example

    parser = optparse.OptionParser(usage)

    parser.add_option("-d", "--image-date",dest="imagedate",
            help="image date folder name", default="")
    parser.add_option("-p", "--product",dest="product",
            help="product", default="")
    parser.add_option("-b", "--blf",dest="blf",
            help="blf file name", default="")

    parser.add_option("-D",   "--dest-path",  dest="destpath",
            help="the path where you want to save images", default="")

    parser.add_option("", "--only-copy",   dest="onlycopy",
            help="enable this optons, it will not burn image", default=False, action="store_true")
    parser.add_option("", "--only-burn",   dest="onlyburn",
            help="enable this optons, it will only burn image", default=False, action="store_true")

    burnoptiongroup=optparse.OptionGroup(parser,"About burn options")
    burnoptiongroup.add_option("-S", "--disable-image",   dest="disableimage",
            help="disable some images not to burn. Can be a comma seperated list of ID_Names or index", default="")
    burnoptiongroup.add_option("-N", "--enable-image",   dest="enableimage",
            help="enable some images not to burn. Can be a comma seperated list of ID_Names or index", default="")
    burnoptiongroup.add_option("-E", "--erase-flash",   dest="eraseflash",
            help="erase all flash images", default=False, action="store_true")
    burnoptiongroup.add_option("-e", "--only-erase-flash",   dest="onlyeraseflash",
            help="only erase all flash images", default=False, action="store_true")
    burnoptiongroup.add_option("-R", "--reset-after-burning",   dest="resetafterburning",
            help="resetUE after burning", default=False, action="store_true")
    parser.add_option_group(burnoptiongroup)

    parser.add_option("-L", "--list-image",   dest="listimage",
            help="print all images name in blf file", default=False, action="store_true")

    parser.add_option("-q", "--quiet",   dest="quiet",
            help="will not print log", default=False, action="store_true")

    parser.add_option("-f", "--force",   dest="force",
            help="force copy file", default=False, action="store_true")

    parser.add_option("-j",   "--jobs",   dest="jobsnum",
            help="set max threadpoool num", default=0)
    parser.add_option("",   "--max",   dest="printlistmax",
            help="set max print list num", default="")

    parser.add_option("",   "--swdl-zip",   dest="swdlzip",
            help="set SoftwareDownloader.zip name", default="")
    parser.add_option("",   "--swdl",   dest="swdl",
            help="set swdl app name", default="")

    swdldrivergroup=optparse.OptionGroup(parser,"About SoftwareDownloader Driver options")
    swdldrivergroup.add_option("", "--check-driver",   dest="checkdriver",
            help="check driver", default=False, action="store_true")
    swdldrivergroup.add_option("", "--install-driver",   dest="installdriver",
            help="install SWDownloader driver", default=False, action="store_true")
    swdldrivergroup.add_option("", "--reinstall-driver",   dest="reinstalldriver",
            help="reinstall SWDownloader driver", default=False, action="store_true")
    swdldrivergroup.add_option("", "--uninstall-driver", dest="uninstalldriver",
            help="install SWDownloader driver", default=False, action="store_true")
    parser.add_option_group(swdldrivergroup)

    mountgroup=optparse.OptionGroup(parser, "Mount options")
    mountgroup.add_option("-m", "--mount",      dest="mount",
            help="use mount", default=False, action="store_true")
    mountgroup.add_option("",   "--mount-path", dest="mountpath",
            help="autobuild mount point ", default="")
    parser.add_option_group(mountgroup)

    localburnoptiongroup=optparse.OptionGroup(parser,"Local images burn options")
    localburnoptiongroup.add_option("-l",   "--local",  dest="local",
            help="the path where your source images", default="")
    parser.add_option_group(localburnoptiongroup)

    servergroup=optparse.OptionGroup(parser, "samba/ftp/http server options")
    servergroup.add_option("",   "--host",   dest="host",
            help="", default="")
    servergroup.add_option("",   "--username",   dest="username",
            help="", default="")
    servergroup.add_option("",   "--password",   dest="password",
            help="", default="")
    parser.add_option_group(servergroup)

    (options, args) = parser.parse_args()

    return (options, args)

def main():
    (options, args) = parseargs()
    #检查驱动
    checkdriver = options.checkdriver
    #安装驱动
    reinstalldriver = options.reinstalldriver
    #安装驱动
    installdriver = options.installdriver
    #卸载驱动，一般不会用到吧
    uninstalldriver = options.uninstalldriver

    #包含日期的 image folder名
    #2014-10-27_pxa1908-kk4.4_k314_alpha1
    imagedate = options.imagedate

    #product名，也是folder的名字
    product = options.product

    #blf文件名字
    blf = options.blf

    #local模式用到的一个路径
    local = options.local
    #目的路径，用来存放复制过来的images
    destpath = options.destpath

    #mount模式
    mount = options.mount
    #挂载点
    mountpath = options.mountpath

    #只复制image
    onlycopy = options.onlycopy
    #直接烧image
    onlyburn = options.onlyburn

    #安静模式，不输出print的信息
    quiet = options.quiet
    #当模糊搜索到多个时，列出最多个数给用户
    printlistmax=options.printlistmax
    #多线程，0的时候禁用多线程，>0 线程池的最大个数
    jobsnum = options.jobsnum
    force = options.force

    #不烧写哪些image： 数字，用逗号分开
    disableimage = options.disableimage
    #只烧写哪些image
    enableimage = options.enableimage
    #是否擦写
    eraseflash = options.eraseflash
    #只擦写不烧写
    onlyeraseflash = options.onlyeraseflash
    #烧写后是否重启
    resetafterburning = options.resetafterburning
    #print image name list
    listimage = options.listimage

    #host/ip
    host = options.host
    #username 账户名
    username = options.username
    #password 密码
    password = options.password

    swdldriver = SwdlDriver()
    #检查驱动是否有
    if checkdriver:
        if swdldriver.checkdriver():
            print "install driver"
        else:
            print "not install driver"
        return 0
    #reinstall-driver选项装驱动
    if reinstalldriver:
        swdldriver.reinstalldriver()
        return 0
    #install-driver选项装驱动
    if installdriver:
        swdldriver.installdriver()
        return 0
    #uninstall-driver 卸载驱动用处不大吧
    if uninstalldriver:
        swdldriver.uninstalldriver()
        return 0

    #local模式
    #指定一个local的路径，一个blf文件名字
    if local:
        localburn = LocalBurn(local, blf)

        if quiet:
            localburn.set_quiet(True)
        if force:
            localburn.set_copyforce(True)

        if printlistmax:
            try:
                plmax = int(printlistmax)
            except ValueError as e:
                localburn.set_printlistmax(20)
            else:
                localburn.set_printlistmax(plmax)

        if jobsnum:
            try:
                jobsnum = int(jobsnum)
            except ValueError as e:
                localburn.set_jobsnum(10)
            else:
                if jobsnum < 0:
                    jobsnum = 0
                localburn.set_jobsnum(jobsnum)
        if destpath:
            localburn.set_destpath(destpath)

        if onlycopy:
            localburn.set_onlycopy(True)

        if onlyburn:
            localburn.set_onlyburn(True)

        if listimage:
            localburn.set_listimage(True)

        #这两个不能同时出现
        if disableimage and enableimage:
            pass
        elif disableimage:
            localburn.set_disableimage(disableimage)
        elif enableimage:
            localburn.set_enableimage(enableimage)

        if eraseflash and onlyeraseflash:
            pass
        elif eraseflash:
            localburn.set_eraseflash(True)
        elif onlyeraseflash:
            localburn.set_onlyeraseflash(True)

        if resetafterburning:
            localburn.set_resetafterburning(True)

        localburn.start()
        return 0

    #mount模式daily burn模式
    if mount:
        mountdailyburn = MountDailyBurn(imagedate, product, blf)
        if quiet:
            mountdailyburn.set_quiet(True)
        if force:
            mountdailyburn.set_copyforce(True)
        if printlistmax:
            try:
                plmax = int(printlistmax)
            except ValueError as e:
                mountdailyburn.set_printlistmax(20)
            else:
                mountdailyburn.set_printlistmax(plmax)
        if jobsnum:
            try:
                jobsnum = int(jobsnum)
            except ValueError as e:
                mountdailyburn.set_jobsnum(10)
            else:
                if jobsnum < 0:
                    jobsnum = 0
                mountdailyburn.set_jobsnum(jobsnum)
        if destpath:
            mountdailyburn.set_destpath(destpath)

        if onlycopy:
            mountdailyburn.set_onlycopy(True)

        if onlyburn:
            mountdailyburn.set_onlyburn(True)

        if mountpath:
            mountdailyburn.set_mountpath(mountpath)

        if listimage:
            mountdailyburn.set_listimage(True)

        #这两个不能同时出现
        if disableimage and enableimage:
            pass
        elif disableimage:
            mountdailyburn.set_disableimage(disableimage)
        elif enableimage:
            mountdailyburn.set_enableimage(enableimage)

        #擦写flash的选项，这两个也不能同时出现
        if eraseflash and onlyeraseflash:
            pass
        elif eraseflash:
            mountdailyburn.set_eraseflash(True)
        elif onlyeraseflash:
            mountdailyburn.set_onlyeraseflash(True)

        if resetafterburning:
            mountdailyburn.set_resetafterburning(True)

        mountdailyburn.start()
        return 0

    #不是mount模式，也不是local模式
    sambadailyburn = SambaDailyBurn(imagedate, product, blf)
    if quiet:
        sambadailyburn.set_quiet(True)
    if force:
        sambadailyburn.set_copyforce(True)
    if printlistmax:
        try:
            plmax = int(printlistmax)
        except ValueError as e:
            sambadailyburn.set_printlistmax(20)
        else:
            sambadailyburn.set_printlistmax(plmax)

    #设置多线程的个数
    if jobsnum:
        try:
            jobsnum = int(jobsnum)
        except ValueError as e:
            sambadailyburn.set_jobsnum(10)
        else:
            if jobsnum < 0:
                jobsnum = 0
            sambadailyburn.set_jobsnum(jobsnum)
    if destpath:
        sambadailyburn.set_destpath(destpath)

    if onlycopy:
        sambadailyburn.set_onlycopy(True)
    if onlyburn:
        sambadailyburn.set_onlyburn(True)

    if listimage:
        sambadailyburn.set_listimage(True)

    #这两个不能同时出现
    if disableimage and enableimage:
        pass
    elif disableimage:
        sambadailyburn.set_disableimage(disableimage)
    elif enableimage:
        sambadailyburn.set_enableimage(enableimage)

    #擦写flash的选项，这两个也不能同时出现
    if eraseflash and onlyeraseflash:
        pass
    elif eraseflash:
        sambadailyburn.set_eraseflash(True)
    elif onlyeraseflash:
        sambadailyburn.set_onlyeraseflash(True)

    if resetafterburning:
        sambadailyburn.set_resetafterburning(True)

    if host:
        sambadailyburn.set_host(host)
    if username:
        sambadailyburn.set_username(username)
    if password:
        sambadailyburn.set_password(password)

    sambadailyburn.start()

    return 0

if __name__ == '__main__':
    main()
