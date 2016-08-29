# April Fools Day Script
# Copyright (C) 2012,2013,2014,2015,2016 Adrian Gibanel Lopez
class CloseOnClickQWidget(QtGui.QWidget):
	def mousePressEvent(self,event):
		self.close()


afd_image_path = images_path + "/" + "US-FBI-ShadedSeal.svg"
afd_app = QtGui.QApplication(sys.argv)


afd_grid = QtGui.QGridLayout()
afd_grid.setSpacing(10)

# afd_title
afd_title = QtGui.QLabel("Your computer has been locked!")
afd_title_font = QtGui.QFont()
afd_title_font.setPointSize(20)
afd_title.setFont(afd_title_font)

afd_title_palette = afd_title.palette()
afd_title_palette.setColor(afd_title.backgroundRole(),QtCore.Qt.red)
afd_title_palette.setColor(afd_title.foregroundRole(),QtCore.Qt.red)
afd_title.setPalette(afd_title_palette)

# afd_message

next_year = str(datetime.datetime.now().year + 1)

afd_message = QtGui.QLabel("This operating system is locked due to the violation of the federal laws of the United States of America!\n(Article 2, Section 9, Clause 9; Article 303; Article 320 of the Criminal Code of U.S.A.\n provides for a deprivation of liberty for one to four years.).\nFollowing violations were detected:\n* You are using Rescatux which its license is: GNU GENERAL PUBLIC LICENSE.\nGNU GENERAL PUBLIC LICENSE has been totally forbidden since "+next_year+"\nin order to protect our Software Industry jobs.\nThis computer lock is aimed to stop your illegal activity.")
afd_message_font = QtGui.QFont()
afd_message_font.setPointSize(14)
afd_message.setFont(afd_message_font)

afd_message_palette = afd_message.palette()
afd_message_palette.setColor(afd_message.backgroundRole(),QtCore.Qt.black)
afd_message_palette.setColor(afd_message.foregroundRole(),QtCore.Qt.black)
afd_message.setPalette(afd_message_palette)

# afd_fine

next_year = str(datetime.datetime.now().year + 1)

afd_fine = QtGui.QLabel("To unlock the computer you are obliged to pay a fine of $100.")
afd_fine_font = QtGui.QFont()
afd_fine_font.setPointSize(14)
afd_fine.setFont(afd_fine_font)

afd_fine_palette = afd_fine.palette()
afd_fine_palette.setColor(afd_fine.backgroundRole(),QtCore.Qt.darkGreen)
afd_fine_palette.setColor(afd_fine.foregroundRole(),QtCore.Qt.darkGreen)
afd_fine.setPalette(afd_fine_palette)

# afd_pay

next_year = str(datetime.datetime.now().year + 1)

afd_pay = QtGui.QLabel("You have 48 hours to pay the fine, otherwise you will be arrested.\nPlease click this text anywhere to learn about the different payment methods available.")
afd_pay_font = QtGui.QFont()
afd_pay_font.setPointSize(14)
afd_pay.setFont(afd_pay_font)

afd_pay_palette = afd_pay.palette()
afd_pay_palette.setColor(afd_pay.backgroundRole(),QtCore.Qt.black)
afd_pay_palette.setColor(afd_pay.foregroundRole(),QtCore.Qt.black)
afd_pay.setPalette(afd_pay_palette)

# fbi_image

afd_fbi = QtGui.QLabel()
afd_pixmap = QtGui.QPixmap(afd_image_path)
afd_fbi.resize(640,480)
afd_scaled_pixmap = afd_pixmap.scaled(afd_fbi.size(),QtCore.Qt.KeepAspectRatio)
afd_fbi.setPixmap(afd_scaled_pixmap)
#afd_fbi.setPixmap(afd_pixmap)

afd_grid.addWidget(afd_title,0,0,1,0)
afd_grid.addWidget(afd_message,1,0,5,2)
afd_grid.addWidget(afd_fine,6,0,1,1)
afd_grid.addWidget(afd_pay,7,0,1,1)
afd_grid.addWidget(afd_fbi,8,0,1,1)

afd_scrollArea = VerticalScrollArea()
afd_gridQWidget =  QtGui.QWidget()
afd_gridQWidget.setLayout(afd_grid)
afd_scrollArea.setWidgetResizable(False)
afd_scrollArea.setWidget(afd_gridQWidget)
afd_scrollArea.setMinimumWidth(afd_gridQWidget.minimumSizeHint().width())
afd_qVboxLayout = QtGui.QVBoxLayout()
afd_qVboxLayout.addWidget(afd_scrollArea)

afd_window = CloseOnClickQWidget()

# Clear Layout - Begin
if afd_window.layout() is not None:
	old_layout = afd_window.layout()
	for i in reversed(range(old_layout.count())):
		old_layout.itemAt(i).widget().setParent(None)
	sip.delete(old_layout)
# Clear Layout - End

QtGui.QWidget.setLayout(afd_window,afd_qVboxLayout)
afd_window.showFullScreen()
afd_app.exec_()