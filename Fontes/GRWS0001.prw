#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

/*/{Protheus.doc} GRWS0001
Integracao Agrometrika - autenticação
@author Rafael Domingues - TNU
@since 16.09.2023
/*/
User Function GRWS0001()
	Local cServer   	As Character
	Local cResource 	As Character
	Local oRest     	As Object
	Local aHeader   	As Array
	Local cJson 		As Character
	Local cApiId 		As Character
	Local cApiChv 		As Character
	Local oJsonRes 		As Character
	Local cRet 			As Character
	Local lJob			:= Select( "SX6" ) == 0
	Local cJobEmp		:= '02'
	Local cJobFil		:= '0101'

	If lJob
		RpcSetEnv( cJobEmp, cJobFil )
	EndIf

	cServer   	:= SuperGetMv("ES_SERVER" 	,.F.,"https://homologacao.agrometrikaweb.com.br" )
	cResource 	:= SuperGetMv("ES_RESLOG" 	,.F.,"/HomologApiv2/Autenticacao" )
	oRest     	:= FwRest():New(cServer)
	aHeader   	:= {}
	cJson 		:= ""
	cApiId 		:= SuperGetMv("ES_APIID" 	,.F.,"a622bd86-df0a-4856-b8e7-ad2c82063317" )
	cApiChv 	:= SuperGetMv("ES_APICHV" 	,.F.,"f32PZMxQnfjNjz3rxX6QZ8EnWxwTMMIIPMjh2iC6xUR2wBa3japyO2phzO3CqNe" )
	oJsonRes	:= JsonObject():new()
	cRet		:= ""

	AAdd(aHeader, "Content-Type: application/json")
	oRest:SetPath(cResource)

	cJson := '{'
	cJson += '	"ID": "'+AllTrim(cApiId)+'",'
	cJson += '	"Chave": "'+AllTrim(cApiChv)+'"'
	cJson += '}'

	oRest:SetPostParams(cJson)

	If oRest:Post(aHeader)
		cJson := oRest:GetResult()
		If FWJsonDeserialize( cJson, @oJsonRes )
			If oJsonRes:Autenticado
				Conout(oJsonRes:Token)
				cRet := oJsonRes:Token
			Else
				Conout("Erro autenticação")
			EndIf
		Else
			Conout("Não foi possivel desearilizar o retorno")
		EndIf
	EndIf
	FreeObj(oRest)
	FreeObj(oJsonRes)
Return(cRet)
