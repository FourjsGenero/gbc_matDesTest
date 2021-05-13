-- This program is for testing basic GBC UI look-n-feel customizations.
-- By: Neil J Martin ( neilm@4js.com )

IMPORT os
IMPORT FGL gl_lib
&include "genero_lib.inc"

CONSTANT C_PRGDESC = "Material Design Test"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_VER = "3.2"
CONSTANT C_PRGICON = "logo_dark"
CONSTANT C_IMG = "smiley"

CONSTANT PG_MAX = 1000

DEFINE m_forms DYNAMIC ARRAY OF STRING

MAIN
	DEFINE l_rec RECORD
		fld1 CHAR(10),
		fld2 DATE,
		fld3 STRING,
		fld4 STRING,
		fld5 STRING,
		fld6 STRING,
		fld7 STRING,
		fld8 STRING,
		okay BOOLEAN,
		notokay BOOLEAN,
		nul BOOLEAN
	END RECORD
	DEFINE l_arr DYNAMIC ARRAY OF RECORD
		col1 STRING,
		col2 SMALLINT,
		img STRING
	END RECORD
	DEFINE l_listView DYNAMIC ARRAY OF RECORD
		col1 STRING,
		col2 STRING,
		img STRING
	END RECORD
	DEFINE x SMALLINT

	CALL gl_lib.gl_setInfo(C_VER, NULL, C_PRGICON, NULL, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(arg_val(1), NULL, TRUE)
--  CALL ui.Interface.setImage("fa-bug")
	FOR x = 1 TO 15
		LET l_arr[x].col1 = "Row " || x
		LET l_arr[x].col2 = x
		LET l_arr[x].img = C_IMG
		LET l_listView[x].col1 = "This is row " || x
		LET l_listView[x].col2 = "this is a like an information line"
		LET l_listView[x].img = C_IMG
	END FOR
	LET l_rec.fld1 = "Active"
	LET l_rec.fld2 = TODAY
	LET l_rec.fld3 = "Red"
	LET l_rec.fld4 = "Inactive"
	LET l_rec.fld5 = "Active"
	LET l_rec.fld6 = "Inactive"
	LET l_rec.fld7 = "Active"
	LET l_rec.fld8 = "Inactive"
	LET l_rec.okay = TRUE
	LET l_rec.notokay = FALSE
	LET l_rec.nul = NULL

	OPEN FORM f FROM "matDesTest"
	DISPLAY FORM f

	DISPLAY fgl_getenv("FGLIMAGEPATH") TO imgpath
	DISPLAY getAUIAttrVal("StyleList", "fileName") TO stylefile

	DIALOG ATTRIBUTE(UNBUFFERED,FIELD ORDER FORM)
		INPUT BY NAME l_rec.* ATTRIBUTES(WITHOUT DEFAULTS)
		END INPUT
		DISPLAY ARRAY l_arr TO arr1.* --ATTRIBUTES(ACCEPT=FALSE)
		END DISPLAY
		DISPLAY ARRAY l_listView TO arr2.*
			BEFORE ROW
				DISPLAY SFMT("On row %1 of %2",
								DIALOG.getCurrentRow("arr2"), l_listView.getLength())
						TO tab2info
			ON UPDATE
				CALL gl_lib.gl_winMessage(
						"Update", "Update not available!", "exclamation")
			ON DELETE
				CALL gl_lib.gl_winMessage(
						"Delete", "Delete not available!", "exclamation")
		END DISPLAY
		DISPLAY ARRAY l_listView TO arr3.*
			BEFORE ROW
				DISPLAY SFMT("On row %1 of %2",
								DIALOG.getCurrentRow("arr3"), l_listView.getLength())
						TO tab3info
		END DISPLAY
		COMMAND "bomb"
			ERROR "Bang!"
		ON ACTION msg
			MESSAGE "Hello Message"
		ON ACTION err
			ERROR "Error Message"
		ON ACTION win
			CALL win()
		ON ACTION win_mess
			CALL gl_lib.gl_winMessage("Info", "Testing", "information")
		ON ACTION arr2
			CALL DIALOG.nextField("lvcol1")
		ON ACTION arr3
			CALL DIALOG.nextField("a3col1")
		ON ACTION wintitle
			CALL fgl_settitle("My Window Title")
		ON ACTION dyntext
			CALL gbc_replaceHTML("dyntext", "Dynamic Text:" || CURRENT)
		ON ACTION darklogo
			CALL gbc_replaceHTML(
					"logocell", "<img src='./resources/img/logo_dark.png'/>")
		ON ACTION lightlogo
			CALL gbc_replaceHTML(
					"logocell", "<img src='./resources/img/logo_light.png'/>")
		ON ACTION uitext
			CALL ui.Interface.setText("My UI Text")
		ON ACTION pg
			CALL pg(DIALOG.getForm(), 0)
		ON ACTION pg50
			CALL pg(DIALOG.getForm(), (PG_MAX / 2))
		ON ACTION showform
			CALL showForm()
		ON ACTION inactive
			CALL dummy()
		GL_ABOUT
		ON ACTION actiona
			ERROR "Control-A"
		ON ACTION actionb
			ERROR "Control-B"
		ON ACTION actionc
			ERROR "Control-C"
		ON ACTION actiond
			ERROR "Control-D"
		ON ACTION actione
			ERROR "Control-E"
		ON ACTION actionf
			ERROR "Control-F"
		ON ACTION actiong
			ERROR "Control-G"
		ON ACTION actionh
			ERROR "Control-H"
		ON ACTION actioni
			ERROR "Control-I"
		ON ACTION actionj
			ERROR "Control-J"
		ON ACTION actionk
			ERROR "Control-K"
		ON ACTION actionl
			ERROR "Control-L"
		ON ACTION actionm
			ERROR "Control-M"
		ON ACTION actionn
			ERROR "Control-N"
		ON ACTION actiono
			ERROR "Control-O"
		ON ACTION actionp
			ERROR "Control-P"
		ON ACTION actionq
			ERROR "Control-Q"
		ON ACTION actionr
			ERROR "Control-R"
		ON ACTION actions
			ERROR "Control-S"
		ON ACTION actiont
			ERROR "Control-T"
		ON ACTION actionu
			ERROR "Control-U"
		ON ACTION actionv
			ERROR "Control-V"
		ON ACTION actionw
			ERROR "Control-W"
		ON ACTION actionx
			ERROR "Control-X"
		ON ACTION actiony
			ERROR "Control-Y"
		ON ACTION actionz
			ERROR "Control-Z"
		ON ACTION f1
			ERROR "F1"
		ON ACTION f2
			ERROR "F2"
		ON ACTION f3
			ERROR "F3"
		ON ACTION f4
			ERROR "F4"
		ON ACTION f5
			ERROR "F5"
		ON ACTION f6
			ERROR "F6"
		ON ACTION f7
			ERROR "F7"
		ON ACTION f8
			ERROR "F8"
		ON ACTION f9
			ERROR "F9"
		ON ACTION f10
			ERROR "F10"
		ON ACTION f11
			ERROR "F11"
		ON ACTION f12
			ERROR "F12"
		ON ACTION fc_ismob
			CALL gl_lib.gl_winMessage("Mobile?", IIF(gbc_isMobile(),"App Running on Mobile device!","App not running on Mobile device"),"information")
		ON ACTION close
			EXIT DIALOG
		ON ACTION quit
			EXIT DIALOG
		BEFORE DIALOG
			CALL pg(DIALOG.getForm(), (PG_MAX / 2))
			IF ui.Interface.getFrontEndName() != "GBC" THEN
				CALL DIALOG.setActionActive("darklogo", FALSE)
				CALL DIALOG.setActionActive("lightlogo", FALSE)
				CALL DIALOG.setActionActive("dyntext", FALSE)
			END IF
			CALL DIALOG.getForm().ensureElementVisible("bomb") -- attempt to give focus to a button will not work.
	END DIALOG
END MAIN
--------------------------------------------------------------------------------
-- Function just to cause everything to go inactive
FUNCTION dummy()
	MENU "dummy"
		BEFORE MENU
			CALL DIALOG.getForm().setElementText("inactive", "Active")
			CALL DIALOG.getForm().setElementImage("inactive", "fa-eye")
		ON ACTION inactive
			CALL DIALOG.getForm().setElementText("inactive", "Inactive")
			CALL DIALOG.getForm().setElementImage("inactive", "fa-eye-slash")
			EXIT MENU
	END MENU
END FUNCTION
--------------------------------------------------------------------------------
-- ProgressBar tests
FUNCTION pg(l_f ui.Form, l_just_set INTEGER)
	DEFINE x SMALLINT
	DEFINE l_dn om.DomNode
	LET l_dn = l_f.findNode("FormField", "formonly.pg")
	LET l_dn = l_dn.getFirstChild()
	CALL l_dn.setAttribute("valueMax", PG_MAX)
	IF l_just_set > 0 THEN
		DISPLAY l_just_set TO pg
		CALL ui.Interface.refresh()
	ELSE
		FOR x = 1 TO PG_MAX
			DISPLAY x TO pg
			CALL ui.Interface.refresh()
		END FOR
	END IF
END FUNCTION
--------------------------------------------------------------------------------
-- GBC ONLY - isMobile
FUNCTION gbc_isMobile() RETURNS BOOLEAN
	DEFINE l_bool BOOLEAN = FALSE
	IF ui.Interface.getFrontEndName() MATCHES "GM?" THEN RETURN TRUE END IF
	IF ui.Interface.getFrontEndName() = "GDC" THEN RETURN FALSE END IF
	CALL ui.Interface.frontCall(	"mymodule", "isMobile", [], l_bool)
	RETURN l_bool
END FUNCTION
--------------------------------------------------------------------------------
-- GBC ONLY - Dynamically replace HTML code
FUNCTION gbc_replaceHTML(l_obj STRING, l_txt STRING)
	DEFINE l_ret STRING
	IF ui.Interface.getFrontEndName() = "GBC" THEN
		CALL ui.Interface.frontCall(
				"mymodule", "replace_html", [l_obj, l_txt], l_ret)
	ELSE
		CALL gl_lib.gl_winMessage("Error", "GBC Test only!", "exclamation")
	END IF
	DISPLAY "l_ret:", l_ret
END FUNCTION
--------------------------------------------------------------------------------
-- Show a list .42f files in a Window and allow them to be viewed
FUNCTION showForm()
	DEFINE l_path, l_file STRING
	DEFINE l_handle INTEGER
	IF m_forms.getLength() = 0 THEN
		LET l_path = os.Path.pwd()
		CALL os.Path.dirSort("name", 1)
		LET l_handle = os.Path.dirOpen(l_path)
		WHILE l_handle > 0
			LET l_file = os.Path.dirNext(l_handle)
			IF l_file IS NULL THEN
				EXIT WHILE
			END IF
			IF os.Path.extension(l_file) = "42f" THEN
				LET m_forms[m_forms.getLength() + 1] = l_file
			END IF
		END WHILE
		CALL os.Path.dirClose(l_handle)
	END IF
	OPEN WINDOW matDesTest_forms WITH FORM "matDesTest_forms"
	DISPLAY ARRAY m_forms TO arr.*
		ON ACTION accept
			CALL showForm2(m_forms[arr_curr()])
		ON ACTION win
			CALL win()
	END DISPLAY
	CLOSE WINDOW matDesTest_forms
END FUNCTION
--------------------------------------------------------------------------------
-- Open a window with the pass form name
FUNCTION showForm2(l_formName STRING)
	OPEN WINDOW aform WITH FORM l_formName
	MENU
		ON ACTION close
			EXIT MENU
		ON ACTION cancel
			EXIT MENU
		ON ACTION quit
			EXIT MENU
	END MENU
	CLOSE WINDOW aform
END FUNCTION
--------------------------------------------------------------------------------
-- A simple modal window
FUNCTION win()
	OPEN WINDOW win WITH FORM "matDesTest_modal"
	MENU
		ON ACTION close
			EXIT MENU
		ON ACTION cancel
			EXIT MENU
	END MENU
	CLOSE WINDOW win
END FUNCTION
--------------------------------------------------------------------------------
-- A value of aui node
FUNCTION getAUIAttrVal(l_nodeName STRING, l_attName STRING) RETURNS STRING
	DEFINE l_ret STRING
	DEFINE l_nl om.NodeList
	LET l_nl = ui.Interface.getRootNode().selectByTagName(l_nodeName)
	IF l_nl.getLength() = 0 THEN
		RETURN NULL
	END IF
	LET l_ret = l_nl.item(1).getAttribute(l_attName)
	RETURN l_ret
END FUNCTION
