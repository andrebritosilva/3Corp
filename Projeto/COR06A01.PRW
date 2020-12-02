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
±±ºPrograma  ³COR06A01  ºAutor  ³Marcelo Franca      º Data ³  01/12/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Alterar vencimento real                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COR06A01()
                                                  
Local oVenc
Local oVreal
Local nOpc:= 0

Private dVencre := SE2->E2_VENCREA

If Empty(SE2->E2_SALDO) 
	Alert("Título Pagoo - Não é possível alterar o vencimento!!!")
	Return
EndIf

SA2->(DbSetOrder(1))
SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA) )

Define MsDialog oVenc Title "Alteração do Vencimento Real " From C(130),C(270) To C(270),C(550) Pixel

	
@ C(005),C(005) Say "Título : " + SE2->E2_PREFIXO + " - " + SE2->E2_NUM + " - " + SE2->E2_PARCELA
@ C(015),C(005) Say "Fornecedor: " + AllTrim(SA2->A2_NOME) 

@ C(025),C(005) Say "Venc Real" 	Size C(030),C(010) Pixel Of oVenc
@ C(025),C(030) MsGet oVreal 	Var dVencre Picture "@d" Size C(035),C(010) Pixel Of oVenc VALID (dVencre>=SE2->E2_VENCTO .AND. FA050Venc(2) )

@ C(045),C(035) Button "Ok"	 		Size C(030),C(010) Pixel Action (nOpc:=1,oVenc:End() )
@ C(045),C(070) Button "Cancelar" 	Size C(030),C(010) Pixel Action (nOpc:=2,oVenc:End() )

	
Activate MsDialog oVenc Centered   

If nOpc == 1
	SE2->(Reclock("SE2",.F.))
	SE2->E2_VENCREA	:= dVencre
	SE2->(MsUnLock())
ElSeIf nOpc == 2
	Return()
EndIF

Return()