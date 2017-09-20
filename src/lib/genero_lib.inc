&define GL_DBGMSG( lev, msg ) \
	CALL gl_dbgMsg( __FILE__, __LINE__, lev, NVL(msg,"NULL!")) \

&define GL_MODULE_ERROR_HANDLER   WHENEVER ANY ERROR CALL gl_error

&define GL_ABOUT ON ACTION about CALL gl_lib.gl_about( C_VER )
