#!/usr/bin/env python
# Rescapp main script
# Copyright (C) 2012 Adrian Gibanel Lopez
#
# Rescapp is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rescapp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rescapp.  If not, see <http://www.gnu.org/licenses/>.

import sys, subprocess, os, time, linecache, sip
from PyQt4 import QtGui,QtCore,QtWebKit
from functools import partial


class RescappOption():

    def __init__(self):
      self.code=""
      self.name=""
      self.description=""
      self.isOptionAttr=False
      self.hasOfflineDoc=False
      self.executable=False
      self.beta=False
      
    def isMenu(self):
      return (self.isOptionAttr == False)
    def isOption(self):
      return (self.isOptionAttr == True)
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
      self.isOptionAttr = False
    def setAsOption(self):
      self.isOptionAttr = True
    def setHasOfflineDoc(self, mybool):
      self.hasOfflineDoc=mybool
    def getHasOfflineDoc(self):
      return self.hasOfflineDoc
    def setExecutable(self, mybool):
      self.executable=mybool
    def getExecutable(self):
      return self.executable
    def setBeta(self, mybool):
      self.beta=mybool
    def getBeta(self):
      return self.beta
    def setFromDir(self, dir_to_check, ndir):
      global current_pwd
      global name_filename
      global description_filename
      global run_filename
      global beta_filename
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
      if (os.path.isfile(current_pwd + '/' + ndir + '/' + beta_filename)):
	self.setBeta(True)
      if (os.path.isfile(current_pwd + '/' + ndir + '/' + offlinedoc_filename)):
	self.setAsOption()
	self.setHasOfflineDoc(True)


class MainWindow(QtGui.QWidget):	


    def selectOptionCommon (self, n_option):
	global current_pwd
      	global name_filename
	global description_filename
	global run_filename
	global beta_filename
	global offlinedoc_filename
	global option_history_list

	self.selected_option = n_option
	self.selected_option_code = n_option.getCode()
	print "DEBUG: selected_option_code in selectOptionCommon: " + self.selected_option_code
	option_history_list.append(n_option)
	if (self.selected_option_code == "help-rescapp"):
	  self.parserescappmenues('rescatux.lis')
	self.drawMainWindows()
	
    def selectOption(self, option_code):
	global option_list
	
	print "DEBUG: Selecting option (code): " + option_code
	for n_option in option_list:	    
	    if (n_option.getCode() == option_code):
	      self.selectOptionCommon(n_option)

    def selectPreviousOption(self):
	global option_history_list
	print "DEBUG: option_history_list contents: "
	for debug_option in (option_history_list):
	  print "Debug content: " + debug_option.getCode()
	n_option = option_history_list.pop()
	n_option = option_history_list.pop()
	print "DEBUG: Selecting previous option (code): " + n_option.getCode()
	self.selectSupportOption(n_option)
	      
    def selectSupportOption(self, support_RescappOption):
	print "DEBUG: Selecting Support option (code): " + support_RescappOption.getCode()
	self.selectOptionCommon(support_RescappOption)
	
    def selectMenu(self, menuOption):
	print "DEBUG: Selecting Menu option (code): " + menuOption.getCode()
	self.selectOptionCommon(menuOption)
	self.parserescappmenues(menuOption.getCode() + '.lis')
	
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
      
      
      f=open(current_pwd + '/' + 'rescatux.lis')
      for mydir in f:
	ndir = mydir.rstrip('\r\n');
	dir_to_check = os.path.join(current_pwd, ndir)
	print dir_to_check
	if os.path.isdir(dir_to_check):
	  new_option = RescappOption()
	  new_option.setFromDir(dir_to_check, ndir)
	  option_list.append(new_option)
	  f2=open(current_pwd + '/' + ndir + '.lis')
	  for mydir2 in f2:
	    ndir2 = mydir2.rstrip('\r\n');
	    dir_to_check2 = os.path.join(current_pwd, ndir2)
	    print dir_to_check2
	    if os.path.isdir(dir_to_check2):
	      new_option2 = RescappOption()
	      new_option2.setFromDir(dir_to_check2, ndir2)
	      option_list.append(new_option2)
	  
	  
	else:
	  print "DEBUG: Warning: " + dir_to_check + " was ignored because it was not a directory!"
      print "DEBUG: menu_base: " + menu_base
      if (menu_base == "rescatux.lis"):
	self.selected_option = help_support_option
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
	mainmenu_btn.setIcon(QtGui.QIcon(mainmenu_icon_path))
	
        back_btn = QtGui.QPushButton('BACK', self)
	back_btn.clicked.connect(self.selectPreviousOption)
	back_btn.setToolTip("Go back to the previous option")
	back_btn.setIcon(QtGui.QIcon(back_icon_path))
	
	self.rescue_btn = QtGui.QPushButton('RESCUE!', self)
	self.rescue_btn.setToolTip("Run selected option!")
	self.rescue_btn.clicked.connect(self.runRescue)
	self.rescue_btn.setIcon(QtGui.QIcon(rescue_icon_path))
	
	if (self.selected_option.getExecutable() == True):
	  self.rescue_btn.show()
	  if (self.selected_option.getBeta() == True):
	    self.rescue_btn.setText(self.selected_option.getName()+ " (BETA) " + "!!!")
	  else:
	    self.rescue_btn.setText(self.selected_option.getName()+ "!!!")
	  self.rescue_btn.setToolTip(self.selected_option.getDescription())
	else:
	  if (hasattr(self, 'rescue_btn') == True ):
	    self.rescue_btn.hide()


	
	
	self.chat_btn = QtGui.QPushButton(chat_support_option.getName(), self)
	self.chat_btn.clicked.connect(partial(self.selectSupportOption,chat_support_option))
	self.chat_btn.setToolTip(chat_support_option.getDescription())
	self.chat_btn.setIcon(QtGui.QIcon(support_icon_path))
	
	self.share_log_btn = QtGui.QPushButton(share_log_support_option.getName(), self)
	self.share_log_btn.clicked.connect(partial(self.selectSupportOption,share_log_support_option))
	self.share_log_btn.setToolTip(share_log_support_option.getDescription())
	self.share_log_btn.setIcon(QtGui.QIcon(support_icon_path))
	
	self.help_btn = QtGui.QPushButton(help_support_option.getName(), self)
	self.help_btn.clicked.connect(partial(self.selectSupportOption,help_support_option))
	self.help_btn.setToolTip(help_support_option.getDescription())
	self.help_btn.setIcon(QtGui.QIcon(support_icon_path))

	self.wb=QtWebKit.QWebView()
	self.wb.load(url)

        grid = QtGui.QGridLayout()
        grid.setSpacing(10)
	

	grid.addWidget(mainmenu_btn,0,0,1,1)
	if (len (option_history_list) > 1):
	  grid.addWidget(back_btn,0,1,1,1)
	else:
	  grid.addWidget(back_btn,0,1,1,1)
	  back_btn.hide()
	grid.addWidget(self.chat_btn,0,2,1,1)
	grid.addWidget(self.share_log_btn,0,3,1,1)
	grid.addWidget(self.help_btn,0,4,1,1)
	grid.addWidget(self.rescue_btn,title_offset,1,title_offset+rows_per_option-1,1)

	options_offset = 1 + title_offset
	  
	options_slot_list = list ()
	x_grid_position = 1
	
	name_pos_x = 1
	name_pos_y = 0
	print "DEBUG: selected option code: " + self.selected_option.getCode()
	if ((self.selected_option.isMenu() == True ) or (self.selected_option.getCode() == "help-rescapp")):
	  for n_option in option_list:
	    print "DEBUG: n_option code: "+ n_option.getCode() +" was found"
	    if ((n_option.getExecutable() == True) or (n_option.getHasOfflineDoc() == True)):
	      print "DEBUG: n_option " + n_option.getCode() + " has offlinedoc and it is executable"
	      if (n_option.getBeta() == True):
		tmp_name_button = QtGui.QPushButton(n_option.getName()+ " (BETA) ", self)
	      else:
		tmp_name_button = QtGui.QPushButton(n_option.getName(), self)
	      tmp_option_slot = partial(self.selectOption,n_option.getCode())
	      tmp_name_button.clicked.connect(tmp_option_slot)
	    else:
	      print "DEBUG: n_option " + n_option.getCode() + " is a menu"
	      tmp_name_button = QtGui.QLabel(n_option.getName(), self)
	      tmp_name_button.setTextFormat(QtCore.Qt.RichText)
	      tmp_name_button.setText("<img src=" + menu_icon_path + ">"+n_option.getName())

	    tmp_name_button.setToolTip(n_option.getDescription())
	    if (n_option.isMenu()):
	      name_pos_y=name_pos_y + 1
	      name_pos_x=name_pos_x + 1
	      x_grid_position = x_grid_position + rows_per_option
	      name_pos_y=0
	    grid.addWidget(tmp_name_button,options_offset+name_pos_x,name_pos_y,rows_per_option,1)
	    name_pos_y=name_pos_y + 1
	    if ((name_pos_y % maximum_option_columns) == 0) or (n_option.isMenu()):
	      name_pos_x=name_pos_x + 1
	      x_grid_position = x_grid_position + rows_per_option
	      name_pos_y=0
	else:
	  tmp_description_label = QtGui.QLabel("<b>" + self.selected_option.getDescription()+"</b>")
	  tmp_description_label.setWordWrap(True)
	  grid.addWidget(tmp_description_label,options_offset+name_pos_x,name_pos_y,rows_per_option,4)
	  name_pos_x=name_pos_x + 1
	  
	bottom_start = options_offset + (name_pos_x * rows_per_option) + 8
	webgrid = QtGui.QHBoxLayout()
	webgrid.addWidget(self.wb)
	frame = QtGui.QFrame()
	frame.setLayout(webgrid)
	frame.setStyleSheet("margin:0px; border:10px solid rgb(124, 127, 126); ")
	grid.addWidget(frame, bottom_start + 5, 0, 5, 5)
	
	if (self.selected_option.getHasOfflineDoc()):
	  self.wb.load(QtCore.QUrl('file:///' + current_pwd + '/' + self.selected_option.getCode() + '/' + offlinedoc_filename))        
        
        
	self.setLayout(grid)
	self.setMaximumHeight(1000)

    def initActions(self):
        self.exitAction = QtGui.QAction('Quit', self)
        self.exitAction.setShortcut('Ctrl+Q')
        self.exitAction.setStatusTip('Exit application')
        self.connect(self.exitAction, QtCore.SIGNAL('triggered()'), self.close)
    
    def __init__(self, url):
        QtGui.QMainWindow.__init__(self)
        self.initActions()
        self.addAction(self.exitAction)
	self.parserescappmenues(mainmenu_filename)

        


if __name__ == "__main__":
  
  
    current_pwd="/home/user/Desktop/rescapp"
    mainmenu_filename = 'rescatux.lis'
    code_list = list ()
    name_list = list ()
    description_list = list()
    option_list = list()
    support_option_list = list ()
    option_history_list = list ()
    
    name_filename='name'
    description_filename='description'
    run_filename='run'
    beta_filename='ISBETA'
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
    
    images_path = current_pwd + '/' + "images"
    mainmenu_icon_path = images_path + "/" + "go-home.png"
    back_icon_path = images_path + "/" + "go-previous.png"
    menu_icon_path = images_path + "/" + "folder.png"
    support_icon_path = images_path + "/" + "help-browser.png"
    rescue_icon_path = images_path + "/" + "text-x-script.png"
    
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