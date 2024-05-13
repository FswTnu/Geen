#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GRFATA03
Envia wf de aprovação
@author Marcio Lopes dos Santos - TNU
@since 19.01.2024
/*/
User Function GRFATA03()

Local aArea    := GetArea()
Local cAliasC6 := GetNextAlias()
Local cAliasZ0 := GetNextAlias()
Local nE

	SC5->(RecLock("SC5",.F.))
		SC5->C5_XSTATUS := ""
	SC5->(MsUnLock())

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
			SC9->(RecLock("SC9",.F.))
			SC9->C9_XAPRV1 := (cAliasZ0)->ZZ0_XAPRV1
			SC9->C9_XAPRV2 := (cAliasZ0)->ZZ0_XAPRV2
			SC9->(MsUnLock())

			DbSelectArea("SC5")
			SC5->( DbSetOrder(1) )
			SC5->( DbSeek( xFilial("SC5") + SC9->C9_PEDIDO ) )
			
			DbSelectArea("SA1")
			SA1->( DbSetOrder(1) )
			SA1->( DbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )
			If Empty( SC5->C5_XSTATUS )

				For nE := 1 To 1

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
					cHtml += '	<p></p>'
					cHtml += '	<div style="text-align: left;">&nbsp;</div>'
					cHtml += '	<div style="text-align: left;">'
					cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">Olá '+ cNomUser  +'</span></b></td>' 
					cHtml += '	<p></p>'
					cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">O pedido '+SC5->C5_NUM+ " DA FILIAL "+AllTrim(SC9->C9_FILIAL)+" - "+SM0->M0_FILIAL+', no valor de R$ '+Alltrim(Transform((cAliasC6)->TOTPED, "@E 999,999,999,999.99"))+' do cliente '+AllTrim(SA1->A1_NOME)+' foi aprovado no dia ' +DtoC(dDataBase)+ '.</span></b></td>'
					cHtml += '	<p></p><br>'
					cHtml += '	<p><span style="font-family:arial,helvetica,sans-serif;"><strong>Mensagem Autom&aacute;tica, favor n&atilde;o responder esse e-mail.</strong></span></p>'
					cHtml += '	</body>'
					cHtml += '</html>'

					cUserMail := UsrRetMail(__cUserId)

					U_GRFUNX01(cAssunto, cHtml, cUserMail)
				Next nE
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

		(cAliasZ0)->( DbCloseArea() )
	EndIf

	(cAliasC6)->( DbCloseArea() )

	RestArea(aArea)

Return
















	IF !Empty(SC5->C5_XSTATUS) .And. Empty( SC9->C9_BLCRED ) .And. Empty( SC9->C9_BLEST )

		SC5->(RecLock("SC5",.F.))
			SC5->C5_XSTATUS := ""
		SC5->(MsUnLock())

		TcSqlExec("UPDATE "+RetSqlName("ZZ1")+" SET Z1_DTAPRO = '"+DtoS(Date())+"' WHERE D_E_L_E_T_ <> '*' AND ZZ1_FILIAL = '"+xFilial("ZZ1")+"' AND ZZ1_NUM = '"+SC5->C5_NUM+"' " )

		cAssunto := "APROVAÇÃO DO PEDIDO - "+AllTrim(SC5->C5_NUM)+" da Filial "+SM0->M0_FILIAL
		
		cHtml := '<html>'
		cHtml += '<body>'
		cHtml += '	<div style="text-align: left;"><img alt="" src="https://greenplaceagro.com.br/wp-content/uploads/2023/07/Logo-5.png" style="width: 248px; height: 60px; background-color:#ffffff;" /></div>'
		cHtml += '	</p>'
		cHtml += '	<div style="text-align: left;"><span style="font-family:arial,helvetica,sans-serif;">Pedido Liberado</span></div>'
		cHtml += '	</p>'
		cHtml += '	<div style="text-align: left;">&nbsp;</div>'
		cHtml += '	<div style="text-align: left;">'

		cUserMail := UsrRetMail(__cUserId)

		cHtml += '	<td><b><span style="font-family:arial,helvetica,sans-serif;">O pedido '+SC5->C5_NUM+' está liberado a ser faturado.</span></b></td>'
		cHtml += '	</p>'
		cHtml += '		<p><span style="font-family:arial,helvetica,sans-serif;"><strong>Mensagem Autom&aacute;tica, favor n&atilde;o responder esse e-mail.</strong></span></p>'
		cHtml += '	</body>'
		cHtml += '</html>'

		U_GRFUNX01(cAssunto, cHtml, cUserMail)
	EndIf

Return
