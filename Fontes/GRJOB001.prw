#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

/*/{Protheus.doc} GRJOB001
Integracao Agrometrika X Protheus
GET Cliente -> Schedule
@author Rafael Domingues - TNU
@since 16.09.2023
/*/
User Function GRJOB001()
	Local cServer   	:= ""
	Local cResource 	:= ""
	Local oRest     	:= Nil
	Local aHeader   	:= {}
	Local cJson 		:= ""
	Local oJsonRes 		:= ""
	Local cToken 		:= ""
	Local lJob			:= Select( "SX6" ) == 0
	Local cJobEmp		:= '02'
	Local cJobFil		:= '0101'
	Local cQry			:= ""
	Local cAliasA		:= GetNextAlias()
	Local aSA1Auto  	:= {}
	Local nErr			:= 0
	Local nValGaran		:= 0
	Local nV			:= 0

	Private lMsErroAuto		:= .F.
	Private lMsHelpAuto		:= .T.
	Private lAutoErrNoFile 	:= .T.
	Private aErro 		:= {}

	If lJob
		RpcSetEnv( cJobEmp, cJobFil )
	EndIf

	cServer	:= SuperGetMv("ES_SERVER" 	,.F.,"https://homologacao.agrometrikaweb.com.br")
	cToken	:= U_GRWS0001()

	If Empty(cToken)
		ConOut("Token indisponivel")
		Return
	EndIf

	AAdd(aHeader, "Content-Type: application/json")
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "X-Authentication-Token: "+cToken)

	cQry := " SELECT R_E_C_N_O_ AS RECSA1 FROM "+RetSqlName("SA1")+" WHERE D_E_L_E_T_ <> '*' "
	cQry += " AND A1_COD = '001080' AND A1_LOJA = '01' "
	//cQry += " AND A1_COD IN ('000393','001080','000079','000797') "
	//cQry += " AND A1_CGC = '10843685000191' "
	cQry := ChangeQuery(cQry)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAliasA, .F., .T.)

	(cAliasA)->(DbGoTop())
	While (cAliasA)->(!Eof())
		SA1->(DbGoTo((cAliasA)->RECSA1))

		aSA1Auto := {}
		aAdd(aSA1Auto,{"A1_COD"		,SA1->A1_COD								,Nil})
		aAdd(aSA1Auto,{"A1_LOJA"	,SA1->A1_LOJA								,Nil})
		aAdd(aSA1Auto,{"A1_NOME"	,SA1->A1_NOME								,Nil})
		aAdd(aSA1Auto,{"A1_END"		,SA1->A1_END								,Nil})
		aAdd(aSA1Auto,{"A1_NREDUZ"	,SA1->A1_NREDUZ								,Nil})
		aAdd(aSA1Auto,{"A1_TIPO"	,SA1->A1_TIPO								,Nil})
		aAdd(aSA1Auto,{"A1_EST"		,SA1->A1_EST								,Nil})
		aAdd(aSA1Auto,{"A1_MUN"		,SA1->A1_MUN								,Nil})

		cResource 	:= SuperGetMv("ES_RECLI" 	,.F.,"/HomologApiv2/Cliente/")
		oRest     	:= FwRest():New(cServer)
		oJsonRes 	:= JsonObject():new()

		cResAux := ""
		cResAux += AllTrim(SA1->A1_CGC)

		oRest:SetPath(cResource+cResAux)

		If oRest:Get(aHeader)
			cJson := oRest:GetResult()
			If FWJsonDeserialize( cJson, @oJsonRes )
				If Len(oJsonRes:errosrequisicao) == 0
					aAdd(aSA1Auto,{"A1_XSEGURA"	,Iif(oJsonRes:DadosCliente:valorLimiteSeguro==Nil,0,oJsonRes:DadosCliente:valorLimiteSeguro)			,Nil})

				EndIf
			EndIf
		EndIf

		cResource 	:= SuperGetMv("ES_RELIM" 	,.F.,"/HomologApiv2/Cliente/Limite/")
		oRest     	:= FwRest():New(cServer)
		oJsonRes 	:= JsonObject():new()

		cResAux := ""
		cResAux += AllTrim(SA1->A1_CGC)

		oRest:SetPath(cResource+cResAux)

		If oRest:Get(aHeader)
			cJson := oRest:GetResult()
			If FWJsonDeserialize( cJson, @oJsonRes )
				If Len(oJsonRes:errosrequisicao) == 0
					nLc := Iif(oJsonRes:LimiteCliente:valLimiteClean==Nil,0,oJsonRes:LimiteCliente:valLimiteClean)
					dVencLc := Iif(oJsonRes:LimiteCliente:datVigencia==Nil,CtoD("  /  /  "),StoD(StrTran(SubStr(oJsonRes:LimiteCliente:datVigencia,1,10),"-")))

					aAdd(aSA1Auto,{"A1_LC"		,Iif(oJsonRes:LimiteCliente:valLimiteClean==Nil,0,oJsonRes:LimiteCliente:valLimiteClean)		,Nil})
					aAdd(aSA1Auto,{"A1_VENCLC"	,Iif(oJsonRes:LimiteCliente:datVigencia==Nil,"",StoD(StrTran(SubStr(oJsonRes:LimiteCliente:datVigencia,1,10),"-")))			,Nil})
					aAdd(aSA1Auto,{"A1_XLCCRAP"	,Iif(oJsonRes:LimiteCliente:valLimite==Nil,0,oJsonRes:LimiteCliente:valLimite)			,Nil})
					//aAdd(aSA1Auto,{"A1_LCFIN"	,Iif(oJsonRes:LimiteCliente:valLimiteClean==Nil,0,oJsonRes:LimiteCliente:valLimiteClean)		,Nil})
					//aAdd(aSA1Auto,{"A1_LCFIN"	,Iif(oJsonRes:LimiteCliente:ValAprovado==Nil,0,oJsonRes:LimiteCliente:ValAprovado)		,Nil})
					//aAdd(aSA1Auto,{"A1_XRTNG"	,Iif(oJsonRes:LimiteCliente:ConceitoAtual==Nil,"",oJsonRes:LimiteCliente:ConceitoAtual)				,Nil})
				EndIf
			EndIf
		EndIf

		cResource 	:= SuperGetMv("ES_REGAR" 	,.F.,"/HomologApiv2/Cliente/Garantias/")
		oRest     	:= FwRest():New(cServer)
		oJsonRes 	:= JsonObject():new()

		cResAux := ""
		cResAux += AllTrim(SA1->A1_COD)

		oRest:SetPath(cResource+cResAux)

		If oRest:Get(aHeader)
			cJson := oRest:GetResult()
			If FWJsonDeserialize( cJson, @oJsonRes )
				If Len(oJsonRes:errosrequisicao) == 0 .And. Len(oJsonRes:garantias) > 0
					aAdd(aSA1Auto,{"A1_XRTNG"	,Iif(oJsonRes:Garantias[1]:codTipoGarantia==Nil,"",oJsonRes:Garantias[1]:codTipoGarantia)				,Nil})
					aAdd(aSA1Auto,{"A1_XVLDGRT"	,Iif(oJsonRes:Garantias[1]:datValidade==Nil,"",StoD(StrTran(SubStr(oJsonRes:Garantias[1]:datValidade,1,10),"-")))			,Nil})
					aAdd(aSA1Auto,{"A1_XTPGRNT"	,Iif(oJsonRes:Garantias[1]:codTipoGarantia==Nil,"",oJsonRes:Garantias[1]:codTipoGarantia)		,Nil})
					aAdd(aSA1Auto,{"A1_XSTGRNT"	,Iif(oJsonRes:Garantias[1]:codEstadoGarantia==Nil,"",AllTrim(Str(oJsonRes:Garantias[1]:codEstadoGarantia))) 	,Nil})

					For nV := 1 To Len( oJsonRes:Garantias )
						nValGaran += Iif(oJsonRes:Garantias[nV]:valGarantia==Nil,0,oJsonRes:Garantias[nV]:valGarantia)
					Next nV

					aAdd(aSA1Auto,{"A1_LCFIN"	, nValGaran	,Nil})
				EndIf
			EndIf
		EndIf

		lMsErroAuto := .F.

		MSExecAuto({|_x, _y| CRMA980(_x, _y)}, aSA1Auto, 4)

		If lMsErroAuto
			aErro := GetAutoGrLog()

			For nErr := 1 To Len(aErro)
				If At("Invalido",aErro[nErr])
					cErr := aErro[nErr]
					Exit
				EndIf
			Next nErr
		Else
			SA1->(RecLock("SA1",.F.))
			SA1->A1_LC := nLc
			SA1->A1_VENCLC := dVencLc
			SA1->(MsUnLock())

			DbSelectArea("ZZ2")
			ZZ2->(RecLock("ZZ2",.T.))
			ZZ2->ZZ2_CGC 	:= SA1->A1_CGC
			ZZ2->ZZ2_COD 	:= SA1->A1_COD
			ZZ2->ZZ2_LOJA 	:= SA1->A1_LOJA
			ZZ2->ZZ2_LC 	:= SA1->A1_LC
			ZZ2->ZZ2_LCFIN 	:= SA1->A1_LCFIN
			ZZ2->ZZ2_NOME 	:= SA1->A1_NOME
			ZZ2->ZZ2_VENCLC := SA1->A1_VENCLC
			ZZ2->(MsUnLock())
		EndIf

		(cAliasA)->(DbSkip())
	End
	(cAliasA)->(DbCloseArea())
Return
