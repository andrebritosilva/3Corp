#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"          
#Include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M030INC   ºAutor  ³Microsiga           º Data ³  20/11/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 3Corp                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M030INC()

	If SA1->A1_XCADAST == '2' .And. M->A1_COD <> NIL

		SA2->(DbSetOrder(3)) // A2_FILIAL + A2_CGC
		SA2->(DbGoTop())	
		
		If SA2->(DbSeek(xFilial("SA2") + AllTrim(SA1->A1_CGC) ) )
		
			Alert("Cliente já cadastrado como Fornecedor. Código = " + SA2->A2_COD + " - " + SA2->A2_LOJA)
			
			If SA1->A1_XCADAST == '1' .or. Empty(SA1->A1_XCADAST)
				
				SA1->(Reclock("SA1",.F.))
				SA1->A1_XCADAST	:= "2"
				SA1->(MsUnLock())
			
			EndIf
        
			If SA2->A2_XCADAST == '1'  .or. Empty(SA2->A2_XCADAST)
				
				SA2->(Reclock("SA2",.F.))
				SA2->A2_XCADAST	:= "2"
				SA2->(MsUnLock())
			
			EndIf

		Else
			
			Processa({|| ClieInc()},"Incluir Cliente")			
			
		EndIf

	EndIf	
	
	SA2->(DbSetOrder(1)) // A2_FILIAL + A2_CGC
	SA2->(DbGoTop())	
	
Return

Static Function ClieInc()

	Local aVetor   		:= {}                                                  
	Local cCodigo		:= ""
	Local cLoja			:= ""

	Private lMsErroAuto	:= .F.          

	ProcRegua(2)

	//Incluir Cliente
			
	cCodigo	:= ""
	cLoja	:= ""

	If SA2->(DbSeek(xFilial("SA2") + AllTrim(SubStr(SA1->A1_CGC,1,8)) ) )

		cCodigo	:= SA2->A2_COD
		cLoja	:= SA2->A2_LOJA
	
		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
	
		While SA2->(DbSeek(xFilial("SA2") + cCodigo + cLoja ) )

			cLoja := Strzero((Val(cLoja) + 1),4)

		End

	Else

		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
  		    
    	cCodigo	:= GETSXENUM("SA2","A2_COD")
  		    	
    	While SA2->(DbSeek(xFilial("SA2") + cCodigo + cLoja ) ) 
  		    	
    		cCodigo:= SOMA1(cCodigo)
  		    		  		    	
    	End

    	cLoja	:= "0001"
  		
	EndIf
			
	AADD(aVetor,{"A2_COD"		,cCodigo 			,Nil})
	AADD(aVetor,{"A2_LOJA"		,cLoja 				,Nil})
	AADD(aVetor,{"A2_NOME"		,SA1->A1_NOME		,Nil})
	AADD(aVetor,{"A2_NREDUZ"	,SA1->A1_NREDUZ		,Nil})
	AADD(aVetor,{"A2_MSBLQL"	,"1"				,Nil})
	AADD(aVetor,{"A2_END"		,SA1->A1_END		,Nil})
	AADD(aVetor,{"A2_COMPLEM"	,SA1->A1_COMPLEM	,Nil})
	AADD(aVetor,{"A2_BAIRRO"	,SA1->A1_BAIRRO		,Nil})
	AADD(aVetor,{"A2_EST"		,SA1->A1_EST		,Nil})
	AADD(aVetor,{"A2_COD_MUN"	,SA1->A1_COD_MUN	,Nil})
	AADD(aVetor,{"A2_MUN"		,SA1->A1_MUN		,Nil})
	AADD(aVetor,{"A2_CEP"		,SA1->A1_CEP		,Nil})
	AADD(aVetor,{"A2_TIPO"		,SA1->A1_PESSOA		,Nil})
	AADD(aVetor,{"A2_PAIS"		,SA1->A1_PAIS		,Nil})
	AADD(aVetor,{"A2_EMAIL"		,SA1->A1_EMAIL		,Nil})
	AADD(aVetor,{"A2_CGC"		,SA1->A1_CGC		,Nil})
	AADD(aVetor,{"A2_INSCR"		,SA1->A1_INSCR		,Nil})
            
	If !Empty(SA1->A1_INSCRM)
		
		AADD(aVetor,{"A2_INSCRM"	,SA1->A1_INSCRM		,Nil})
				
	Else

		AADD(aVetor,{"A2_INSCRM"	,"ISENTO"		,Nil})
			
	EndIf

	If !Empty(SA1->A1_DDI)
		
		AADD(aVetor,{"A2_DDI"	,SA1->A1_DDI		,Nil})
			
	EndIf

	AADD(aVetor,{"A2_DDD"		,SA1->A1_DDD		,Nil})
	AADD(aVetor,{"A2_TEL"		,SA1->A1_TEL		,Nil})

	If !Empty(SA1->A1_CONTATO)
		
		AADD(aVetor,{"A2_CONTATO"	,SA1->A1_CONTATO		,Nil})
			
	EndIf

	If !Empty(SA1->A1_FAX)
		
		AADD(aVetor,{"A2_FAX"	,SA1->A1_FAX		,Nil})
			
	EndIf

	If !Empty(SA1->A1_PFISICA)
		
		AADD(aVetor,{"A2_PFISICA"	,SA1->A1_PFISICA		,Nil})
			
	EndIf

	If !Empty(SA1->A1_HPAGE)
		
		AADD(aVetor,{"A2_HPAGE"	,SA1->A1_HPAGE		,Nil})
			
	EndIf
			
	AADD(aVetor,{"A2_NATUREZ"	,SA1->A1_NATUREZ	,Nil})
	AADD(aVetor,{"A2_CODPAIS"	,SA1->A1_CODPAIS	,Nil})

	If !Empty(SA1->A1_TPESSOA) .And. SA1->A1_TPESSOA <> "EP"
		
		AADD(aVetor,{"A2_TPESSOA"	,SA1->A1_TPESSOA	,Nil})
			
	EndIf
			
	AADD(aVetor,{"A2_CONTRIB"	,SA1->A1_CONTRIB	,Nil})
	AADD(aVetor,{"A2_XCADAST"	,"2"				,Nil})

	IncProc("Incluir Fornecedor")

	MSExecAuto({|x,y| Mata020(x,y)},aVetor,3) //3- Inclusao, 4- Altera?o, 5- Exclus?
			
	If lMsErroAuto
	
		MostraErro()
		RollbackSx8()

	Else
			
		ConfirmSX8()
		MsgInfo("Fornecedor Incluido = " + cCodigo + " - " + cLoja + ". Favor validar e desbloquear o Fornecedor no Cadastro de Fornecedores.", "Fim")
																			
		If SA1->A1_XCADAST == '1' .or. Empty(SA1->A1_XCADAST)
				
			SA1->(Reclock("SA1",.F.))
			SA1->A1_XCADAST	:= "2"
			SA1->(MsUnLock())
			
		EndIf
	
	EndIf
	
	SA2->(DbSetOrder(1))
	SA2->(DbGoTop())
		
Return()