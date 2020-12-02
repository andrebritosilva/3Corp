#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"          
#Include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cor05A04  ºAutor  ³Marcelo Franca      º Data ³  18/11/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incluir Cliente / Fornecedor                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 3Corp                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COR05A04()
            
	Local aVetor   		:= {}                                                  
	Local cCodigo		:= ""
	Local cLoja			:= ""
	Local oCli
	Local oVend
	Local aCombo 	:= { "F = Cons.Final", "L = Produtor Rural", "R = Revendedor", "S = Solidario", "X = Exportacao" } 
	Local aAuxCombo	:= { "F", "L", "R", "S", "X" }
	Local nAux		:= 0
	Local cTipo		:= ""
	Local oTipo 

	Private lMsErroAuto	:= .F.          
	Private cVend		:= Space(06)	

	If Funname()=="MATA030" //Cliente - Incluir Fornecedor

		ProcRegua(2)

		SA2->(DbSetOrder(3)) // A2_FILIAL + A2_CGC
		SA2->(DbGoTop())	
		
		If SA2->(DbSeek(xFilial("SA2") + AllTrim(SA1->A1_CGC) ) )
			
			IncProc("Incluir Fornecedor")
			
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
		    
			//Incluir Fornecedor
			
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
	
		EndIf
		

	ElseIf Funname()=="MATA020" //Fornecedor - Incluir Cliente

		nAux		:= aScan( aAuxCombo, "F" )
		
		If nAux > 0
			cTipo := aCombo[nAux]
		Endif


		SA1->(DbSetOrder(3)) // A1_FILIAL + A1_CGC
		SA1->(DbGoTop())	
		
		If SA1->(DbSeek(xFilial("SA1") + AllTrim(SA2->A2_CGC) ) )
		
			IncProc("Incluir Cliente")
		
			Alert("Fornecedor já cadastrado como Cliente. Código = " + SA1->A1_COD + " - " + SA1->A1_LOJA)
			
			If SA2->A2_XCADAST == '1'  .or. Empty(SA2->A2_XCADAST)
				
				SA2->(Reclock("SA2",.F.))
				SA2->A2_XCADAST	:= "2"
				SA2->(MsUnLock())
			
			EndIf
        
   			If SA1->A1_XCADAST == '1'  .or. Empty(SA1->A1_XCADAST)
				
				SA1->(Reclock("SA1",.F.))
				SA1->A1_XCADAST	:= "2"
				SA1->(MsUnLock())
			
			EndIf

		Else

			//Tela para perguntar - VENDEDOR E TIPO
			
			Define MsDialog oCli Title "Dados do Cliente " From C(130),C(270) To C(270),C(700) Pixel
			
			
			@ C(005),C(005) Say "Vendedor :" Size C(030),C(010) Pixel Of oCli  
			@ C(005),C(030) MsGet oVend 	Var cVend Picture "@!" Size C(030),C(010) Pixel Of oCli F3 "SA3" VALID (vazio() .or. Existcpo("SA3") )
			
			@ C(025),C(005) Say "Tipo:" 	Size C(050),C(020) Pixel Of oCli
			@ C(025),C(030) COMBOBOX oTipo 	Var cTipo ITEMS aCombo Size C(125),C(040) Pixel Of oCli 
			 
			@ C(045),C(035) Button "Ok"	 		Size C(030),C(010) Pixel Action (nOpc:=1,oCli:End() )
			@ C(045),C(070) Button "Cancelar" 	Size C(030),C(010) Pixel Action (nOpc:=2,oCli:End() )
			
				
			Activate MsDialog oCli Centered   
			
			If nOpc == 2
				Return()
			EndIF
			
			ProcRegua(2)

			//Incluir Cliente
			
			cCodigo	:= ""
			cLoja	:= ""

			If SA1->(DbSeek(xFilial("SA1") + AllTrim(SubStr(SA2->A2_CGC,1,8)) ) ) 

				cCodigo	:= SA1->A1_COD
				cLoja	:= SA1->A1_LOJA
	
				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())
	
				While SA1->(DbSeek(xFilial("SA1") + cCodigo + cLoja ) )
					cLoja := Strzero((Val(cLoja) + 1),4)
				End

  		    Else
  		    
  		    	SA1->(DbSetOrder(1))
				SA1->(DbGoTop())
  		    
  		    	cCodigo	:= GETSXENUM("SA1","A1_COD")
  		    	
  		    	While SA1->(DbSeek(xFilial("SA1") + cCodigo + cLoja ) ) 
  		    	
  		    		cCodigo:= SOMA1(cCodigo)
  		    	
  		    	End
  		    	
  		    	cLoja	:= "0001"
  		    	
			EndIf
			
			AADD(aVetor,{"A1_COD"		,cCodigo 			,Nil})
			AADD(aVetor,{"A1_LOJA"		,cLoja 				,Nil})
			AADD(aVetor,{"A1_NOME"		,SA2->A2_NOME		,Nil})
			AADD(aVetor,{"A1_NREDUZ"	,SA2->A2_NREDUZ		,Nil})
			AADD(aVetor,{"A1_MSBLQL"	,"1"				,Nil})
			AADD(aVetor,{"A1_END"		,SA2->A2_END		,Nil})
			AADD(aVetor,{"A1_COMPLEM"	,SA2->A2_COMPLEM	,Nil})
			AADD(aVetor,{"A1_BAIRRO"	,SA2->A2_BAIRRO		,Nil})
			
			AADD(aVetor,{"A1_TIPO"		,AllTrim(cTipo)		,Nil})
			
			AADD(aVetor,{"A1_EST"		,SA2->A2_EST		,Nil})
			AADD(aVetor,{"A1_COD_MUN"	,SA2->A2_COD_MUN	,Nil})
			AADD(aVetor,{"A1_MUN"		,SA2->A2_MUN		,Nil})
			AADD(aVetor,{"A1_CEP"		,SA2->A2_CEP		,Nil})
			AADD(aVetor,{"A1_PESSOA"	,SA2->A2_TIPO		,Nil})
			AADD(aVetor,{"A1_PAIS"		,SA2->A2_PAIS		,Nil})
			AADD(aVetor,{"A1_EMAIL"		,SA2->A2_EMAIL		,Nil})
			AADD(aVetor,{"A1_CGC"		,SA2->A2_CGC		,Nil})
			AADD(aVetor,{"A1_INSCR"		,SA2->A2_INSCR		,Nil})
            
			If !Empty(SA2->A2_INSCRM)
		
				AADD(aVetor,{"A1_INSCRM"	,SA2->A2_INSCRM		,Nil})
				
			Else

				AADD(aVetor,{"A1_INSCRM"	,"ISENTO"		,Nil})
			
			EndIf

			If !Empty(SA2->A2_DDI)
		
				AADD(aVetor,{"A1_DDI"	,SA2->A2_DDI		,Nil})
			
			EndIf

			AADD(aVetor,{"A1_DDD"		,SA2->A2_DDD		,Nil})
			AADD(aVetor,{"A1_TEL"		,SA2->A2_TEL		,Nil})

			If !Empty(SA2->A2_CONTATO)
		
				AADD(aVetor,{"A1_CONTATO"	,SA2->A2_CONTATO		,Nil})
			
			EndIf

			If !Empty(SA2->A2_FAX)
		
				AADD(aVetor,{"A1_FAX"	,SA2->A2_FAX		,Nil})
			
			EndIf

			If !Empty(SA2->A2_PFISICA)
		
				AADD(aVetor,{"A1_PFISICA"	,SA2->A2_PFISICA		,Nil})
			
			EndIf

			If !Empty(SA2->A2_HPAGE)
		
				AADD(aVetor,{"A1_HPAGE"	,SA2->A2_HPAGE		,Nil})
			
			EndIf
			
			AADD(aVetor,{"A1_NATUREZ"	,SA2->A2_NATUREZ	,Nil})
			AADD(aVetor,{"A1_VEND"		,cVend				,Nil})
			

			If !Empty(SA2->A2_RECISS)
		
				AADD(aVetor,{"A1_RECISS"	,SA2->A2_RECISS	,Nil})
			
			EndIf

			AADD(aVetor,{"A1_CODPAIS"	,SA2->A2_CODPAIS	,Nil})

			If !Empty(SA2->A2_CODMUN)
		
				AADD(aVetor,{"A1_CODMUN"	,SA2->A2_CODMUN	,Nil})
			
			EndIf

			If !Empty(SA2->A2_TPESSOA)
		
				AADD(aVetor,{"A1_TPESSOA"	,SA2->A2_TPESSOA	,Nil})
			
			EndIf
			
			If !Empty(SA2->A2_RECINSS)
		
				AADD(aVetor,{"A1_RECINSS"	,SA2->A2_RECINSS	,Nil})
			
			EndIf
			
			AADD(aVetor,{"A1_CONTRIB"	,SA2->A2_CONTRIB	,Nil})
			AADD(aVetor,{"A1_XCADAST"	,"2"				,Nil})

			IncProc("Incluir Cliente")	

			MSExecAuto({|x,y| Mata030(x,y)},aVetor,3) //3- Inclusao, 4- Altera?o, 5- Exclus?
			
			If lMsErroAuto
	
				MostraErro()
				RollbackSx8()

			Else
			
				ConfirmSX8()

				MsgInfo("Cliente Incluido = " + cCodigo + " - " + cLoja + ". Favor validar e desbloquear o Cliente no Cadastro de Clientes.", "Fim")
																			
				If SA2->A2_XCADAST == '1' .or. Empty(SA2->A2_XCADAST)
				
					SA2->(Reclock("SA2",.F.))
					SA2->A2_XCADAST	:= "2"
					SA2->(MsUnLock())
			
				EndIf
	
			EndIf
	
		EndIf
		
		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		
    EndIf

Return()