#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MATA030_MVC
Ponto de Entrada do Cadastro de Clientes (MVC) - alteração -> Integração Green
@author Rafael Domingues - TNU
@since 16.09.2023
/*/
User Function CRMA980()
	Local aArea := GetArea()
	Local xRet	:= .T.
	
	xRet := U_AGROMETR()

	RestArea(aArea)
Return xRet
