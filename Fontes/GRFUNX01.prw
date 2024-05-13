#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GRFUNX01
Função de envio de email
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
User Function GRFUNX01(_cTitulo, _cMensagem, _cPara)
	Local aArea		As Array
	Local nRet		As Numerical
	Local oServer	As Object
	Local oMessage	As Object
	Local cSMTPAddr As Character
	Local cSMTPPort As Character
	Local cUser     As Character
	Local cPass     As Character
	Local nSMTPTime As Numerical
	Local lSsl		As Logical
	Local lTls		As Logical
	Local lAuth		As Logical
	Local nX		As Numerical
	Local lTeste	As Logical
	Local cMailTst	As Character

	aArea		:= GetArea()
	nRet		:= 0
	oServer		:= Nil
	oMessage	:= Nil
	cFrom 		:= SuperGetMV( "MV_RELFROM"	, Nil, "smtp.office365.com" ) //"rafael@webmr.com.br"
	cSMTPAddr 	:= SuperGetMV( "MV_RELSERV"	, Nil, "smtp.office365.com" ) //"smtp.webmr.com.br"
	cSMTPPort 	:= SuperGetMV( "MV_RELPORT"	, Nil, "587" ) //"587"
	cUser     	:= SuperGetMV( "MV_RELACNT"	, Nil, "wf_protheus@inovalli.com.br" ) //"rafael@webmr.com.br"
	cPass     	:= SuperGetMV( "MV_RELPSW"	, Nil, "Bob16605" ) //"jMxLMM12h6Kn"
	nSMTPTime 	:= SuperGetMV( "MV_RELTIME"	, Nil, 120 ) //120
	lSsl		:= SuperGetMV( "MV_RELSSL"	, Nil, .T. ) //.T.
	lTls		:= SuperGetMV( "MV_RELTLS "	, Nil, .T. ) //.T.
	lAuth		:= SuperGetMV( "MV_RELAUTH"	, Nil, .T. ) //.T.
	nX			:= 0
	lTeste		:= SuperGetMV( "EM_TSTMAIL"	, Nil, .F. ) //.T.
	cMailTst	:= SuperGetMV( "EM_MAILTST"	, Nil, "rafael.domingues@tnuservicos.com.br" )

	If lTeste
		_cPara := AllTrim(cMailTst)
	EndIf

	cSMTPAddr := Substr(AllTrim(cSMTPAddr),1,At(":",AllTrim(cSMTPAddr))-1)

	oServer := TMailManager():New()
	oServer:SetUseTLS( lTls )
	oServer:SetUseSSL( lSsl )

	nRet := oServer:init('', cSMTPAddr, cUser, cPass, 0, Val(cSMTPPort))
	If nRet != 0
		cMsg := "Erro de inicialização SMTP server: " + oServer:GetErrorString( nRet )
		FwLogMsg("INFO",,"EMAIL",FunName(),"","01",cMsg,0,0,{})
		RestArea(aArea)
		FWFreeArray(aArea)
		FreeObj(oServer)
		FreeObj(oMessage)
		Return(.F.)
	EndIf

	// the method set the timout for the SMTP server
	nRet := oServer:SetSMTPTimeout( nSMTPTime )
	If nRet != 0
		cMsg := "Erro set SMTP timeout to " + cValToChar( nSMTPTime )
		FwLogMsg("INFO",,"EMAIL",FunName(),"","01",cMsg,0,0,{})
		RestArea(aArea)
		FWFreeArray(aArea)
		FreeObj(oServer)
		FreeObj(oMessage)
		Return(.F.)
	EndIf

	// estabilish the connection with the SMTP server
	nRet := oServer:SMTPConnect()
	If nRet <> 0
		cMsg := "Erro de conexão SMTP server: " + oServer:GetErrorString( nRet )
		FwLogMsg("INFO",,"EMAIL",FunName(),"","01",cMsg,0,0,{})
		RestArea(aArea)
		FWFreeArray(aArea)
		FreeObj(oServer)
		FreeObj(oMessage)
		Return(.F.)
	EndIf

	// authenticate on the SMTP server (If needed)
	If lAuth
		nRet := oServer:SmtpAuth( cUser, cPass )
		If nRet <> 0
			cMsg := "Erro de autenticação SMTP server: " + oServer:GetErrorString( nRet )
			FwLogMsg("INFO",,"EMAIL",FunName(),"","01",cMsg,0,0,{})
			oServer:SMTPDisconnect()
			RestArea(aArea)
			FWFreeArray(aArea)
			FreeObj(oServer)
			FreeObj(oMessage)
			Return(.F.)
		EndIf
	EndIf

	oMessage := TMailMessage():New()
	oMessage:Clear()

	oMessage:cDate 		:= cValToChar( Date() )
	oMessage:cFrom 		:= cFrom
	oMessage:cTo 		:= _cPara
	oMessage:cSubject 	:= _cTitulo
	oMessage:cBody 		:= _cMensagem

	nRet := oMessage:Send( oServer )
	If nRet <> 0
		cMsg := "Erro o enviar e-mail: " + oServer:GetErrorString( nRet )
		FwLogMsg("INFO",,"EMAIL",FunName(),"","01",cMsg,0,0,{})
		RestArea(aArea)
		FWFreeArray(aArea)
		FreeObj(oServer)
		FreeObj(oMessage)
		Return(.F.)
	EndIf

	nRet := oServer:SMTPDisconnect()
	If nRet <> 0
		cMsg := "Erro ao desconectar SMTP server: " + oServer:GetErrorString( nRet )
		FwLogMsg("INFO",,"EMAIL",FunName(),"","01",cMsg,0,0,{})
		RestArea(aArea)
		FWFreeArray(aArea)
		FreeObj(oServer)
		FreeObj(oMessage)
		Return(.F.)
	EndIf

	RestArea(aArea)
	FWFreeArray(aArea)
	FreeObj(oServer)
	FreeObj(oMessage)
Return(.T.)

/*/{Protheus.doc} TSTMAIL
Teste de envio de email
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
User Function TSTMAIL()
	Local _cTitulo 		:= "teste"
	Local _cMensagem 	:= "teste"
	Local _cPara 		:= "rdoliveira.xico@gmail.com"

	If Select("SX6") == 0
		RpcSetenv("02","01")
	EndIf

	lRet := U_GRFUNX01(_cTitulo, _cMensagem, _cPara)
Return
