#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static cTitulo := "Aprovadores Pedido de Venda"

/*/{Protheus.doc} GRFATC01
Aprovadores Pedido de Venda
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
User Function GRFATC01()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZ0')
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()
Return NIL

/*/{Protheus.doc} MenuDef
Aprovadores Pedido de Venda
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.GRFATC01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.GRFATC01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.GRFATC01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.GRFATC01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

/*/{Protheus.doc} ModelDef
Aprovadores Pedido de Venda
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function ModelDef()
	Local oModel 	:= Nil
	Local oStZZ0 	:= FWFormStruct(1,"ZZ0")

	oModel := MPFormModel():New("xMVCZZ0M",,,,)
	oModel:AddFields("FORMZZ0",,oStZZ0)
	oModel:SetPrimaryKey({'ZZ0_FILIAL','ZZ0_COD'})
	oModel:SetDescription(cTitulo)
	oModel:GetModel("FORMZZ0"):SetDescription(cTitulo)
Return oModel

/*/{Protheus.doc} ViewDef
Aprovadores Pedido de Venda
@author Rafael Domingues - TNU
@since 12.11.2023
/*/
Static Function ViewDef()
	Local oModel := FWLoadModel("GRFATC01")
	Local oStZZ0 := FWFormStruct(2, "ZZ0")
	Local oView := Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_ZZ0", oStZZ0, "FORMZZ0")
	oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView('VIEW_ZZ0', cTitulo )
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_ZZ0","TELA")
Return oView
