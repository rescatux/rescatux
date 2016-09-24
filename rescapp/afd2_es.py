# April Fools Day 2 Script
# -*- coding: utf-8 -*-
# Copyright (C) 2012,2013,2014,2015,2016 Adrian Gibanel Lopez
afd2_app = QtGui.QApplication(sys.argv)


afd2_grid = QtGui.QGridLayout()
afd2_grid.setSpacing(10)

# afd2_title
afd2_title = QtGui.QLabel(u"¿Asustado?")
afd2_title_font = QtGui.QFont()
afd2_title_font.setPointSize(30)
afd2_title.setFont(afd2_title_font)

afd2_title_palette = afd2_title.palette()
afd2_title_palette.setColor(afd2_title.backgroundRole(),QtCore.Qt.red)
afd2_title_palette.setColor(afd2_title.foregroundRole(),QtCore.Qt.red)
afd2_title.setPalette(afd2_title_palette)

# afd2_message

this_year = str(datetime.datetime.now().year)

afd2_message = QtGui.QLabel(u"¡¡¡ " + u"Feliz día<br>de los<br>santos inocentes<br>del año "+this_year+ u" !!!")
afd2_message_font = QtGui.QFont()
afd2_message_font.setPointSize(40)
afd2_message.setFont(afd2_message_font)

afd2_message_palette = afd2_message.palette()
afd2_message_palette.setColor(afd2_message.backgroundRole(),QtCore.Qt.black)
afd2_message_palette.setColor(afd2_message.foregroundRole(),QtCore.Qt.black)
afd2_message.setPalette(afd2_message_palette)

# afd2_pay

next_year = str(datetime.datetime.now().year + 1)

afd2_pay = QtGui.QLabel("Pulsa en cualquier sitio para usar Rescatux / Rescapp .")
afd2_pay_font = QtGui.QFont()
afd2_pay_font.setPointSize(14)
afd2_pay.setFont(afd2_pay_font)

afd2_pay_palette = afd2_pay.palette()
afd2_pay_palette.setColor(afd2_pay.backgroundRole(),QtCore.Qt.darkGreen)
afd2_pay_palette.setColor(afd2_pay.foregroundRole(),QtCore.Qt.darkGreen)
afd2_pay.setPalette(afd2_pay_palette)

afd2_grid.addWidget(afd2_title,0,0,1,0)
afd2_grid.addWidget(afd2_message,5,0,2,0)
afd2_grid.addWidget(QtGui.QLabel(),6,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),7,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),8,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),9,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),10,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),11,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),12,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),13,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),14,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),15,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),16,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),17,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),18,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),19,0,2,1)
afd2_grid.addWidget(QtGui.QLabel(),20,0,2,1)
afd2_grid.addWidget(afd2_pay,21,0,1,1)

afd2_scrollArea = VerticalScrollArea()
afd2_gridQWidget =  QtGui.QWidget()
afd2_gridQWidget.setLayout(afd2_grid)
afd2_scrollArea.setWidgetResizable(False)
afd2_scrollArea.setWidget(afd2_gridQWidget)
afd2_scrollArea.setMinimumWidth(afd2_gridQWidget.minimumSizeHint().width())
afd2_qVboxLayout = QtGui.QVBoxLayout()
afd2_qVboxLayout.addWidget(afd2_scrollArea)

afd2_window = CloseOnClickQWidget()

# Clear Layout - Begin
if afd2_window.layout() is not None:
	old_layout = afd2_window.layout()
	for i in reversed(range(old_layout.count())):
		old_layout.itemAt(i).widget().setParent(None)
	sip.delete(old_layout)
# Clear Layout - End

QtGui.QWidget.setLayout(afd2_window,afd2_qVboxLayout)
afd2_window.showFullScreen()
afd2_app.exec_()