#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

#DEFINE  ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} MA410MNU
Ponto de Entrada - Menu do pedido de venda -> Visualiza Aprovações
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
User Function MA410MNU()
	Aadd(aRotina,{ OemToAnsi("@ Aprovações") ,"U_GRFATA01()",0 ,6 ,0 ,NIL} )
Return
