#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"        
#INCLUDE "TOPCONN.CH"          
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#Include "RwMake.ch"
#INCLUDE "SHELL.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cor05A01  ºAutor  ³Marcelo Franca      º Data ³  01/12/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incluir Dados Logisticos - Pesos - Transportadora - obs     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COR05A01()
                                                  
Local oCodTr
Local oPesoLi 
Local oPesoBr 
Local oEspeci 
Local oVolume 
Local oObs	
Local nOpc:= 0
Local lRet:= .T.

Private nPesoLi := SC5->C5_PESOL
Private nPesoBr := SC5->C5_PBRUTO
Private cTransp := SC5->C5_TRANSP
Private cEspeci := SC5->C5_ESPECI1
Private nVolume := SC5->C5_VOLUME1
Private cObs	:= SC5->C5_XOBS  
Private cNtransp:= Posicione("SA4",1,xFilial("SA4") + cTransp,"A4_NREDUZ")
Private oLogi
Private oTransp

If (!Empty(SC5->C5_NOTA)) .Or. (SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ))
	Alert("Pedido Encerrado - Não é possível incluir dados logisticos!!!")
	Return
EndIf

SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI) )

Define MsDialog oLogi Title "Dados Logisticos" From C(130),C(270) To C(470),C(750) Pixel
//C(230),C(470) To C(350),C(750) Pixel
	
@ C(005),C(005) Say "Pedido : " + SC5->C5_NUM //+ " - Pedido Protheus:" + SC5->C5_NUM
@ C(015),C(005) Say "Cliente: " + AllTrim(SA1->A1_NOME) 

@ C(025),C(005) Say "Transp.:" 	Size C(030),C(010) Pixel Of oLogi
@ C(025),C(030) MsGet oCodTr 	Var cTransp Picture "@!" Size C(030),C(010) Pixel Of oLogi F3 "SA4" VALID ((vazio() .And. unome() ) .or. (Existcpo("SA4") .And. unome() ) )
@ C(025),C(075) Say "Nome Tran:" 	Size C(030),C(010) Pixel Of oLogi
@ C(025),C(100) MsGet oTransp  Var cNtransp When .f. Picture "@!" Size C(050),C(010) Pixel Of oLogi 

@ C(045),C(005) Say "Peso Liq:" 	Size C(030),C(010) Pixel Of oLogi
@ C(045),C(030) MsGet oPesoLi  	Var nPesoLi  Picture "@e 999,999.9999" Size C(035),C(010) Pixel Of oLogi 
@ C(045),C(075) Say "Peso Bruto:" 	Size C(030),C(010) Pixel Of oLogi
@ C(045),C(100) MsGet oPesoBr  	Var nPesoBr  Picture "@e 999,999.9999" Size C(035),C(010) Pixel Of oLogi 

@ C(065),C(005) Say "Especie:" 	Size C(030),C(010) Pixel Of oLogi
@ C(065),C(030) MsGet oEspeci  	Var cEspeci  Picture "@!" Size C(030),C(010) Pixel Of oLogi 
@ C(065),C(075) Say "Volume:" 	Size C(030),C(010) Pixel Of oLogi
@ C(065),C(100) MsGet oVolume  	Var nVolume  Picture "99999" Size C(015),C(010) Pixel Of oLogi 

@ C(085),C(005) Say "Obs.:" 	Size C(030),C(010) Pixel Of oLogi
@ C(085),C(030) Get oObs  	Var cObs When .f. Size C(200),C(060) MULTILINE Of oLogi PIXEL

@ C(150),C(095) Button "Ok"	 Size C(030),C(010) Pixel Action (nOpc:=1,oLogi:End() )
@ C(150),C(140) Button "Cancelar" Size C(030),C(010) Pixel Action (nOpc:=2,oLogi:End() )

Activate MsDialog oLogi Centered   

If nOpc == 1
	SC5->(Reclock("SC5",.F.))
	SC5->C5_TRANSP	:= cTransp
	SC5->C5_PESOL	:= nPesoLi
	SC5->C5_PBRUTO	:= nPesoBr
	SC5->C5_ESPECI1	:= cEspeci
	SC5->C5_VOLUME1	:= nVolume
	SC5->C5_XOBS	:= cObs
	SC5->(MsUnLock())
	lRet:= .T.
ElSeIf nOpc == 2
	lRet:= .F.
EndIF

Return(lRet)

Static Function Unome()

	cNtransp:= Posicione("SA4",1,xFilial("SA4") + cTransp,"A4_NREDUZ")
	oTransp:Refresh()
	oTransp:SetFocus()

Return (.T.)