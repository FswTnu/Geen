#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"

/*/{Protheus.doc} GRFATA02
FwMarkBrowse para aprovar pedido de venda
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
User Function GRFATA02()
	Local aCampos		:= {}

	Private cCadastro 	:= "Aprova Pedido de Vendas"
	Private cArqTmp		:= ''
	Private aRetPar		:= {}
	Private aParamBox	:= {}
	Private oBrowse 	:= Nil

	//Criar a tabela temporária
	aAdd(aCampos,{"TR_OK"  		,"C",2,0}) //Este campo será usado para marcar/desmarcar
	aAdd(aCampos,{"TR_FILIAL" 	,"C",TamSX3("C5_FILIAL")[1],0})
	aAdd(aCampos,{"TR_PEDIDO" 	,"C",TamSX3("C5_NUM")[1],0})
	aAdd(aCampos,{"TR_CLIENTE"	,"C",TamSX3("A1_COD")[1],0})
	aAdd(aCampos,{"TR_NOMCL"	,"C",TamSX3("A1_NOME")[1],0})
	aAdd(aCampos,{"TR_CGC"		,"C",TamSX3("A1_CGC")[1],0})
	aAdd(aCampos,{"TR_VALPED"	,"N",16,2})
	aAdd(aCampos,{"TR_POS"  	,"N",12,0})

	oTempTable := FWTemporaryTable():New("cArqTmp",aCampos)
	oTempTable:AddIndex("01", {"TR_PEDIDO"} )
	oTempTable:Create()
	cArqTmp := oTempTable:GetAlias()

	aAdd(aParamBox,{1 ,"Emissao de"		,Ctod(Space(8))								,"","",""		,"",50,.F.})
	aAdd(aParamBox,{1 ,"Emissao ate"	,dDataBase									,"","",""		,"",50,.F.})
	aAdd(aParamBox,{1 ,"Pedido de"		,Space(TamSX3("C5_NUM")[1])					,"","","SC5"	,"",00,.F.})
	aAdd(aParamBox,{1 ,"Pedido ate"		,Replicate( "Z", TamSX3("C5_NUM")[1] )		,"","","SC5"	,"",00,.F.})

	If ParamBox(aParamBox,"Parâmetros",@aRetPar)
		FWMsgRun( , {|| GRFAT02A(aRetPar) }, cCadastro,'Aguarde, montando a interface...' )
	Else
		FwAlertSucess(('Processo cancelado.'))
	EndIf
Return(.T.)

/*/{Protheus.doc} GRFAT02A
FwMarkBrowse para envio de pedidos
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function GRFAT02A(aRetPar)
	Local lMarcar	:= .F.
	Local aSeek		:= {}
	Local cQry		:= ''

	Private cAliasTMP	:= ""

	cQry := " SELECT C5_FILIAL, C5_NUM, A1_COD, A1_NOME, A1_CGC, SC5.R_E_C_N_O_ AS RECSC5, SUM(C9_PRCVEN) AS C9_PRCVEN, SUM(C9_QTDLIB) AS C9_QTDLIB FROM "+RetSqlName("SC5")+" SC5 "
	cQry += " INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.D_E_L_E_T_ <> '*' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM "
	cQry += " INNER JOIN "+RetSqlName("SC9")+" SC9 ON SC9.D_E_L_E_T_ <> '*' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C6_ITEM = C9_ITEM "
	cQry += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.D_E_L_E_T_ <> '*' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI "
	cQry += " WHERE SC5.D_E_L_E_T_ <> '*' "
	cQry += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQry += " AND C5_XSTATUS = 'X' "
	cQry += " AND C9_NFISCAL = '' "
	cQry += " AND C9_BLEST IN ('','10') "
	cQry += " AND C9_BLCRED IN ('','10') "
	cQry += " AND C5_EMISSAO BETWEEN '"+DtoS(aRetPar[1])+"' AND '"+DtoS(aRetPar[2])+"' "
	cQry += " AND C5_NUM BETWEEN '"+aRetPar[3]+"' AND '"+aRetPar[4]+"' "
	cQry += " GROUP BY C5_FILIAL, C5_NUM, A1_COD, A1_NOME, A1_CGC, SC5.R_E_C_N_O_ "
	cAliasTMP := GetNextAlias()
	nTotReg := 0
	DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry),cAliasTMP,.F.,.T.)
	(cAliasTMP)->( DbEval( { || nTotReg++ },,{ || !Eof() } ) )
	(cAliasTMP)->( DbGoTop() )

	If nTotReg == 0
		(cAliasTMP)->( DbCloseArea() )
		FWAlertWarning('Não há dados para os parâmetros informados!')
		Return
	Endif

	//Popular tabela temporária
	(cAliasTMP)->( DbGoTop() )
	While (cAliasTMP)->(!Eof())
		RecLock("cArqTmp",.T.)
		(cArqTmp)->TR_OK		:= ""
		(cArqTmp)->TR_FILIAL	:= AllTrim((cAliasTMP)->C5_FILIAL)
		(cArqTmp)->TR_PEDIDO	:= AllTrim((cAliasTMP)->C5_NUM)
		(cArqTmp)->TR_CLIENTE	:= AllTrim((cAliasTMP)->A1_COD)
		(cArqTmp)->TR_NOMCL		:= AllTrim((cAliasTMP)->A1_NOME)
		(cArqTmp)->TR_CGC		:= AllTrim((cAliasTMP)->A1_CGC)
		(cArqTmp)->TR_VALPED	:= (cAliasTMP)->C9_PRCVEN * (cAliasTMP)->C9_QTDLIB
		(cArqTmp)->TR_POS 		:= (cAliasTMP)->RECSC5
		MsUnLock()
		(cAliasTMP)->( DbSkip() )
	End
	(cAliasTMP)->( DbCloseArea() )

	(cArqTmp)->(DbGoTop())
	If (cArqTmp)->(!Eof())
		//Irei criar a pesquisa que será apresentada na tela
		aAdd(aSeek,{"Pedido"	,{{"","C",050,0,"Pedido"	,"@!"}} } )

		//Agora iremos usar a classe FWMarkBrowse
		oBrowse:= FWMarkBrowse():New()
		oBrowse:SetDescription(cCadastro) //Titulo da Janela
		oBrowse:SetAlias(cArqTmp) //Indica o alias da tabela que será utilizada no Browse
		oBrowse:SetFieldMark("TR_OK") //Indica o campo que deverá ser atualizado com a marca no registro
		oBrowse:oBrowse:SetDBFFilter(.T.)
		oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
		oBrowse:oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
		oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
		oBrowse:SetTemporary() //Indica que o Browse utiliza tabela temporária
		oBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
		oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse

		oBrowse:SetColumns(GRFAT02C("TR_FILIAL"		,"Filial"			,03,"@!",0,010,0))
		oBrowse:SetColumns(GRFAT02C("TR_PEDIDO"		,"Pedido"			,03,"@!",0,010,0))
		oBrowse:SetColumns(GRFAT02C("TR_CLIENTE"	,"Cod. Cliente"		,03,"@!",0,010,0))
		oBrowse:SetColumns(GRFAT02C("TR_NOMCL"		,"Nome Cliente"		,03,"@!",0,010,0))
		oBrowse:SetColumns(GRFAT02C("TR_CGC"		,"CPF/CNPJ"			,03,"@!",0,010,0))
		oBrowse:SetColumns(GRFAT02C("TR_VALPED"		,"Valor Pedido"		,03,"@E 999,999,999,999.99",2,20,0))

		//Adiciona botoes na janela
		oBrowse:AddButton("Aprovar", { ||  Processa({|| GRFAT02D() }, "Aprovando Pedidos ...") } )
		oBrowse:AddButton("Reprovar", { ||  Processa({|| GRFAT02F() }, "Reprovando Pedidos ...") } )
		oBrowse:AddButton("Vis.Pedido", { ||  Processa({|| GRFAT02E(TR_PEDIDO) }, "Visualiza Pedido") } )

		//Indica o Code-Block executado no clique do header da coluna de marca/desmarca
		oBrowse:bAllMark := { || GRFAT02B(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }

		//Método de ativação da classe
		oBrowse:Activate()

		oBrowse:oBrowse:Setfocus() //Seta o foco na grade
	EndIf
Return

/*/{Protheus.doc} GRFAT02B
Função para marcar/desmarcar todos os registros do grid
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function GRFAT02B(cMarca,lMarcar)
	Local cAlTempo := 'cArqTmp'
	Local aArTempo  := (cAlTempo)->( GetArea() )

	dbSelectArea(cAlTempo)
	(cAlTempo)->( dbGoTop() )
	While !(cAlTempo)->( Eof() )
		RecLock( (cAlTempo), .F. )
		(cAlTempo)->TR_OK := IIf( lMarcar, cMarca, '  ' )
		MsUnlock()
		(cAlTempo)->( dbSkip() )
	EndDo

	RestArea( aArTempo )
Return .T.

/*/{Protheus.doc} GRFAT02C
Função para criar as colunas do grid
@author Rafael Domingues - TNU
@since 12.11.2023
/*/ 
Static Function GRFAT02C(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
	EndIf

    /* Array da coluna
    [n][01] Título da coluna
    [n][02] Code-Block de carga dos dados
    [n][03] Tipo de dados
    [n][04] Máscara
    [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    [n][06] Tamanho
    [n][07] Decimal
    [n][08] Indica se permite a edição
    [n][09] Code-Block de validação da coluna após a edição
    [n][10] Indica se exibe imagem
    [n][11] Code-Block de execução do duplo clique
    [n][12] Variável a ser utilizada na edição (ReadVar)
    [n][13] Code-Block de execução do clique no header
    [n][14] Indica se a coluna está deletada
    [n][15] Indica se a coluna será exibida nos detalhes do Browse
    [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
    */
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}

/*/{Protheus.doc} GRFAT02D
Função para aprovar
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function GRFAT02D()
	Local cAlTempo	:= 'cArqTmp'
	Local aArTempo	:= (cAlTempo)->( GetArea() )

	ProcRegua( nTotReg )
	dbSelectArea(cAlTempo)
	(cAlTempo)->( dbGoTop() )
	While !(cAlTempo)->( Eof() )
		If !Empty((cAlTempo)->TR_OK)
			SC5->(DbGoTo((cAlTempo)->TR_POS))
			SC5->(RecLock("SC5",.F.))
			SC5->C5_XSTATUS := ""
			SC5->(MsUnLock())

			TcSqlExec("UPDATE "+RetSqlName("ZZ1")+" SET Z1_DTAPRO = '"+DtoS(Date())+"' WHERE D_E_L_E_T_ <> '*' AND ZZ1_FILIAL = '"+xFilial("ZZ1")+"' AND ZZ1_NUM = '"+SC5->C5_NUM+"' " )

			cAssunto := "PEDIDO APROVADO - "+AllTrim(SC5->C5_NUM)+" da Filial "+SM0->M0_FILIAL
			
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
		(cAlTempo)->( DbSkip() )
	End

	FWAlertInfo('Execução Finalizada!', cCadastro )
	GRFAT02B('',.F.)

	RestArea( aArTempo )
Return( Nil )

/*/{Protheus.doc} GRFAT02F
Função para reprovar
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function GRFAT02F()
	Local cAlTempo	:= 'cArqTmp'
	Local aArTempo	:= (cAlTempo)->( GetArea() )

	ProcRegua( nTotReg )
	dbSelectArea(cAlTempo)
	(cAlTempo)->( dbGoTop() )
	While !(cAlTempo)->( Eof() )
		If !Empty((cAlTempo)->TR_OK)
			TcSqlExec("UPDATE "+RetSqlName("ZZ1")+" SET ZZ1_JUSTIF = 'REPROVADO DESACORDO VALOR', Z1_DTAPRO = '"+DtoS(Date())+"' WHERE D_E_L_E_T_ <> '*' AND ZZ1_FILIAL = '"+xFilial("ZZ1")+"' AND ZZ1_NUM = '"+SC5->C5_NUM+"' " )
		EndIf
		(cAlTempo)->( DbSkip() )
	End

	FWAlertInfo('Execução Finalizada!', cCadastro )
	GRFAT02B('',.F.)

	RestArea( aArTempo )
Return( Nil )

/*/{Protheus.doc} GRFAT02E
Função para visualizar o pedido
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function GRFAT02E(TR_PEDIDO)
	Local aArea := GetArea() //Irei gravar a area atual
	Private Inclui    := .F. //defino que a inclusão é falsa
	Private Altera    := .T. //defino que a alteração é verdadeira
	Private nOpca     := 1   //obrigatoriamente passo a variavel nOpca com o conteudo 1
	Private cCadastro := "Pedido de Vendas" //obrigatoriamente preciso definir com private a variável cCadastro
	Private aRotina := {} //obrigatoriamente preciso definir a variavel aRotina como private

	DbSelectArea("SC5") //Abro a tabela SC5
	SC5->(dbSetOrder(1)) //Ordeno no índice 1
	SC5->(dbSeek(xFilial("SC5")+TR_PEDIDO)) //Localizo o meu pedido
	If SC5->(!EOF()) //Se o pedido existe irei continuar
		SC5->(DbGoTo(Recno())) //Me posiciono no pedido
		MatA410(Nil, Nil, Nil, Nil, "A410Visual") //executo a função padrão MatA410
	Endif
	SC5->(DbCloseArea()) //quando eu sair da tela de visualizar pedido, fecho o meu alias
	RestArea(aArea) //restauro a area anterior.
Return
