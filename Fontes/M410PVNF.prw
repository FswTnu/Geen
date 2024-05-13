#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} M410PVNF
Ponto de entrada - Valida��o na chamada do Prep Doc Sa�da no A��es Relacionadas do Pedido de Venda, n�o fatura pedidos com bloqueio
@author Rafael Domingues
@since 12.02.2022
/*/
User Function M410PVNF()
	Local lRet := .T.
	Local aArea := GetArea()
	Local aAreaC5 := SC5->(GetArea())
	Local aAreaC6 := SC6->(GetArea())
	
	//Se tiver em branco o campo, n�o permite prosseguir
//	If Alltrim(SC5->C5_XSTATUS) == "X"
//		MsgAlert( "Cliente com bloqueio. O pedido n�o pode ser faturado!")
//		lRet := .F.
//	EndIf
	
	RestArea(aAreaC6)
	RestArea(aAreaC5)
	RestArea(aArea)
Return lRet
