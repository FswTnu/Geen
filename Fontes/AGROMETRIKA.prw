#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} AGROMETR
Ponto de Entrada do Cadastro de Clientes (MVC) - alteração -> Integração Green
@author Rafael Domingues - TNU
@since 16.09.2023
/*/
User Function AGROMETR()
	Local aArea		:= GetArea()
	Local aParam	:= PARAMIXB
	Local oObj		:= ""
	Local cIdPonto	:= ""
	Local cIdModel	:= ""
	Local cServer	:= SuperGetMv("ES_SERVER" 	,.F.,"https://homologacao.agrometrikaweb.com.br")
	Local cResource := SuperGetMv("ES_RESCLI" 	,.F.,"/HomologApiv2/Cliente")
	Local oRest		:= Nil
	Local aHeader	:= {}
	Local cJson		:= ""
	Local oJsonRes	:= Nil
	Local cToken	:= ""
	Local xRet 		:= .T.
	Local nX		:= 0
	Local cMsg		:= ""

	If aParam <> NIL
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]
		nOperation 	:= oObj:GetOperation()

		If cIdPonto == "MODELCOMMITNTTS"
			If nOperation == 3 .Or. nOperation == 4
				cToken	:= U_GRWS0001()

				AAdd(aHeader, "Content-Type: application/json")
				AAdd(aHeader, "Accept: application/json")
				AAdd(aHeader, "X-Authentication-Token: "+cToken)

				//Cria Funcao REST
				oRest    	:= FwRest():New(cServer)
				oJsonRes 	:= JsonObject():new()
				oRest:SetPath(cResource)

				cJson := '{'
				cJson += '	"nomCliente": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_NOME"))+'",'
				cJson += '	"nomFantasia": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_NREDUZ"))+'",'
				If AllTrim(oObj:GetValue("SA1MASTER","A1_PESSOA")) == "F"
					cJson += '	"numCPF": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_CGC"))+'",'
				Else
					cJson += '	"numCNPJ": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_CGC"))+'",'
				EndIf

				If AllTrim(oObj:GetValue("SA1MASTER","A1_TIPO")) == "L"
					cJson += '  "codTipoCliente": 8,'
				Else
					cJson += '  "codTipoCliente": 10,'
				EndIf

				cJson += '	"codClienteERP": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_COD"))+'",'
				If Empty(oObj:GetValue("SA1MASTER","A1_DTINIV"))
					cJson += '  "datClienteDesde": "null",'
				Else
					cJson += '  "datClienteDesde": "'+Substr(DtoS(oObj:GetValue("SA1MASTER","A1_DTINIV")),1,4)+"-"+Substr(DtoS(oObj:GetValue("SA1MASTER","A1_DTINIV")),5,2)+"-"+Substr(DtoS(oObj:GetValue("SA1MASTER","A1_DTINIV")),7,2)+'",'
				EndIf
				If Empty(oObj:GetValue("SA1MASTER","A1_DTNASC"))
					cJson += '	"datConstituicao": "null",'
				Else
					cJson += '	"datConstituicao": "'+Substr(DtoS(oObj:GetValue("SA1MASTER","A1_DTNASC")),1,4)+"-"+Substr(DtoS(oObj:GetValue("SA1MASTER","A1_DTNASC")),5,2)+"-"+Substr(DtoS(oObj:GetValue("SA1MASTER","A1_DTNASC")),7,2)+'",'
				EndIf
				cJson += '	"valInscricaoEstadual": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_INSCR"))+'",'
				If Empty(oObj:GetValue("SA1MASTER","A1_CONTRIB"))
					cJson += '	"flgOptanteSimples": "null",'
				Else
					cJson += '	"flgOptanteSimples": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_CONTRIB"))+'",'
				EndIf
				cJson += '	"valCEP": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_CEP"))+'",'
				cJson += '	"desUF": "'+AllTrim(AllTrim(oObj:GetValue("SA1MASTER","A1_EST")))+'",'
				cJson += '	"desEndereco": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_END"))+'",'
				cJson += '	"desBairro": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_BAIRRO"))+'",'
				cJson += '	"desMunicipio": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_MUN"))+'",'
				cJson += '	"valFone": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_DDD"))+AllTrim(oObj:GetValue("SA1MASTER","A1_TEL"))+'",'
				cJson += '	"desEmail": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_EMAIL"))+'",'
				cJson += '	"Contato": "'+AllTrim(oObj:GetValue("SA1MASTER","A1_CONTATO"))+'"'
				cJson += '}'

				cJson := EncodeUtf8(cJson)

				oRest:SetPostParams(cJson)
				If oRest:Post(aHeader)
					cJson := oRest:GetResult()
					If FWJsonDeserialize( cJson, @oJsonRes )
						If oJsonRes:Salvo
							MsgInfo("Integrado com a Agrometrika com sucesso!")
						Else
							For nX := 1 To Len(oJsonRes["errosRequisicao"])
								cMsg += oJsonRes["errosRequisicao"][nX]["descricaoErro"] +CHR(13)+CHR(10)
							Next nX

							MsgInfo("Erro na integracao com a Agrometrika! "+cMsg)
						EndIf
					Else
						MsgInfo("Não foi possivel desearilizar o retorno")
					EndIf
				Else
					MsgInfo("Não passou pela integração com a Agrometrika!")
				EndIf

				//Elimina da memória a instância do objeto informado como parâmetro.
				FreeObj(oRest)
				FreeObj(oJsonRes)
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return xRet
