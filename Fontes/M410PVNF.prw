#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} M410PVNF
Ponto de entrada - Validação na chamada do Prep Doc Saída no Ações Relacionadas do Pedido de Venda, não fatura pedidos com bloqueio
@author Rafael Domingues
@since 12.02.2022
/*/
User Function M410PVNF()
	Local lRet := .T.
	Local aArea := GetArea()
	Local aAreaC5 := SC5->(GetArea())
	Local aAreaC6 := SC6->(GetArea())
	
	//Se tiver em branco o campo, não permite prosseguir
//	If Alltrim(SC5->C5_XSTATUS) == "X"
//		MsgAlert( "Cliente com bloqueio. O pedido não pode ser faturado!")
//		lRet := .F.
//	EndIf
	
	RestArea(aAreaC6)
	RestArea(aAreaC5)
	RestArea(aArea)
Return lRet
