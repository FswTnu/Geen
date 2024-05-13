#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} M440STTS
Ponto de entrada para bloqueio e envio de WF de aprovação
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
User Function M440STTS()
	
	Local aArea    := GetArea()
	Local cAliasC6 := GetNextAlias()
	Local cAliasZ0 := GetNextAlias()
	Local nE
	

	If SC9->C9_BLCRED == "01" .Or. SC9->C9_BLCRED == "04"

		_cQryC6 := " SELECT SUM( C6_PRCVEN * C6_QTDVEN ) AS TOTPED FROM "+RetSqlName('SC6')
		_cQryC6 += " WHERE D_E_L_E_T_ = ' ' "
		_cQryC6 += " AND C6_FILIAL = '"+xFilial('SC9')+"' "
		_cQryC6 += " AND C6_NUM = '"+SC9->C9_PEDIDO+"' "

		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQryC6),cAliasC6,.F.,.T.)
		
		If (cAliasC6)->( !Eof() )
			cQry := " SELECT ZZ0_XAPRV1, ZZ0_XAPRV2, ZZ0_NOMUS1, ZZ0_NOMUS2 FROM "+RetSqlName("ZZ0")
			cQry += " WHERE D_E_L_E_T_ =  ' ' "
			cQry += " AND '"+AllTrim(Str( (cAliasC6)->TOTPED ) )+"' BETWEEN ZZ0_LIMINF AND ZZ0_LIMSUP "
			DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry),cAliasZ0,.F.,.T.)

			If (cAliasZ0)->( !Eof() )
				If Empty(SC9->C9_XAPRV1) .Or. Empty(SC9->C9_XAPRV2)
					SC9->C9_XAPRV1 := (cAliasZ0)->ZZ0_XAPRV1
					SC9->C9_XAPRV2 := (cAliasZ0)->ZZ0_XAPRV2

					DbSelectArea("SC5")
					SC5->( DbSetOrder(1) )
					SC5->( DbSeek( xFilial("SC5") + SC9->C9_PEDIDO ) )
					If !Empty(SC9->C9_XAPRV1) .Or. !Empty(SC9->C9_XAPRV2)

						For nE := 1 To 2

							If nE == 1
								cEmail   := AllTrim(UsrRetMail( (cAliasZ0)->ZZ0_XAPRV1))
								cNomUser := AllTrim((cAliasZ0)->ZZ0_NOMUS1)
							Else
								cEmail   := AllTrim(UsrRetMail( (cAliasZ0)->ZZ0_XAPRV2))
								cNomUser := AllTrim((cAliasZ0)->ZZ0_NOMUS2)
							EndIf

				
							cAssunto	:= "APROVAÇÃO DO PEDIDO - "+AllTrim(SC9->C9_PEDIDO)+" DA FILIAL "+AllTrim(SC9->C9_FILIAL)+" - "+SM0->M0_FILIAL

							cHtml := '<html>'
							cHtml += '<body>'
							cHtml += '	<div style="text-align: left;"><img alt="" src="https://greenplaceagro.com.br/wp-content/uploads/2023/07/Logo-5.png" style="width: 248px; height: 60px; background-color:#ffffff;" /></div>'
							cHtml += '	<p></p><br>'
							cHtml += '	<div style="text-align: left;"><span style="font-family:arial,helvetica,sans-serif;">Pedido Não Faturado</span></div>'
							cHtml += '	<p></p>'
							cHtml += '	<div style="text-align: left;">&nbsp;</div>'
							cHtml += '	<div style="text-align: left;">'
							cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">Olá '+ cNomUser  +'</span></b></td>' 
							cHtml += '	<p></p>'
							If SC9->C9_BLCRED == "01"
								cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">O pedido '+SC5->C5_NUM+' no valor de R$ '+Alltrim(Transform((cAliasC6)->TOTPED, "@E 999,999,999,999.99"))+' do cliente '+AllTrim(SA1->A1_NOME)+' foi bloqueado confome o motivo 01 - Bloqueio de crédito por valor.</span></b></td>'
							Else
								cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">O pedido '+SC5->C5_NUM+' no valor de R$ '+Alltrim(Transform((cAliasC6)->TOTPED, "@E 999,999,999,999.99"))+' do cliente '+AllTrim(SA1->A1_NOME)+' foi bloqueado confome o motivo 04 - Vencimento do limite de crédito – Data de crédito vencida.</span></b></td>'
							EndIf
							cHtml += '	<p></p><br>'
							cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">No momento do bloqueio deste pedido, a situação do cliente era:</span></b></td>'
							cHtml += '	<p></p>'
							cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">Limite disponível: '+Alltrim(Transform((SA1->A1_LC + SA1->A1_LCFIN) - (SA1->A1_SALDUP + SA1->A1_SALPEDL), "@E 999,999,999,999.99"))+'</span></b></td>' 
							cHtml += '	<p></p>'
							cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">Validade do seu limite de crédito: '+DtoC(SA1->A1_VENCLC)+'</span></b></td>'
							cHtml += '	<p></p>'
							cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">Somatória dos títulos em aberto: '+Alltrim(Transform(SA1->A1_ATR, "@E 999,999,999,999.99"))+'</span></b></td>' 
							cHtml += '	<p></p>'
							cHtml += '	<p><span style="font-family:arial,helvetica,sans-serif;"><strong>Mensagem Autom&aacute;tica, favor n&atilde;o responder esse e-mail.</strong></span></p>'
							cHtml += '	</body>'
							cHtml += '</html>'

							U_GRFUNX01(cAssunto, cHtml, cEmail)
						Next nE

						SC5->(RecLock('SC5',.F.))
						//SC5->C5_LIBEROK := 'S'
						SC5->C5_XSTATUS := "X"
						SC5->(MsUnLock())
						/*
						DbSelectArea("ZZ1")
						ZZ1->(RecLock("ZZ1",.T.))
						ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
						ZZ1->ZZ1_CODUSR := cCodUser
						ZZ1->ZZ1_NOMUSR := cNomUser
						ZZ1->ZZ1_NUM	:= SC5->C5_NUM
						ZZ1->(MsUnLock())
						*/
					EndIf
				EndIf
			EndIf

			(cAliasZ0)->( DbCloseArea() )
		EndIf

		(cAliasC6)->( DbCloseArea() )

		RestArea(aArea)
	EndIF
Return
