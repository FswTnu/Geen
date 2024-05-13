#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} M460MARK
Ponto de entrada para validar a marca��o do pedido para faturamento, n�o fatura pedidos com bloqueio
@author Rafael Domingues
@since 12.12.2022
/*/
User Function  M460MARK()
	Local aArea	:= GetArea()	
	Local lRet	:= .T.

	DbSelectArea('SC5')
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SC9->C9_PEDIDO))

//	If Alltrim(SC5->C5_XSTATUS) == "X"
//		MsgAlert( "Cliente com bloqueio. O pedido n�o pode ser faturado!")
//		lRet := .F.
//	EndIf

//	RestArea(aArea)
Return .T.
