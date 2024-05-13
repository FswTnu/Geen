#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GRFATA01
Visualiza Aprovações
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
User Function GRFATA01()
	Local oButton1

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Aprovações" FROM 000, 000 TO 500, 600 COLORS 0, 16777215 PIXEL

	fMSNewGe1()
	@ 224, 139 BUTTON oButton1 PROMPT "Ok" ACTION (oDlg:End()) SIZE 045, 015 OF oDlg PIXEL
	@ 224, 209 BUTTON oButton2 PROMPT "Voltar" ACTION (oDlg:End()) SIZE 045, 015 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} GRFATA01
Visualiza Aprovações
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function fMSNewGe1()
	Local nX
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"ZZ1_CODUSR","ZZ1_NOMUSR","ZZ1_NUM","ZZ1_JUSTIF","ZZ1_DTAPRO"}
	Local aAlterFields := {}
	Local cQuery       := ""
	Static oMSNewGe1

// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {	AllTrim(X3Titulo())	,;
				SX3->X3_CAMPO      	,;
				SX3->X3_PICTURE   	,;
				SX3->X3_TAMANHO 	,;
				SX3->X3_DECIMAL 	,;
				SX3->X3_VALID 		,;
				SX3->X3_USADO 		,;
				SX3->X3_TIPO 		,;
				SX3->X3_F3 			,;
				SX3->X3_CONTEXT 	,;
				SX3->X3_CBOX 		,;
				SX3->X3_RELACAO		})
		Endif
	Next nX

// Define field values
	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)

	aColsEx := {}

	cQuery := " SELECT ZZ1_CODUSR,ZZ1_NOMUSR,ZZ1_NUM,ZZ1_JUSTIF,ZZ1_DTAPRO FROM "+RetSqlName("ZZ1")
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += " AND ZZ1_FILIAL = '"+xFilial("ZZ1")+"' "
	cQuery += " AND ZZ1_NUM = '"+SC5->C5_NUM+"' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMP', .T., .F.)
	TcSetField("TMP","ZZ1_DTAPRO","D")

	DbSelectArea("TMP")
	DbGoTop()
	While !Eof()

		aAdd(aColsEx, {	TMP->ZZ1_CODUSR, TMP->ZZ1_NOMUSR,TMP->ZZ1_NUM, TMP->ZZ1_JUSTIF,	TMP->ZZ1_DTAPRO, .F.})

		DbSelectArea("TMP")
		DbSkip()
	End

	DbSelectArea("TMP")
	DbCloseArea()

	oMSNewGe1 := MsNewGetDados():New( 012, 004, 206, 295, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return
