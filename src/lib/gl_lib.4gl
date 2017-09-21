--------------------------------------------------------------------------------
#+ Genero Library 1 - by Neil J Martin ( neilm@4js.com )
#+ This library is intended as an example of useful library code for use with
#+ Genero 3.10 and above
#+
#+ No warrantee of any kind, express or implied, is included with this software;
#+ use at your own risk, responsibility for damages (if any) to anyone resulting
#+ from the use of this software rests entirely with the user.
#+
#+ Environment Variables:
#+
#+	FJS_GL_DBGLEV: 0-3 Debug output.
#+	FJS_MDICONT: MDI Container name
#+	FJS_MDITITLE: MDI Text for container program
#+	FJS_STYLE: Style file to use if not default
#+	FJS_STYLE2: Additional Style file to merge with current.
#+	FJS_GL_NOINIT: Don't use Form Initializer
#+	FJS_PICS: Add this path to images used for splash etc. Will default to FGLIMAGEPATH
#+

IMPORT os
IMPORT util

&include "genero_lib.inc"

PUBLIC DEFINE gl_dbgLev SMALLINT  -- debug level: 0=None, 1=General, 2=All
PUBLIC DEFINE gl_version STRING
PUBLIC DEFINE gl_progIcon STRING
PUBLIC DEFINE gl_progName STRING -- base.application.getProgramName
PUBLIC DEFINE gl_progDesc STRING
PUBLIC DEFINE gl_progAuth STRING
PUBLIC DEFINE gl_splash STRING
PUBLIC DEFINE gl_toolbar,  gl_topmenu STRING
PUBLIC DEFINE gl_os STRING
PUBLIC DEFINE gl_cli_os STRING
PUBLIC DEFINE gl_cli_osver STRING
PUBLIC DEFINE gl_cli_un STRING
PUBLIC DEFINE gl_cli_res STRING
PUBLIC DEFINE gl_cli_dir STRING
PUBLIC DEFINE gl_fe_typ STRING
PUBLIC DEFINE gl_fe_ver STRING
PUBLIC DEFINE gl_userName STRING
PUBLIC DEFINE gl_app_build STRING -- Applcation Build 
PUBLIC DEFINE gl_app_name STRING -- Applcation Name
PUBLIC DEFINE gl_noToolBar BOOLEAN

PUBLIC DEFINE m_logDir STRING
PUBLIC DEFINE m_logName STRING
PUBLIC DEFINE m_logDate BOOLEAN
PUBLIC DEFINE m_mdi CHAR(1)

DEFINE m_key STRING
DEFINE m_user_agent STRING

--------------------------------------------------------------------------------
#+ Initialize Function
#+
#+ @param l_mdi_sdi Char(1):	"S"-Sdi "M"-mdi Container "C"-mdi Child
#+ @param l_key 		String:		name for .4ad/.4st/.4tb - default="default"
#+ @param l_use_fi 	Smallint:	TRUE/FALSE Set Form Initializer to gl_forminit.
#+ @return Nothing.
FUNCTION gl_init( l_mdi_sdi CHAR(1), l_key STRING, l_use_fi BOOLEAN) --{{{
	DEFINE l_desc, l_container STRING

	LET gl_progName = base.Application.getProgramName()
	CALL gl_userName()
	CALL startLog( os.path.join( gl_getLogDir(),gl_progName||"."||gl_userName||".log"))

	GL_MODULE_ERROR_HANDLER
	OPTIONS ON CLOSE APPLICATION CALL gl_appClose
	OPTIONS ON TERMINATE SIGNAL CALL gl_appTerm

	LET gl_dbgLev = fgl_getEnv("FJS_GL_DBGLEV") -- 0=None, 1=General, 2=All
	IF gl_dbgLev IS NULL THEN LET gl_dbgLev = 0 END IF
	GL_DBGMSG(1, "gl_init: Debug Level:"||gl_dbgLev)

	LET l_desc = base.application.getResourceEntry("fglrun.localization.file.1.name")
	IF l_desc IS NULL THEN
		GL_DBGMSG(0, "gl_init:WARNING: No localization file specified in FGLPROFILE!")
	END IF

	IF l_mdi_sdi IS NULL OR l_mdi_sdi = " " THEN LET l_mdi_sdi = "S" END IF
	LET m_mdi = l_mdi_sdi

	IF gl_os IS NULL THEN
		IF os.Path.separator() = "\\" THEN
			LET gl_os = "Windows"
		ELSE
			LET gl_os = gl_getUname()
			LET gl_os = gl_os.append(" - "||gl_getLinuxVer() )
		END IF
	END IF
	GL_DBGMSG(1, "gl_init: OS:"||gl_os)
	GL_DBGMSG(1, "gl_init: FGLDIR="||fgl_getEnv("FGLSDIR"))
	GL_DBGMSG(1, "gl_init: FGLSERVER="||fgl_getEnv("FGLSERVER"))
	GL_DBGMSG(1, "gl_init: FGLPROFILE="||fgl_getEnv("FGLPROFILE"))
	GL_DBGMSG(1, "gl_init: DBPATH="||fgl_getEnv("DBPATH"))
	GL_DBGMSG(1, "gl_init: DBDATE="||fgl_getEnv("DBDATE"))
	GL_DBGMSG(1, "gl_init: FGLIMAGEPATH="||fgl_getEnv("FGLIMAGEPATH"))

	IF l_key IS NULL THEN LET l_key = "default" END IF
	LET m_key = l_key
	IF gl_toolbar IS NULL THEN LET gl_toolbar = m_key END IF
	IF gl_topmenu IS NULL THEN LET gl_topmenu = m_key END IF

	LET l_key = fgl_getEnv("FJS_STYLE")
	IF l_key.getLength() < 2 THEN LET l_key = m_key END IF -- Style name taken from l_key

-- Added for web client.
	IF fgl_getEnv("FJS_GL_NOINIT") = 1 THEN
		GL_DBGMSG(1, "gl_init: FJS_GL_NOINIT is set.")
		LET l_use_fi = FALSE
	END IF

	IF l_use_fi THEN
		GL_DBGMSG(1, "gl_init: Form Initializer 'gl_forminit'.")
		CALL ui.form.setDefaultInitializer( "gl_forminit" )
	ELSE
		GL_DBGMSG(1, "gl_init: No Form Initializer.")
	END IF

	LET gl_fe_typ = UPSHIFT(ui.interface.getFrontEndName())
	LET gl_fe_ver = ui.interface.getFrontEndVersion()
	GL_DBGMSG(1, "gl_init: FE:"||gl_fe_typ||" version:"||gl_fe_ver)
	LET gl_cli_os = "?"
	LET gl_cli_osver = "?"
	LET gl_cli_res = "?"
	LET gl_cli_dir = "?"
	IF gl_fe_typ = "GBC" THEN LET gl_cli_os = "WWW" END IF
	IF m_mdi != "M" AND m_mdi != "C" AND gl_fe_typ != "GBC" THEN
		CALL ui.interface.frontcall("standard","feinfo",[ "ostype" ], [ gl_cli_os ] )
		CALL ui.interface.frontcall("standard","feinfo",[ "osversion" ], [ gl_cli_osver ] )
		CALL ui.interface.frontCall("standard","feinfo",[ "screenresolution" ], [ gl_cli_res ])
		CALL ui.interface.frontCall("standard","feinfo",[ "fepath" ], [ gl_cli_dir ])
	END IF

	TRY
		CALL ui.interface.loadStyles( m_key||"_"||gl_fe_typ )
		GL_DBGMSG(1, "gl_init: Styles '"||m_key||"_"||gl_fe_typ||"' loaded.")
	CATCH
		GL_DBGMSG(1, "gl_init: Styles '"||m_key||"_"||gl_fe_typ||"' FAILED to load!")
		TRY
			CALL ui.interface.loadStyles( m_key )
			GL_DBGMSG(1, "gl_init: Styles '"||m_key||"' loaded.")
		CATCH
			GL_DBGMSG(0, "gl_init: Styles '"||m_key||"' FAILED to load!")
		END TRY
	END TRY

{
	LET l_key = fgl_getEnv("FJS_STYLE2")
	IF l_key.getLength() > 1 THEN
		CALL gl_mergeST(l_key) -- Merge this style file in with the default one.
	END IF
	CALL gl_addStyles() -- Add default colours and font sizes.
}

	LET l_key = fgl_getEnv("FJS_ACTIONS")
	IF l_key.getLength() < 1 THEN LET l_key = m_key END IF
	TRY
		CALL ui.interface.loadActionDefaults( l_key )
		GL_DBGMSG(1, "gl_init: Action Defaults '"||l_key.trim()||"' loaded.")
	CATCH
		GL_DBGMSG(0, "gl_init: Action Defaults '"||l_key.trim()||"' FAILED to load!")
	END TRY

	IF NOT l_use_fi AND NOT gl_noToolBar THEN
		TRY
			CALL ui.interface.loadToolbar( gl_toolbar )
			GL_DBGMSG(1, "gl_init: Toolbar '"||gl_toolbar||"' loaded.")
		CATCH
			GL_DBGMSG(0, "gl_init: Toolbar '"||gl_toolbar||"' FAILED to load!")
		END TRY
	END IF

	IF m_mdi = "M" OR m_mdi = "s" THEN -- Startmenu only for MDI Container.
		TRY
			CALL ui.Interface.loadStartMenu( m_key )
			GL_DBGMSG(1, "gl_init: Start Menu '"||m_key.trim()||"' loaded.")
		CATCH
			GL_DBGMSG(0, "gl_init: Start Menu'"||m_key.trim()||"' FAILED to load!")
		END TRY
	END IF

	IF gl_progIcon IS NOT NULL THEN
		CALL ui.interface.setImage( gl_progIcon )
		GL_DBGMSG(1, "gl_init: load progIcon '"||gl_progIcon||"'.")
	END IF

-- MDI code
	LET l_container = fgl_getEnv("FJS_MDICONT")
	IF l_container IS NULL OR l_container = " " THEN
		LET l_container = "MDIcontain"
	END IF
	LET l_desc = fgl_getEnv("FJS_MDITITLE")
	IF l_desc IS NULL OR l_desc = " " THEN
		LET l_desc = "MDI Container:"||l_container
	END IF
	CASE m_mdi
		WHEN "C" -- Child
			GL_DBGMSG(2, "gl_init: Child")
			CALL ui.Interface.setType("child")
			CALL ui.Interface.setContainer(l_container)
		WHEN "M" -- MDI Container
			GL_DBGMSG(2, "gl_init: Container:"||l_container)
			CALL ui.Interface.setText(l_desc)
			CALL ui.Interface.setType("container")
			CALL ui.Interface.setName(l_container)
	END CASE
	CALL ui.Interface.setText( gl_progName )

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Cleanly exit program, setting exit status.
#+
#+ @param stat Exit status 0 or -1 normally.
#+ @param reason For Exit, clean, crash, closed, terminated etc
#+ @return none
FUNCTION gl_exitProgram( l_stat SMALLINT, l_reason STRING )
	GL_DBGMSG(0, SFMT("gl_exitProgram: stat=%1 reason:%2",l_stat,l_reason))
	EXIT PROGRAM l_stat
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ On Application Close
FUNCTION gl_appClose()
	GL_DBGMSG(1,"gl_appClose")
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ On Application Terminalate
FUNCTION gl_appTerm()
	GL_DBGMSG(1,"gl_appTerm")
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Set the gl variables for version / splash / progname etc
#+
#+ @param l_version Version
#+ @param l_splash Splash Image
#+ @param l_progicon Icon Image
#+ @param l_progname Program Name
#+ @param l_progdesc Program description
#+ @param l_progauth Program Author
#+ @return none
FUNCTION gl_setInfo(l_version STRING,
										l_splash STRING, 
										l_progicon STRING, 
										l_progname STRING, 
										l_progdesc STRING, 
										l_progauth STRING) --{{{
	IF l_progName IS NULL THEN LET l_progname = base.Application.getProgramName() END IF
	LET gl_version = l_version
	LET gl_splash = l_splash
	LET gl_progicon = l_progicon
	LET gl_progname = l_progname
	LET gl_progdesc = l_progdesc
	LET gl_progauth = l_progauth
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Set the gl variables for application name and build number
#+
#+ @param l_app_name Appliciation Name
#+ @param l_app_build Build No / GIT/SVN/CVS Revision
FUNCTION gl_setAppInfo( l_app_name STRING, l_app_build STRING ) --{{{
	DEFINE c base.Channel
	DEFINE l_info_file STRING
	IF l_app_name IS NULL THEN
		LET l_info_file = "../etc/app_info.txt"
		IF NOT os.path.exists(l_info_file) THEN LET l_info_file = "../etc/app_name.txt" END IF
		LET c = base.Channel.create()
		TRY
			CALL c.openFile(l_info_file,"r")
			LET l_app_name = c.readLine()
			LET l_app_build = c.readLine()
			IF l_app_build IS NULL THEN
				LET l_app_build = os.path.mtime(".") -- use bin date as a build time
			END IF
			CALL c.close()
		CATCH
			GL_DBGMSG(0, "No ../etc/app_info.txt or app_name.txt found!")
		END TRY
	END IF
	LET gl_app_name = l_app_name
	LET gl_app_build = l_app_build
	GL_DBGMSG(0, "App: "||NVL(l_app_name,"NULL")||" Build: "||NVL(l_app_build,"NULL"))
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Form Initializer. Call automatically set setDefaultinitializer is used.
#+
#+ @param fm Form object to be initialized.
FUNCTION gl_formInit(l_fm ui.Form) --{{{
	DEFINE l_fn om.DomNode
	DEFINE l_nam, l_styl, l_tag STRING
	DEFINE l_nl om.nodeList

	GL_DBGMSG(1, "gl_formInit: start")

	LET l_fn = l_fm.getNode()

	LET l_nam = l_fn.getAttribute("name")
	LET l_styl = l_fn.getAttribute("style")
	LET l_tag = l_fn.getAttribute("tag")
	IF l_tag IS NULL THEN LET l_tag = "(null)" END IF
	GL_DBGMSG(0, "gl_formInit: tag='"||l_tag||"'")
	IF l_styl IS NULL THEN -- check to see if the window had the style set.
		LET l_fn = gl_getWinNode(NULL)
		LET l_styl = l_fn.getAttribute("style")
		LET l_fn = l_fm.getNode()
	END IF
	IF l_styl IS NULL THEN
		GL_DBGMSG(1, "gl_formInit: form='"||l_nam||"' style=NULL")
		LET l_styl = "NULL"
	ELSE
		GL_DBGMSG(1, "gl_formInit: form='"||l_nam||"' style='"||l_styl||"'")
	END IF
	
	IF l_styl != "splash" 
	AND l_styl != "dialog" 	AND l_styl != "dialog2" 	AND l_styl != "dialog3" 
	AND l_styl != "menu"
	AND l_styl != "lookup" AND l_styl != "naked" AND l_styl != "about"  AND l_styl != "viewer"
	AND l_styl != "wizard" THEN
		LET l_nl = l_fn.selectByTagName("ToolBar")
		IF NOT gl_noToolBar AND l_nl.getlength() < 1 THEN
			GL_DBGMSG(1, "gl_formInit: loading Toolbar '"||gl_toolbar||"'")
			TRY
				CALL l_fm.loadToolbar( gl_toolbar )
				GL_DBGMSG(0, "gl_formInit: loaded Toolbar '"||gl_toolbar||"'")
			CATCH
				GL_DBGMSG(0, "gl_formInit: Failed to load Toolbar '"||gl_toolbar||"'")
			END TRY
		END IF

		LET l_nl = l_fn.selectByTagName("TopMenu")
		IF l_styl != "main" AND gl_topmenu != "default" AND l_nl.getlength() < 1 THEN -- normal won't want default?
			GL_DBGMSG(1, "gl_formInit: loading TopMenu '"||gl_topmenu||"'")
			TRY
				CALL l_fm.loadTopmenu( gl_topmenu )
				GL_DBGMSG(0, "gl_formInit: loaded TopMenu '"||gl_topmenu||"'")
			CATCH
				GL_DBGMSG(0, "gl_formInit: Failed to load TopMenu '"||gl_topmenu||"'")
			END TRY
		END IF
	END IF

	CALL gl_titleWin(NULL)

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ set Window image.
#+
#+ @param l_img image name (without extension)
#+ @return none
FUNCTION gl_winImage( l_img STRING ) --{{{
	DEFINE l_win ui.Window

	LET l_win = ui.Window.getCurrent()
	IF l_win IS NULL THEN
		GL_DBGMSG(1, "gl_winImage: No Current Window!")
		RETURN
	END IF
	GL_DBGMSG(3, "gl_winImage: Image set to "||l_img)
    
	CALL ui.interface.setImage( l_img )
	CALL l_win.setImage( l_img )
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Title the application
#+
#+ @param titl title for the window, can be NULL ( defaults to title from Form )
#+ @return none
FUNCTION gl_titleWin( l_titl STRING ) --{{{
	DEFINE l_new STRING
	DEFINE l_win ui.Window
	DEFINE n om.domNode

	LET l_win = ui.Window.getCurrent()
	IF l_win IS NULL THEN
		GL_DBGMSG(1, "gl_titleWin: No Current Window!")
		RETURN
	END IF

	LET n = gl_getFormNode( NULL )
	IF l_titl IS NULL OR l_titl = " " THEN
		IF n IS NOT NULL THEN
			LET l_titl = n.getAttribute("text")
		END IF
		IF ( l_titl IS NULL OR l_titl = " " ) THEN
			LET l_titl = l_win.getText()
		END IF
		IF ( l_titl IS NULL OR l_titl = " " ) THEN
			LET l_titl = gl_progdesc
		ELSE
			IF l_titl.subString(11,11) = ":" THEN LET l_titl = l_titl.subString(12,l_titl.getLength()) END IF
		END IF
-- 01/01/1970:
-- 12345678901
	END IF

	LET l_new = TODAY,":"
	IF gl_progname IS NOT NULL THEN
		LET l_new = l_new.trim()," ",gl_progname.trim()
	END IF
	IF gl_version IS NOT NULL THEN
		LET l_new = l_new.trim()," ",gl_verFmt(gl_version)
	END IF
	IF l_titl IS NOT NULL THEN
		LET l_new = l_new.trim()," - ",l_titl.trim()
	END IF

	GL_DBGMSG(1, "gl_titleWin: new '"||l_new||"'")
	CALL l_win.setText( l_new )
	IF n IS NOT NULL THEN
		CALL n.setAttribute("text",l_new )
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Return the form object for the named form.
#+
#+ @param l_nam name of Form, if null current Form object is returned.
#+ @return ui.Form.
FUNCTION gl_getForm( l_nam STRING ) RETURNS ui.Form --{{{
	DEFINE l_win ui.Window
	DEFINE l_frm ui.Form

	IF l_nam IS NULL THEN
		LET l_win = ui.Window.getCurrent()
		LET l_frm = l_win.getForm()
	ELSE
	-- not written yet!
	END IF

	RETURN l_frm
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Set gl_userName
#+
FUNCTION gl_userName() --{{{
	DEFINE l_un STRING
	IF UPSHIFT(ui.Interface.getFrontEndName()) = "GDC" THEN
		CALL ui.interface.frontCall("standard","getenv","USERNAME",l_un)
		IF l_un IS NULL THEN
			CALL ui.interface.frontCall("standard","getenv","LOGNAME",l_un)
		END IF
		IF l_un IS NULL THEN LET l_un = "unknown" END IF
		LET gl_cli_un = l_un
	END IF
	LET l_un = fgl_getEnv("USERNAME")
	IF l_un.getLength() < 2 THEN
		LET l_un = fgl_getenv("LOGNAME")
	END IF
	IF l_un IS NULL THEN LET l_un = "unknown" END IF
	CALL FGL_SETENV("GL_USERNAME",l_un)
	LET gl_userName = l_un
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Unhide a UI element
#+
#+ @param l_element An element name to unhide.
#+ @return Nothing.
FUNCTION gl_showElement( l_element STRING )
	DEFINE l_f ui.Form
	LET l_f = gl_getForm(NULL)
	CALL l_f.setElementHidden( l_element, FALSE )
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Format revision string
#+
#+ @param ver = String : a cvs revisions string ie : $Revision: 344 $
#+ @return String.
FUNCTION gl_verFmt( l_ver STRING ) RETURNS STRING --{{{
	DEFINE x SMALLINT
	LET x = l_ver.getIndexOf(":",1)
	IF x = 0 THEN
		RETURN l_ver
	ELSE
		RETURN l_ver.subString(X+2, l_ver.getLength() - 1 )
	END IF
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Generic message in statusbar.
#+
#+ @param l_mess   = String: Message text
#+ @return none
FUNCTION gl_message(l_mess STRING) --{{{
	MESSAGE l_mess.trim()
	CALL ui.interface.refresh()
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Generic Windows message Dialog.  NOTE: This handles messages when there is 
#+ no window!
#+
#+ @param l_title     = Window Title
#+ @param l_message   = Message text
#+ @param l_icon      = Icon name, "exclamation"
#+ @return none
FUNCTION gl_winMessage(l_title STRING, l_message STRING, l_icon STRING) --{{{
	DEFINE l_win ui.window
	
	LET l_win = ui.window.getcurrent()
	IF l_win IS NULL THEN -- Needs a current window or dialog doesn't work!!
		OPEN WINDOW dummy AT 1,1 WITH 1 ROWS, 1 COLUMNS
	END IF
	IF l_icon = "exclamation" THEN ERROR "" END IF -- Beep
	MENU l_title ATTRIBUTES(STYLE="dialog",COMMENT=l_message, IMAGE=l_icon)
		COMMAND "Okay" EXIT MENU
	END MENU

	IF l_win IS NULL THEN
		CLOSE WINDOW dummy
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Generic Windows Question Dialog
#+
#+ @param l_title Window Title
#+ @param l_message Message text
#+ @param l_ans   Default Answer
#+ @param l_items List of Answers ie "Yes|No|Cancel"
#+ @param l_icon  Icon name, "exclamation"
#+ @return string: Entered value.
FUNCTION gl_winQuestion(l_title STRING, 
												l_message STRING, 
												l_ans STRING, 
												l_items STRING, 
												l_icon STRING) RETURNS STRING --{{{
	DEFINE l_result STRING
	DEFINE l_toks base.STRINGTOKENIZER
	DEFINE l_dum BOOLEAN
	DEFINE l_opt DYNAMIC ARRAY OF STRING
	DEFINE x SMALLINT

	LET l_icon = l_icon.trim()
	LET l_title = l_title.trim()
	LET l_message = l_message.trim()
	LET l_icon = l_icon.trim()
	IF l_icon = "info" THEN LET l_icon = "information" END IF

	LET l_toks = base.StringTokenizer.create(l_items,"|")
	IF NOT l_toks.hasMoreTokens() THEN RETURN NULL END IF
	WHILE l_toks.hasMoreTokens()
		LET l_opt[ l_opt.getLength() + 1 ] = l_toks.nextToken()
	END WHILE

	-- Handle the case when there is no current window
	LET l_dum = FALSE
	IF ui.window.getCurrent() IS NULL THEN
		OPEN WINDOW dummy AT 1,1 WITH 1 ROWS, 2 COLUMNS ATTRIBUTE(STYLE="naked")
		CALL fgl_settitle(l_title)
		LET l_dum = TRUE
	END IF

	MENU l_title ATTRIBUTE(STYLE="dialog", COMMENT=l_message, IMAGE=l_icon)
		BEFORE MENU
			HIDE OPTION ALL
			FOR x = 1 TO l_opt.getLength()
				IF l_opt[x] IS NOT NULL THEN
					SHOW OPTION l_opt[x]
					IF l_ans.equalsIgnoreCase(l_opt[x]) THEN
						NEXT OPTION l_opt[x]
					END IF
				END IF
			END FOR
		COMMAND l_opt[1]	LET l_result = l_opt[1]
		COMMAND l_opt[2]	LET l_result = l_opt[2]
		COMMAND l_opt[3]	LET l_result = l_opt[3]
		COMMAND l_opt[4]	LET l_result = l_opt[4]
		COMMAND l_opt[5]	LET l_result = l_opt[5]
		COMMAND l_opt[6]	LET l_result = l_opt[6]
		COMMAND l_opt[7]	LET l_result = l_opt[7]
		COMMAND l_opt[8]	LET l_result = l_opt[8]
		COMMAND l_opt[9]	LET l_result = l_opt[9]
		COMMAND l_opt[10]	LET l_result = l_opt[10]
	END MENU
	IF l_dum THEN CLOSE WINDOW dummy END IF
	RETURN l_result
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Default error handler
#+
#+ @return Nothing.
FUNCTION gl_error() --{{{
  DEFINE l_err,l_mod STRING
  DEFINE l_stat INTEGER
  DEFINE x,y SMALLINT

  LET l_stat = STATUS

  LET l_mod = base.Application.getStackTrace()
  LET x = l_mod.getIndexOf("#",2) + 3
  LET y = l_mod.getIndexOf("#",x+1) - 1
  LET l_mod = l_mod.subString(x,y)
  IF y < 1 THEN LET y = l_mod.getLength() END IF
  LET l_mod = l_mod.subString(x,y)
  IF l_mod IS NULL THEN LET l_mod = "(null)" END IF

  LET l_err = SQLERRMESSAGE
  IF l_err IS NULL THEN LET l_err = ERR_GET(l_stat) END IF
  IF l_err IS NULL THEN LET l_err = "Unknown!" END IF
  LET l_err = l_stat||":"||l_err||"\n"||l_mod
--  CALL gl_logIt("Error:"||l_err)
  CALL gl_errPopup(l_err)
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Simple error message
#+
#+ @return Nothing.
FUNCTION gl_warnPopup(l_msg STRING) --{{{
  CALL gl_winMessage(%"Warning!",l_msg,"exclamation")
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Simple error message
#+
#+ @return Nothing.
FUNCTION gl_errPopup(l_msg STRING) --{{{
  CALL gl_winMessage(%"Error!",l_msg,"exclamation")
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Display an error message in a window, console & logfile.
#+
#+ @param l_fil __FILE__ - File name
#+ @param l_lno __LINE__ - Line Number
#+ @param l_err Error Message.
#+ @return Nothing.
FUNCTION gl_errMsg( l_fil STRING, l_lno INT, l_err STRING) --{{{

	CALL gl_errPopup(l_err)
	ERROR "* ",l_err.trim()," *"
	IF l_fil IS NOT NULL THEN
		DISPLAY l_fil.trim(),":",l_lno,": ",l_err.trim()
		CALL errorlog(l_fil.trim()||":"||l_lno||": "||l_err)
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Display debug messages to console.
#+
#+ @param fil __FILE__ - File name
#+ @param lno __LINE__ - Line Number
#+ @param lev Level of debug
#+ @param msg Message
#+ @return Nothing.
FUNCTION gl_dbgMsg( l_fil STRING, l_lno INT, l_lev STRING, l_msg STRING) --{{{
	DEFINE l_lin CHAR(22)
	DEFINE x SMALLINT

	IF gl_dbgLev = 0 AND l_lev = 0 THEN
		DISPLAY gl_progname CLIPPED,":",l_msg.trim()
	ELSE
		IF gl_dbgLev >= l_lev THEN
			LET l_fil = os.path.basename( l_fil )
			LET x = l_fil.getIndexOf(".",1)
			LET l_fil = l_fil.subString(1,x-1)
			LET l_lin = "...............:",l_lno USING "##,###"
			LET x = l_fil.getLength()
			IF x > 22 THEN LET x = 22 END IF
			LET l_lin[1,x] = l_fil.trim()
			DISPLAY l_lin,":",l_lev USING "<<&",": ",l_msg.trim()
			CALL ERRORLOG(l_lin||":"||(l_lev USING "<<&")||": "||l_msg.trim())
		END IF
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Get the product version from the $FGLDIR/etc/fpi-fgl
#+ @param l_prod String of product name, eg: fglrun
#+ @return String or NULL
FUNCTION gl_getProductVer( l_prod STRING ) RETURNS STRING --{{{
	DEFINE l_file base.channel
	DEFINE l_line STRING
	LET l_file = base.channel.create()
	CALL l_file.openPipe( "fpi -l", "r")
	WHILE NOT l_file.isEof()
		LET l_line = l_file.readLine()
		IF l_line.getIndexOf(l_prod, 1) > 0 THEN
			LET l_line = l_line.subString(8,l_line.getLength() - 1 )
			EXIT WHILE
		END IF
	END WHILE
	CALL l_file.close()
	RETURN l_line
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Attempt to convert a String to a date
#+
#+ @param l_str A string containing a date
#+ @returns DATE or NULL
FUNCTION gl_strToDate(l_str STRING) RETURNS DATE --{{{
	DEFINE l_date DATE
	TRY
		LET l_date = l_str
	CATCH
	END TRY
	IF l_date IS NOT NULL THEN RETURN l_date END IF
	LET l_date = util.Date.parse(l_str,"dd/mm/yyyy")
	RETURN l_date
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Return the result from the uname commend on Unix / Linux / Mac.
#+
#+ @return uname of the OS
FUNCTION gl_getUname() RETURNS STRING --{{{
	DEFINE l_uname STRING
	DEFINE c base.channel
	LET c = base.channel.create()
	CALL c.openPipe("uname","r")
	LET l_uname = c.readLine()
	CALL c.close()
	RETURN l_uname
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Return the Linux Version
#+
#+ @return OS Version
FUNCTION gl_getLinuxVer() RETURNS STRING --{{{
	DEFINE l_ver STRING
	DEFINE c base.channel
	DEFINE l_file DYNAMIC ARRAY OF STRING
	DEFINE x SMALLINT

-- possible files containing version info
	LET l_file[ l_file.getLength() + 1 ] = "/etc/issue.net"
	LET l_file[ l_file.getLength() + 1 ] = "/etc/issue"
	LET l_file[ l_file.getLength() + 1 ] = "/etc/debian_version"
	LET l_file[ l_file.getLength() + 1 ] = "/etc/SuSE-release"

-- loop thru and see which ones exist
	FOR x = 1 TO l_file.getLength() + 1
		IF l_file[x] IS NULL THEN RETURN "Unknown" END IF
		IF os.Path.exists(l_file[x]) THEN
			EXIT FOR
		END IF
	END FOR

-- read the first line of existing file
	LET c = base.channel.create()
	CALL c.openFile(l_file[x],"r")
	LET l_ver = c.readLine()
	CALL c.close()
	RETURN l_ver
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Write a message to an audit file.
#+
#+ @param l_mess Message to write to audit file.
FUNCTION gl_logIt( l_mess STRING ) --{{{
	DEFINE l_pid,l_fil STRING
	--DEFINE x,y SMALLINT
	DEFINE c base.Channel
	LET l_pid = fgl_getPID()
	--DISPLAY base.application.getProgramName()||": "||NVL(l_mess,"NULL")
	LET c = base.Channel.create()
	IF m_logDir IS NULL THEN LET m_logDir = gl_getLogDir() END IF
	IF m_logName IS NULL THEN LET m_logName = gl_getLogName() END IF
	LET l_fil = m_logDir||m_logName||".log"
	CALL c.openFile(l_fil,"a")

	LET l_fil = gl_getCallingModuleName()
	IF l_fil MATCHES "cloud_gl_lib.gl_dbgMsg:*" THEN
		LET l_mess = CURRENT||"|"||NVL(l_mess,"NULL")
	ELSE
		LET l_mess = CURRENT||"|"||NVL(l_fil,"NULL")||"|"||l_mess
	END IF
	
	DISPLAY "Log:",l_mess
	CALL c.writeLine(l_mess)

	CALL c.close()
END FUNCTION --}}}
--------------------------------------------------------------------------------
-- double use, 1=set m_logdir for THIS function, 2=set&return logdir to call programming
-- also check for and create the log folder if it doesn't exist.
--	normally not required as it's created during package install.
FUNCTION gl_getLogDir() RETURNS STRING
	LET m_logDir = fgl_getEnv("LOGDIR")
	LET m_logDate = TRUE
	IF fgl_getEnv("LOGFILEDATE") = "false" THEN LET m_logDate = FALSE END IF
	IF m_logDir.getLength() < 1 THEN
		LET m_logDir = "../logs/" -- default logdir
	END IF

	IF NOT os.path.exists( m_logDir ) THEN
		IF NOT os.path.mkdir( m_logDir ) THEN
			CALL gl_errPopup(SFMT(%"Failed to make logdir '%1.\nProgram aborting",m_logDir))
			CALL gl_exitProgram(200,"log dir issues")
		ELSE
			IF NOT os.path.chrwx( m_logDir,  ( (7 *64) + (7 * 8) + 5 )  ) THEN
				CALL gl_errPopup(SFMT(%"Failed set permissions on logdir '%1'",m_logDir))
				CALL gl_exitProgram(201,"log permissions")
			END IF
		END IF
	END IF
	IF NOT os.path.isDirectory( m_logDir ) THEN
		CALL gl_errPopup(SFMT(%"Logdir '%1' not a directory.\nProgram aborting",m_logDir))
		CALL gl_exitProgram(202,"logdir not a dir")
	END IF

# Make sure the logdir ends with a slash.
	IF m_logDir.getCharAt( m_logDir.getLength() ) != os.path.separator() THEN
		LET m_logDir = m_logDir.append( os.path.separator() )
	END IF
	RETURN m_logDir
END FUNCTION
--------------------------------------------------------------------------------
-- get / set m_logName 
-- NOTE: doesn't include the extension so you can use it for .log and .err
FUNCTION gl_getLogName() RETURNS STRING
	DEFINE l_user STRING
	IF m_logName IS NULL THEN
		LET l_user = fgl_getEnv("LOGNAME") -- get OS user
		IF l_user.getLength() < 2 THEN
			LET l_user = fgl_getEnv("USERNAME") -- get OS user
		END IF
		IF l_user.getLength() < 2 THEN
			LET l_user = "unknown"
		END IF
		--LET m_logName = (TODAY USING "YYYYMMDD")||"-"||base.application.getProgramName()
		IF m_logDate THEN
			LET m_logName = base.application.getProgramName()||"-"||(TODAY USING "YYYYMMDD")||"-"||l_user
		ELSE
			LET m_logName = base.application.getProgramName()
		END IF
	END IF
	RETURN m_logName
END FUNCTION
--------------------------------------------------------------------------------
#+ Gets sourcefile.module:line from a stacktrace.
#+
FUNCTION gl_getCallingModuleName() RETURNS STRING --{{{
	DEFINE l_fil,l_mod,l_lin STRING
	DEFINE x,y SMALLINT
	LET l_fil = base.Application.getStackTrace()
	IF l_fil IS NULL THEN
		DISPLAY "Failed to get getStackTrace!!"
		RETURN "getStackTrace-failed"
	END IF
	--DISPLAY "getCallingModuleName ST:",l_fil
	LET x = l_fil.getIndexOf("#",2) -- skip passed this func
	LET x = l_fil.getIndexOf("#",x+1) -- skip passed func that called this func
	LET x = l_fil.getIndexOf(" ",x) + 1
	LET y = l_fil.getIndexOf("(",x) - 1
	LET l_mod = l_fil.subString(x,y)

	LET x = l_fil.getIndexOf(" ",y) + 4
	LET y = l_fil.getIndexOf("#",x+1) - 2
	IF y < 1 THEN LET y = (l_fil.getLength() - 1) END IF
	LET l_fil = l_fil.subString(x,y)

	-- strip the .4gl from the fil name
	LET x = l_fil.getIndexOf(".",1)
	IF x > 0 THEN
		LET y = l_fil.getIndexOf(":",x)
		LET l_lin = l_fil.subString(y,l_fil.getLength())
		LET l_fil = l_fil.subString(1,x-1)
	END IF
	--DISPLAY "Fil:",l_fil," Mod:",l_mod," Line:",l_lin
	LET l_fil = NVL(l_fil,"FILE?")||"."||NVL(l_mod,"MOD?")||":"||NVL(l_lin,"LINE?")
	RETURN l_fil
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Splash screen
#+
#+ @param l_dur > 0 for sleep then close, 0=just open window, -1=close window
#+ @return Nothing.
FUNCTION gl_splash(l_dur SMALLINT) --{{{
	DEFINE f,g,n om.DomNode

	IF gl_fe_typ = "GBC" THEN RETURN END IF

	IF l_dur = -1 THEN
		CLOSE WINDOW splash
		RETURN
	END IF

	OPEN WINDOW splash AT 1,1 WITH 1 ROWS,1 COLUMNS ATTRIBUTE(STYLE="default noborder dialog2 bg_white")
	LET f = gl_genForm("splash")
	LET g = f.createChild("Grid")
	LET n = g.createChild("Image")
	CALL n.setAttribute("name","logo" )
	CALL n.setAttribute("style","noborder" )
	CALL n.setAttribute("width","36" )
	CALL n.setAttribute("height","8" )
	CALL n.setAttribute("image",gl_splash )
	CALL n.setAttribute("posY","0" )
	CALL n.setAttribute("posX","0" )
	CALL n.setAttribute("gridWidth","40" )
	CALL n.setAttribute("gridHeight","8")
	CALL n.setAttribute("height","200px" )
	CALL n.setAttribute("width", "570px" )
	CALL n.setAttribute("stretch","both" )
	CALL n.setAttribute("autoScale","1" )
	CALL ui.interface.refresh()

	IF l_dur > 0 THEN
		SLEEP l_dur
		CLOSE WINDOW splash
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Dynamic About Window
#+
#+ @param l_ver a version string
#+ @return Nothing.
FUNCTION gl_about(l_ver STRING) --{{{
	DEFINE f,n,g,w om.DomNode
	DEFINE nl om.nodeList
	DEFINE gver, servername, info, txt STRING
	DEFINE y SMALLINT

	IF os.Path.pathSeparator() = ";" THEN -- Windows
		LET servername = fgl_getEnv("COMPUTERNAME")
	ELSE -- Unix / Linux / Mac / Android
		LET servername = fgl_getEnv("HOSTNAME")
	END IF
	LET gver = "build ",fgl_getVersion()

	IF gl_cli_os = "?" THEN
		CALL ui.interface.frontcall("standard","feinfo",[ "ostype" ], [ gl_cli_os ] )
		CALL ui.interface.frontcall("standard","feinfo",[ "osversion" ], [ gl_cli_osver ] )
		CALL ui.interface.frontCall("standard","feinfo",[ "screenresolution" ], [ gl_cli_res ])
		CALL ui.interface.frontCall("standard","feinfo",[ "fepath" ], [ gl_cli_dir ])
	END IF

	IF gl_app_name IS NULL THEN CALL gl_setAppInfo( NULL, NULL ) END IF

	OPEN WINDOW about AT 1,1 WITH 1 ROWS, 1 COLUMNS ATTRIBUTE(STYLE="naked")
	LET n = gl_getWinNode(NULL)
	CALL n.setAttribute("text",gl_progdesc)
	LET f = gl_genForm("about")
	LET n = f.createChild("VBox")
	CALL n.setAttribute("posY","0" )
	CALL n.setAttribute("posX","0" )

	IF gl_splash IS NOT NULL AND gl_splash != " " THEN
		LET g = n.createChild("HBox")
		CALL g.setAttribute("posY",y)
		CALL g.setAttribute("gridWidth",36)
		LET w = g.createChild("SpacerItem")

		LET w = g.createChild("Image")
		CALL w.setAttribute("posY","0" )
		CALL w.setAttribute("posX","0" )
		CALL w.setAttribute("name","logo" )
		CALL w.setAttribute("style","noborder")
		CALL w.setAttribute("stretch","both" )
		CALL w.setAttribute("autoScale","1" )
		CALL w.setAttribute("gridWidth","12" )
		CALL w.setAttribute("image",gl_splash )
		CALL w.setAttribute("height","100px" )
		CALL w.setAttribute("width", "290px" )

		LET w = g.createChild("SpacerItem")
		LET y = 10
	ELSE
		LET y = 1
	END IF

	LET g = n.createChild("Group")
	CALL g.setAttribute("text","About")
	CALL g.setAttribute("posY","10" )
	CALL g.setAttribute("posX","0" )
	CALL g.setAttribute("style","about")

	IF gl_app_build IS NOT NULL THEN
		CALL gl_addLabel(g, 0,y,LSTR("Application"),"right","black")
		CALL gl_addLabel(g,10,y,gl_app_name||" - "||gl_app_build,NULL,NULL) LET y = y + 1
	END IF

	CALL gl_addLabel(g, 0,y,LSTR("Program")||":","right","black")
	CALL gl_addLabel(g,10,y,gl_progname||" - "||l_ver,NULL,"black") LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("Description")||":","right","black")
	CALL gl_addLabel(g,10,y,gl_progdesc,NULL,"black") LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("Author")||":","right","black")
	CALL gl_addLabel(g,10,y,gl_progauth,NULL,"black") LET y = y + 1

	LET w = g.createChild("HLine")
	CALL w.setAttribute("posY",y) LET y = y + 1
	CALL w.setAttribute("posX",0)
	CALL w.setAttribute("gridWidth",25)

	CALL gl_addLabel(g, 0,y,LSTR("Genero Runtime")||":","right","black")
	CALL gl_addLabel(g,10,y,gver,NULL,"black") LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("Server OS")||":","right","black")
	CALL gl_addLabel(g,10,y,gl_os,NULL,"black") LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("Server Name")||":","right","black")
	CALL gl_addLabel(g,10,y,servername,NULL,"black") LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("OS User")||":","right","black")
	CALL gl_addLabel(g,10,y,gl_userName,NULL,"black") LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("Server Time:")||":","right","black")
	CALL gl_addLabel(g,10,y,TODAY||" "||TIME,NULL,"black") LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("Database Name")||":","right","black")
	CALL gl_addLabel(g,10,y,fgl_getEnv("DBNAME"),NULL,NULL) LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("Database Type")||":","right","black")
	CALL gl_addLabel(g,10,y,UPSHIFT( fgl_db_driver_type() ),NULL,"black") LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("DBDATE")||":","right","black")
	CALL gl_addLabel(g,10,y,fgl_getEnv("DBDATE"),NULL,"black") LET y = y + 1

	LET w = g.createChild("HLine")
	CALL w.setAttribute("posY",y) LET y = y + 1
	CALL w.setAttribute("posX",0)
	CALL w.setAttribute("gridWidth",25)

	CALL gl_addLabel(g, 0,y,LSTR("Client OS")||":","right","black")
	CALL gl_addLabel(g,10,y,gl_cli_os||" / "||gl_cli_osver,NULL,"black") LET y = y + 1

	CALL gl_addLabel(g, 0,y,LSTR("Clint OS User")||":","right","black")
	CALL gl_addLabel(g,10,y,gl_cli_un,NULL,"black") LET y = y + 1

	IF m_user_agent.getLength() > 1 THEN
		CALL gl_addLabel(g, 0,y,LSTR("User Agent")||":","right","black")
		CALL gl_addLabel(g,10,y,m_user_agent,NULL,"black") LET y = y + 1
	END IF

	CALL gl_addLabel(g, 0,y,LSTR("FrontEnd Version")||":","right","black")
	CALL gl_addLabel(g,10,y,gl_fe_typ||" "||gl_fe_ver,NULL,"black") LET y = y + 1

	IF gl_cli_dir.getLength() > 1 THEN
		CALL gl_addLabel(g, 0,y,LSTR("Client Directory")||":","right","black")
		CALL gl_addLabel(g,10,y,gl_cli_dir,NULL,"black") LET y = y + 1
	END IF

	CALL gl_addLabel(g, 0,y,LSTR("Client Resolution")||":","right","black")
	CALL gl_addLabel(g,10,y,gl_cli_res,NULL,"black") LET y = y + 1

	LET g = g.createChild("HBox")
	CALL g.setAttribute("posY",y)
	CALL g.setAttribute("gridWidth",40)
	LET w = g.createChild("SpacerItem")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","Copy to Clipboard")
	CALL w.setAttribute("name","copyabout")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","Show Env")
	CALL w.setAttribute("name","showenv")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","Show License")
	CALL w.setAttribute("name","showlicence")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","ReadMe")
	CALL w.setAttribute("name","showreadme")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","Close")
	CALL w.setAttribute("name","closeabout")
	LET w = g.createChild("SpacerItem")

	LET nl = f.selectByTagName("Label")
	FOR y = 1 TO nl.getLength()
		LET w = nl.item( y )
		LET txt = w.getAttribute("text")
		IF txt IS NULL THEN LET txt = "(null)" END IF
		LET info = info.append( txt )
		IF NOT y MOD 2 THEN
			LET info = info.append( "\n" )
		END IF
	END FOR

	MENU "Options"
		ON ACTION close	EXIT MENU
		ON ACTION closeabout	EXIT MENU
		ON ACTION showenv CALL gl_showEnv()
		ON ACTION showreadme CALL gl_showReadMe()
		ON ACTION copyabout 
			CALL ui.interface.frontCall("standard","cbset",info,y )
		ON ACTION showlicence
			CALL gl_showlicence()
	END MENU
	CLOSE WINDOW about

END FUNCTION --}}}