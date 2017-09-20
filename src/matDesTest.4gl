
IMPORT os
IMPORT FGL gl_lib
&include "genero_lib.inc"
CONSTANT C_VER="3.1"
CONSTANT PRGDESC = "Material Design Test"
CONSTANT PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGICON = "njm_demo_icon"

CONSTANT PG_MAX=10000

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
		okay BOOLEAN
	END RECORD
	DEFINE l_arr DYNAMIC ARRAY OF RECORD
		col1 STRING,
		col2 SMALLINT,
		img STRING
	END RECORD
	DEFINE x SMALLINT

	CALL gl_lib.gl_setInfo(C_VER, NULL, C_PRGICON, NULL, PRGDESC, PRGAUTH)
	CALL gl_lib.gl_init( ARG_VAL(1) ,NULL,TRUE)
	CALL ui.Interface.setText( gl_lib.gl_progdesc )

	FOR X = 1 TO 5
		LET l_arr[x].col1 = "Row "||x
		LET l_arr[x].col2 = x
		LET l_arr[x].img = "fa-smile-o"
	END FOR

	OPEN FORM f FROM "matDesTest"
	DISPLAY FORM f

	LET l_rec.fld1 = "Active"
	LET l_rec.fld2 = TODAY
	--LET l_rec.fld3 = "Red"
	LET l_rec.fld4 = "Inactive"
	LET l_rec.fld5 = "Active"
	LET l_rec.fld6 = "Inactive"
	LET l_rec.fld7 = "Active"
	LET l_rec.fld8 = "Inactive"

	DIALOG ATTRIBUTE(UNBUFFERED)
		INPUT BY NAME l_rec.* ATTRIBUTES( WITHOUT DEFAULTS )
		END INPUT
		DISPLAY ARRAY l_arr TO arr.*
		END DISPLAY
		ON ACTION msg MESSAGE "Hello Message"
		ON ACTION err ERROR "Error Message"
		ON ACTION win CALL win()
		ON ACTION wintitle CALL fgl_setTitle("My Window Title")
		ON ACTION dyntext CALL gbc_replaceHTML("dyntext","Dynamic Text")
		ON ACTION darklogo CALL gbc_replaceHTML("logocell","<img src='./resources/img/logo_dark.png'/>")
		ON ACTION lightlogo CALL gbc_replaceHTML("logocell","<img src='./resources/img/logo.png'/>")
		ON ACTION uitext CALL ui.Interface.setText("My UI Text")
		ON ACTION pg CALL pg(DIALOG.getForm(), 0)
		ON ACTION pg50 CALL pg(DIALOG.getForm(), (PG_MAX / 2) )
		ON ACTION showform CALL showForm()
		ON ACTION inactive CALL dummy()
		GL_ABOUT
		ON ACTION close EXIT DIALOG
		ON ACTION quit EXIT DIALOG
		BEFORE DIALOG
			CALL pg(DIALOG.getForm(), (PG_MAX / 2) )
	END DIALOG
END MAIN
--------------------------------------------------------------------------------
FUNCTION win()
	OPEN WINDOW win WITH FORM "matDesTest_modal"
	MENU
		ON ACTION close EXIT MENU
		ON ACTION cancel EXIT MENU
	END MENU
	CLOSE WINDOW win
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION dummy()
	MENU "dummy"
		BEFORE MENU
			CALL DIALOG.getForm().setElementText("inactive","Active")
			CALL DIALOG.getForm().setElementImage("inactive","fa-eye")
		ON ACTION inactive
			CALL DIALOG.getForm().setElementText("inactive","Inactive")
			CALL DIALOG.getForm().setElementImage("inactive","fa-eye-slash")
			EXIT MENU
	END MENU
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION pg(l_f ui.Form, l_just_set INTEGER)
	DEFINE x SMALLINT
	DEFINE l_dn om.DomNode
	LET l_dn = l_f.findNode("FormField","formonly.pg")
	LET l_dn = l_dn.getFirstChild()
	CALL l_dn.setAttribute("valueMax",PG_MAX)
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
FUNCTION gbc_replaceHTML(l_obj STRING, l_txt STRING)
	DEFINE l_ret STRING
	CALL ui.Interface.frontCall("mymodule","replace_html",[ l_obj, l_txt ], l_ret)
	DISPLAY "l_ret:",l_ret
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION showForm()
	DEFINE l_path, l_file STRING
	DEFINE l_handle INTEGER
	IF m_forms.getLength() = 0 THEN
		LET l_path = os.Path.pwd()
		CALL os.Path.dirSort("name", 1)
		LET l_handle = os.Path.dirOpen(l_path)
		WHILE l_handle > 0
			LET l_file = os.Path.dirNext(l_handle)
			IF l_file IS NULL THEN EXIT WHILE END IF
			IF os.path.extension(l_file) = "42f" THEN
				LET m_forms[ m_forms.getLength() + 1 ] = l_file
			END IF
		END WHILE
		CALL os.Path.dirClose(l_handle)
	END IF
	OPEN WINDOW matDesTest_forms WITH FORM "matDesTest_forms"
	DISPLAY ARRAY m_forms TO arr.*
		ON ACTION accept CALL showForm2( m_forms[ arr_curr() ] )
	END DISPLAY
	CLOSE WINDOW matDesTest_forms
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION showForm2(l_formName STRING)
	OPEN WINDOW aform WITH FORM l_formName
	MENU
		ON ACTION close EXIT MENU
		ON ACTION cancel EXIT MENU
		ON ACTION quit EXIT MENU
	END MENU
	CLOSE WINDOW aform
END FUNCTION