#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTitulo := "Log Integração Agrometrika"

/*/{Protheus.doc} GRFATC02
Log Integração Agrometrika
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
User Function GRFATC02()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZ2')
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()
Return NIL

/*/{Protheus.doc} MenuDef
Log Integração Agrometrika
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.GRFATC02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
Return aRot

/*/{Protheus.doc} ModelDef
Log Integração Agrometrika
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function ModelDef()
	Local oModel 	:= Nil
	Local oStZZ2 	:= FWFormStruct(1,"ZZ2")

	oModel := MPFormModel():New("xMVCZZ2M",,,,)
	oModel:AddFields("FORMZZ2",,oStZZ2)
	oModel:SetPrimaryKey({'ZZ2_FILIAL','ZZ2_COD'})
	oModel:SetDescription(cTitulo)
	oModel:GetModel("FORMZZ2"):SetDescription(cTitulo)
Return oModel

/*/{Protheus.doc} ViewDef
Log Integração Agrometrika
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function ViewDef()
	Local oModel := FWLoadModel("GRFATC02")
	Local oStZZ2 := FWFormStruct(2, "ZZ2")
	Local oView := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZZ2", oStZZ2, "FORMZZ2")
	oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView('VIEW_ZZ2', cTitulo )
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_ZZ2","TELA")
Return oView
