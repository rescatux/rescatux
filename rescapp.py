#!/usr/bin/env python
# Rescapp

import sys, subprocess, os, time, linecache, sip
from PyQt4 import QtGui,QtCore,QtWebKit
from functools import partial


class RescappOption():

    def __init__(self):
      self.code=""
      self.name=""
      self.description=""
      self.isOption=False
      self.hasOfflineDoc=False
      self.executable=False
      
    def isMenu(self):
      return (self.isOption == False)
    def isOption(self):
      return ((self.isMenu(self)) == False)
    def setCode(self,code):
      self.code=code
    def setName(self,name):
      self.name=name
    def setDescription(self,description):
      self.description=description
    def getCode(self):
      return self.code
    def getName(self):
      return self.name
    def getDescription(self):
      return self.description
    def setAsMenu(self):
      self.isOption = False
    def setAsOption(self):
      self.isOption = True
    def setHasOfflineDoc(self, mybool):
      self.hasOfflineDoc=mybool
    def getHasOfflineDoc(self):
      return self.hasOfflineDoc
    def setExecutable(self, mybool):
      self.executable=mybool
    def getExecutable(self):
      return self.executable
    def setFromDir(self, dir_to_check, ndir):
      global current_pwd
      global name_filename
      global description_filename
      global run_filename
      global offlinedoc_filename

      
      name_tmp = linecache.getline(current_pwd + '/' + ndir + '/' + name_filename,1)
      name_tmp = name_tmp.rstrip('\r\n');
      
      
      description_tmp = linecache.getline(current_pwd + '/' + ndir + '/' + description_filename,1)
      description_tmp = description_tmp.rstrip('\r\n');
      
      
      print 'DEBUG: Directory (code) found: ' + ndir
      code_list.append(ndir)
      self.setCode(ndir)
      print 'DEBUG: Name found: ' + name_tmp
      self.setName(name_tmp)
      name_list.append(name_tmp)
      print 'DEBUG: Description found: ' + description_tmp
      self.setDescription(description_tmp)
      description_list.append(description_tmp)
      
      if (os.path.isfile(current_pwd + '/' + ndir + '/' + run_filename)):
	self.setAsOption()
	self.setExecutable(True)
      if (os.path.isfile(current_pwd + '/' + ndir + '/' + offlinedoc_filename)):
	self.setAsOption()
	self.setHasOfflineDoc(True)


class MainWindow(QtGui.QWidget):	


    def selectOptionCommon (self, n_option):
	global current_pwd
      	global name_filename
	global description_filename
	global run_filename
	global offlinedoc_filename

	self.selected_option_code = n_option.getCode()
	if (n_option.getExecutable() == True):
	  self.rescue_btn.show()
	  self.rescue_btn.setText("Run: " +n_option.getName()+ "!")
	  self.rescue_btn.setToolTip(n_option.getDescription())
	else:
	  self.rescue_btn.hide()
	
	if (n_option.getHasOfflineDoc()):
	  self.wb.load(QtCore.QUrl('file:///' + current_pwd + '/' + n_option.getCode() + '/' + offlinedoc_filename))
    def selectOption(self, option_code):
	global option_list
	
	print "DEBUG: Selecting option (code): " + option_code
	for n_option in option_list:	    
	    if (n_option.getCode() == option_code):
	      self.selectOptionCommon(n_option)

    def selectSupportOption(self, support_RescappOption):
	print "DEBUG: Selecting Support option (code): " + support_RescappOption.getCode()
	self.selectOptionCommon(support_RescappOption)
	
	
	
    def runRescue(self):
	print "DEBUG: Running option (code) [BEGIN]: " + self.selected_option_code
	run_status = subprocess.call([current_pwd + "/" + "rescapp_launcher.sh",self.selected_option_code])
	print "DEBUG: Running option (code) [FINISH]: " + self.selected_option_code + " with code: " + str(run_status);

    def setLayout(self, layout):
	self.clearLayout()
	QtGui.QWidget.setLayout(self, layout)

    def clearLayout(self):
	if self.layout() is not None:
	    old_layout = self.layout()
	    for i in reversed(range(old_layout.count())):
		old_layout.itemAt(i).widget().setParent(None)
	    sip.delete(old_layout)

    def parserescappmenues(self, menu_base):
      
      global code_list
      global name_list
      global description_list
      global option_list
      global current_pwd
      
      global chat_support_option
      
      self.selected_option_code = ""
      
      code_list = list ()
      name_list = list ()
      description_list = list()
      option_list = list()
      
      f=open(current_pwd + '/' + menu_base)
      for mydir in f:
	ndir = mydir.rstrip('\r\n');
	dir_to_check = os.path.join(current_pwd, ndir)
	print dir_to_check
	if os.path.isdir(dir_to_check):
	  
	  new_option = RescappOption()
	  new_option.setFromDir(dir_to_check, ndir)
	  option_list.append(new_option)
	  
	  
	else:
	  print "DEBUG: Warning: " + dir_to_check + " was ignored because it was not a directory!"
      self.drawMainWindows()

    def drawMainWindows(self):
      
	global mainmenu_filename
	global maximum_option_columns
      
	rows_per_option = 1
	title_offset = 1
	options_offset = 0
	
        mainmenu_btn = QtGui.QPushButton('MAIN MENU', self)
	mainmenu_btn.clicked.connect(partial(self.parserescappmenues,mainmenu_filename))
	mainmenu_btn.setToolTip("Go back to the Main Menu")
	self.rescue_btn = QtGui.QPushButton('RESCUE!', self)
	self.rescue_btn.setToolTip("Run selected option!")
	self.rescue_btn.clicked.connect(self.runRescue)
	self.rescue_btn.hide()
	
	self.chat_btn = QtGui.QPushButton(chat_support_option.getName(), self)
	self.chat_btn.clicked.connect(partial(self.selectSupportOption,chat_support_option))
	self.chat_btn.setToolTip(chat_support_option.getDescription())
	self.share_log_btn = QtGui.QPushButton(share_log_support_option.getName(), self)
	self.share_log_btn.clicked.connect(partial(self.selectSupportOption,share_log_support_option))
	self.share_log_btn.setToolTip(share_log_support_option.getDescription())
	self.help_btn = QtGui.QPushButton(help_support_option.getName(), self)
	self.help_btn.clicked.connect(partial(self.selectSupportOption,help_support_option))
	self.help_btn.setToolTip(help_support_option.getDescription())

	self.wb=QtWebKit.QWebView()
	self.wb.load(url)
	
	name_button_list = list ()
	
	for n_option in option_list:
	  print "DEBUG: Option code: "+ n_option.getCode() +" was found"
	  tmp_name_button = QtGui.QPushButton(n_option.getName(), self)
	  tmp_name_button.setToolTip(n_option.getDescription())
	  name_button_list.append(tmp_name_button)

        grid = QtGui.QGridLayout()
        grid.setSpacing(10)
	

	grid.addWidget(mainmenu_btn,0,0,1,1)
	grid.addWidget(self.chat_btn,0,1,1,1)
	grid.addWidget(self.share_log_btn,0,2,1,1)
	grid.addWidget(self.help_btn,0,3,1,1)
	grid.addWidget(self.rescue_btn,title_offset,1,title_offset+rows_per_option-1,1)

	options_offset = 1 + title_offset
	  
	options_slot_list = list ()
	x_grid_position = 1
	current_n_name_button_n = 1
	
	name_pos_x = 1
	name_pos_y = 0

	for n_name_button_list in name_button_list:
	  
	  
	  for n_option in option_list:
	    if (n_option.getCode() == code_list[current_n_name_button_n - 1]):
	      if ((n_option.getExecutable() == True) or (n_option.getHasOfflineDoc() == True)):
		print "DEBUG: Option " + n_option.getCode() + " has offlinedoc and it is executable"
		options_slot_list.append(partial(self.selectOption,code_list[current_n_name_button_n - 1]))
		n_name_button_list.clicked.connect(options_slot_list[current_n_name_button_n - 1])
	      else:
		print "DEBUG: Option " + n_option.getCode() + " is a menu"
		options_slot_list.append(partial(self.parserescappmenues,code_list[current_n_name_button_n - 1] + '.lis'))
		n_name_button_list.clicked.connect(options_slot_list[current_n_name_button_n - 1])
		
	      grid.addWidget(n_name_button_list,options_offset+name_pos_x,name_pos_y,rows_per_option,1)
	      name_pos_y=name_pos_y + 1
	      if ((name_pos_y % maximum_option_columns) == 0):
		name_pos_x=name_pos_x + 1
		x_grid_position = x_grid_position + rows_per_option
		name_pos_y=0
	    
	      
	      
	  current_n_name_button_n = current_n_name_button_n + 1 
	  
	  
	bottom_start = options_offset + (name_pos_x * rows_per_option) + 8
	grid.addWidget(self.wb, bottom_start + 5, 0, 5, 5)
        
        
        
	self.setLayout(grid)
	self.setMaximumHeight(570)
    def __init__(self, url):
        QtGui.QMainWindow.__init__(self)
	self.parserescappmenues(mainmenu_filename)

        


if __name__ == "__main__":
  
  
    current_pwd="/home/user/Desktop/rescapp"
    mainmenu_filename = 'rescatux.lis'
    code_list = list ()
    name_list = list ()
    description_list = list()
    option_list = list()
    support_option_list = list ()
    
    name_filename='name'
    description_filename='description'
    run_filename='run'
    offlinedoc_filename='local_doc.html'
    version_filename='VERSION'
    
    maximum_option_columns=3
    
    if (os.path.isfile(current_pwd + '/' + version_filename)): 
      rescapp_version = linecache.getline(current_pwd + '/' + version_filename, 1)
      rescapp_version = rescapp_version.rstrip('\r\n'); 
      print "DEBUG: Version " + rescapp_version + " found."
    else:
      rescapp_version = "Unknown"
      print "DEBUG: Warning! Version not found. Using 'Unknown' instead"
      
    chat_support_option= RescappOption()
    chat_support_option.setFromDir(os.path.join(current_pwd, 'chat'), 'chat')
    share_log_support_option= RescappOption()
    share_log_support_option.setFromDir(os.path.join(current_pwd, 'share_log'), 'share_log')

    help_support_option= RescappOption()
    help_support_option.setFromDir(os.path.join(current_pwd, 'help-rescapp'), 'help-rescapp')
    
    app=QtGui.QApplication(sys.argv)
    url = QtCore.QUrl('file:///' + current_pwd + '/' + help_support_option.getCode() + '/' + offlinedoc_filename)
    mw=MainWindow(url)
    mw.setWindowTitle("Rescatux " + rescapp_version +" Rescapp")

    mw.selectSupportOption(help_support_option)
    mw.show()
    sys.exit(app.exec_())