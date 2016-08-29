#!/usr/bin/env python
# Rescapp order.py script
# Copyright (C) 2012,2013,2014,2015,2016 Adrian Gibanel Lopez
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


import sys, subprocess, os, time, linecache, sip, getopt
from PyQt4 import QtGui,QtCore,QtWebKit
from PyQt4.QtGui import QIcon
from PyQt4.QtCore import QStringList

class MainWindow(QtGui.QWidget):

    def setLayout(self, layout):
	self.clearLayout()
	QtGui.QWidget.setLayout(self, layout)

    def clearLayout(self):
	if self.layout() is not None:
	    old_layout = self.layout()
	    for i in reversed(range(old_layout.count())):
		old_layout.itemAt(i).widget().setParent(None)
	    sip.delete(old_layout)

    def refresh_harddisks(self):
	#print "DEBUG: rh"
        while self.harddisks_tablewidget.rowCount(): 
            self.harddisks_tablewidget.removeRow(0)
        n = 0
        m = 0
        for harddisk in harddisks:
	    self.harddisks_tablewidget.insertRow(self.harddisks_tablewidget.rowCount())
	    m = 0
	    for cell in harddisk:
	      item = QtGui.QTableWidgetItem(cell)
	      self.harddisks_tablewidget.setItem(n,m,item)
	      m +=1  
	    n +=1
	    
	self.harddisks_tablewidget.setColumnCount(m)

            
    def move_up_button_clicked(self):
	global harddisks
        current = self.harddisks_tablewidget.currentRow()
        
        if current == -1:
            return 
        
        item = harddisks.pop(current)
        harddisks.insert(current-1, item)
        
        self.refresh_harddisks()
        
        self.harddisks_tablewidget.setCurrentCell(self.harddisks_tablewidget.rowCount()-1,self.harddisks_tablewidget.currentColumn())
    def move_down_button_clicked(self):
	global harddisks
        current = self.harddisks_tablewidget.currentRow()
        
        if current == -1:
            return 
        
        item = harddisks.pop(current)
        harddisks.insert(current+1, item)
        
        self.refresh_harddisks()
        
        self.harddisks_tablewidget.setCurrentCell(self.harddisks_tablewidget.rowCount()+1,self.harddisks_tablewidget.currentColumn())

    def selected_harddisk_changed(self):                       

        current = self.harddisks_tablewidget.currentRow()

        self.move_up_button.setEnabled(True)
        self.move_down_button.setEnabled(True)
        
        if current == 0:
            self.move_up_button.setEnabled(False)
        if current == self.harddisks_tablewidget.rowCount()-1:
            self.move_down_button.setEnabled(False)
	  
	  


    def drawMainWindows(self):
	global harddisks
	global description
      
	
	self.okbtn = QtGui.QPushButton('Ok', self)
        self.okbtn.clicked.connect(self.close)
        self.okbtn.resize(self.okbtn.sizeHint())
	
	# Initialize hard disk stuff - BEGIN
	self.harddisks_tablewidget = QtGui.QTableWidget()
	self.harddisks_tablewidget.itemSelectionChanged.connect(self.selected_harddisk_changed)

	self.harddisks_tablewidget.setSelectionBehavior(QtGui.QAbstractItemView.SelectRows);
	self.harddisks_tablewidget.setSelectionMode(QtGui.QAbstractItemView.SingleSelection);
	# Initialize hard disk stuff - END
	# Move up button - BEGIN
	self.move_up_button = QtGui.QToolButton();
	self.move_up_button.setIcon(QtGui.QIcon(go_up_icon_path))
	self.move_up_button.clicked.connect(self.move_up_button_clicked)
	# Move up button - END
	
	# Move down button - BEGIN
	self.move_down_button = QtGui.QToolButton();
	self.move_down_button.setIcon(QtGui.QIcon(go_down_icon_path))
	self.move_down_button.clicked.connect(self.move_down_button_clicked)
	# Move down button - END
	self.refresh_harddisks()
	# Add button - BEGIN

	self.descriptionwidget = QtGui.QLabel(description)
	self.descriptionwidget.setWordWrap(1==1)

        grid = QtGui.QGridLayout()
        grid.setSpacing(10)

	grid.addWidget(self.descriptionwidget, 0, 0, 1, 3)
	grid.addWidget(self.harddisks_tablewidget, 1, 2, 10, 10)
	grid.addWidget(self.move_up_button, 1, 0, 1, 1)
	grid.addWidget(self.move_down_button, 1, 1, 1, 1)
	grid.addWidget(self.okbtn,2,0,1,1)
        
        #grid.setMargin(0)
        #grid.setContentsMargins(0,0,0,0)
	self.setLayout(grid)

	self.setMinimumHeight(600)
	self.setMinimumWidth(600)

    def __init__(self):
        QtGui.QMainWindow.__init__(self)
    def closeEvent(self,event):
      for harddisk in harddisks:
	print(harddisk[0])
      event.accept()


if __name__ == "__main__":
 
    app=QtGui.QApplication(sys.argv)
    
    # TODO: rescapp.py an order.py take images_path from the same included py file
    current_pwd="/home/user/Desktop/rescapp"
    images_path = current_pwd + '/' + "images"
    go_down_icon_path = images_path + "/" + "go-down.png"
    go_up_icon_path = images_path + "/" + "go-up.png"
    
    harddisks = []
    label_list = QStringList()
    mw=MainWindow()
    
    
    
    myargs = sys.argv[1:]
    # Parse number of columns
    column_number=int(sys.argv[1])
    #print "Column number: " + str(column_number)
    #print myargs
    
    myargs.pop(0)
    
    # Parse window title
    window_title = myargs[0]
    myargs.pop(0)
    # Parse description
    description = myargs[0]
    myargs.pop(0)
    
    mw.drawMainWindows()
    
    # Parse label descriptions
    ncolumn=0
    while (ncolumn < column_number):
      label_descr = myargs[0]
      label_list.append(label_descr)
      myargs.pop(0)
      ncolumn+=1
    #print "labels: " + str(label_list)
    # Parse contents
    row=0
    while myargs:
      new_harddisk = []
      ncolumn=0
      while (ncolumn < column_number):
	new_harddisk_descr = myargs[0]
	new_harddisk.append(new_harddisk_descr)
	myargs.pop(0)
	ncolumn+=1
      harddisks.append(new_harddisk)
      mw.refresh_harddisks()
      row+=1
    #print harddisks
    mw.harddisks_tablewidget.setHorizontalHeaderLabels(label_list)
    mw.setWindowTitle(window_title)
    
    mw.show()
    sys.exit(app.exec_())